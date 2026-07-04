from sqlmodel import Session, select
from typing import List, Dict, Any
from models.poi import POI
from models.utente import Utente
from models.preferenza_utente import PreferenzaUtente
from models.categooria_poi import CategoriaPOI
from models.evento import Evento, TipoEvento, EventoPublic

class GeofenceService:
    def __init__(self, session: Session):
        self.session = session

    def _get_categoria_by_mezzo(self, mezzo_spostamento: str) -> int | None:
        """Utility interna per trovare l'ID della categoria associata al mezzo di trasporto."""
        nome_categoria = None
        if mezzo_spostamento in ["AUTO", "MOTO"]:
            nome_categoria = "benzinaio"
        elif mezzo_spostamento == "AUTOBUS":
            nome_categoria = "fermata"
        elif mezzo_spostamento == "TRENO":
            nome_categoria = "stazione"
        elif mezzo_spostamento == "BICI A NOLEGGIO":
            nome_categoria = "noleggio_bici"

        if not nome_categoria:
            return None

        query = select(CategoriaPOI.id).where(CategoriaPOI.nome == nome_categoria)
        return self.session.exec(query).first()

    def get_geofence_config(self, id_utente: int) -> List[Dict[str, Any]]:
        """
        Restituisce la lista dei POI da monitorare con il geofencing.
        Sfoltita: solo preferenze utente (no mezzi) e max 99 elementi per Android.
        """
        utente = self.session.get(Utente, id_utente)
        if not utente:
            raise ValueError("Utente non trovato")

        configurazioni = []

        query_pref = select(PreferenzaUtente.id_categoria).where(PreferenzaUtente.id_utente == id_utente)
        categorie_preferite = self.session.exec(query_pref).all()

        if categorie_preferite:
            query_poi_pref = select(POI).where(POI.id_categoria.in_(categorie_preferite))
            pois_pref = self.session.exec(query_poi_pref).all()
            
            for p in pois_pref:
                configurazioni.append({
                    "poi": p, 
                    "raggio": 10.0, 
                    "motivo": "Categoria preferita"
                })

        return configurazioni[:99] #carico i primi 99 perchè android ha un limite di 100 geofences

    def trigger_evento_geofence(
        self, id_utente: int, id_poi: int, lat: float, lon: float, is_enter: bool
    ) -> EventoPublic:
        """
        Registra nel DB l'ingresso o l'uscita da un recinto virtuale.
        """
        poi = self.session.get(POI, id_poi)
        if not poi:
            raise ValueError("POI non trovato")

        tipo_evento = TipoEvento.GEOFENCING_ENTER if is_enter else TipoEvento.GEOFENCING_EXIT
        azione = "entrato nell'" if is_enter else "uscito dall'"
        messaggio = f"Sei {azione} area di {poi.nome}."

        nuovo_evento = Evento(
            id_utente=id_utente,
            id_poi=id_poi,
            tipo=tipo_evento,
            messaggio=messaggio,
            motivo="Geofence scattato",
            posizione_utente_reale=f"SRID=4326;POINT({lon} {lat})"
        )

        self.session.add(nuovo_evento)
        self.session.commit()

        return EventoPublic(
            id=nuovo_evento.id,
            id_utente=nuovo_evento.id_utente,
            id_poi=nuovo_evento.id_poi,
            tipo=nuovo_evento.tipo,
            messaggio=nuovo_evento.messaggio,
            motivo=nuovo_evento.motivo,
            feedback=nuovo_evento.feedback,
            time_stamp=nuovo_evento.time_stamp,
            latitudine=lat,
            longitudine=lon
        )