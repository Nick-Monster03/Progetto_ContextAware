from sqlmodel import Session, select
from typing import List, Dict, Any
from models.ranking import RankingResult
from models.evento import Evento, EventoPublic, TipoEvento
from models.preferenza_utente import PreferenzaUtente
from models.utente import Utente
from models.categooria_poi import CategoriaPOI
from services.poi_service import PoiService
from models.poi import POIDistance

class RaccomandationService:
    def __init__(self, session: Session, poi_service: PoiService):
        self.session = session
        self.poi_service = poi_service

    def get_user_preferences(self, id_utente: int) -> List[int]:
        """Recupera la lista degli id_categoria preferiti esplicitamente dall'utente."""
        query = select(PreferenzaUtente.id_categoria).where(PreferenzaUtente.id_utente == id_utente)
        return self.session.exec(query).all()

    def get_categoria_by_mezzo(self, mezzo_spostamento: str) -> int | None:
        """Mappa il mezzo di spostamento alla categoria più rilevante per quel mezzo
        (es. chi usa l'auto sarà interessato ai benzinai in zona) e ne restituisce l'ID."""
        nome_categoria = None
        if mezzo_spostamento in ["AUTO", "MOTO"]:
            nome_categoria = "benzinaio"
        elif mezzo_spostamento == "AUTOBUS":
            nome_categoria = "fermata"
        elif mezzo_spostamento == "TRENO":
            nome_categoria = "stazione"
        elif mezzo_spostamento == "BICI A NOLEGGIO":
            nome_categoria = "noleggio_bici"

        #DEBUG
        #print(f"Mezzo di spostamento: {mezzo_spostamento}, Categoria corrispondente: {nome_categoria}")

        if not nome_categoria:
            return None
        query = select(CategoriaPOI.id).where(CategoriaPOI.nome == nome_categoria)
        return self.session.exec(query).first()

    def calculate_ranking(self, id_utente: int, lat: float, lon: float) -> List[RankingResult]:
        
        pois_vicini = self.poi_service.get_pois_nearby_with_distance(lat, lon, radius_meters=2000.0)
        
        utente = self.session.get(Utente, id_utente)
        categorie_preferite = self.get_user_preferences(id_utente)

        #print(f"categorie_preferite: {categorie_preferite}")

        if utente and utente.mezzo_di_spostamento:
            cat_mezzo_id = self.get_categoria_by_mezzo(utente.mezzo_di_spostamento)
            if cat_mezzo_id and cat_mezzo_id not in categorie_preferite:
                categorie_preferite.append(cat_mezzo_id)
        
        risultati_ranking = []

        for item in pois_vicini:
            poi = item  
            if poi.distance <= 0:
                punteggio = 1000.0
            else:
                punteggio = 1000.0 / poi.distance
            if poi.id_categoria in categorie_preferite:
                punteggio = punteggio * 2.5
            if not self.poi_service.is_open(poi.id):
                punteggio = punteggio * 0.0
            if punteggio > 0:
                risultati_ranking.append(RankingResult(poi=poi, punteggio=round(punteggio, 2)))


        if not risultati_ranking and pois_vicini:
            for poi in pois_vicini:
                if self.poi_service.is_open(poi.id):
                    if poi.distance <= 0:
                        punteggio = 1000.0
                    else:
                        punteggio = 1000.0 / poi.distance
                    risultati_ranking.append(RankingResult(poi=poi, punteggio=round(punteggio, 2)))
                    break 
        
        risultati_ranking = sorted(risultati_ranking, key=lambda x: x.punteggio, reverse=True)
        
        #DEBUG
        #print(f"Ranking calcolato per utente {id_utente} in posizione ({lat}, {lon}):")
        #for r in risultati_ranking:
        #   print(f"POI: {r.poi.nome}, Punteggio: {r.punteggio}, Distanza: {r.poi.distance} metri, Categoria: {r.poi.id_categoria}")
        return risultati_ranking
    
    def get_ranking_list(self, id_utente: int, lat: float, lon: float)-> List[RankingResult]:
        
        ranking = self.calculate_ranking(id_utente, lat, lon)
        
        ranking = list(filter(lambda x: x.punteggio > 0, ranking))

        if not ranking:
            return []
    
        ranking = sorted(ranking, key=lambda x: x.punteggio, reverse=True)
        return ranking[:20]
    
    def generate_startup_suggestion(self, id_utente: int, lat: float, lon: float) -> EventoPublic | dict:
        
        ranking = self.calculate_ranking(id_utente, lat, lon)

        if not ranking:
            return {"message": "Nessun POI nelle vicinanze o tutti chiusi."}

        miglior_risultato = ranking[0]
        miglior_poi = miglior_risultato.poi
        punteggio = miglior_risultato.punteggio

        nuovo_evento = Evento(
            id_utente=id_utente,
            id_poi=miglior_poi.id,
            tipo=TipoEvento.SUGGERIMENTO,
            messaggio=f"Sei nei paraggi di {miglior_poi.nome}, potrebbe interessarti!",
            motivo=f"Miglior POI per contesto attuale (Punteggio: {punteggio})",
            posizione_utente_reale=f"SRID=4326;POINT({lon} {lat})"
        )

        self.session.add(nuovo_evento)
        self.session.commit()
        self.session.refresh(nuovo_evento)

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