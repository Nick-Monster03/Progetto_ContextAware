from datetime import datetime, time
from tkinter.tix import Select
from typing import Any, Dict, List
from fastapi import HTTPException, status
from sqlmodel import Session, select, text
from models.categooria_poi import CategoriaPOI
from models.poi import POI, POICreate, POIDistance, POIUpdate, POIPublic
from models.orari_poi import Orari_Poi

class PoiService: 
    def __init__(self, session: Session):
        self.session = session

    def get_all_poi(self) -> List[POI]:
        """Recupera tutti i POI presenti nel sistema."""
        query = select(POI)
        return self.session.exec(query).all()
    
    def get_poi_by_id(self, poi_id: int) -> POI:
        """Recupera un POI specifico tramite il suo ID."""
        poi = self.session.get(POI, poi_id)
        if not poi:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, # Meglio 404 per "non trovato" al posto di 500
                detail="POI non trovato"
            )
        return poi

    def get_poi_by_categoria(self, id_categoria: int) -> List[POI]:
        """Recupera tutti i POI associati a una categoria specifica."""
        query = (
            select(POI)
            .join(CategoriaPOI, POI.id_categoria == CategoriaPOI.id)
            .where(CategoriaPOI.id == id_categoria)
        )
        return self.session.exec(query).all()

    def get_orari_poi(self, poi_id: int) -> List[Orari_Poi]:
        """Recupera gli orari di apertura di un POI specifico."""
        query = select(Orari_Poi).where(Orari_Poi.id_poi == poi_id)
        return self.session.exec(query).all()
    
    def is_open(self, poi_id: int) -> bool:
        """Verifica se un POI è aperto in un determinato giorno e ora."""
        orari = self.get_orari_poi(poi_id)

        if not orari:
            return True
        
        now = datetime.now()
        giorno_db = (now.weekday() + 1) % 7
        orario_attuale = now.time()

        for orario in orari:
            if orario.giorno == giorno_db and orario.orario_apertura <= orario_attuale <= orario.orario_chiusura:
                return True
        return False    

    def create_poi(self, poi_data: POICreate) -> POI:
        """Crea un nuovo Punto di Interesse."""
        db_poi = POI.model_validate(poi_data)
        self.session.add(db_poi)
        self.session.commit()
        self.session.refresh(db_poi)
        return db_poi

    def get_pois_nearby(self, lat: float, lon: float, radius_meters: float = 2000.0) -> List[POI]:
        """Recupera i POI entro un raggio specificato (default 2km come da traccia)."""
        
        query = select(POI).where(
            text("""
                ST_DWithin(
                    ST_Transform(geometria, 32632), 
                    ST_Transform(ST_SetSRID(ST_MakePoint(:lon, :lat), 4326), 32632), 
                    :radius
                )
            """)
        )

        risultati = self.session.exec(query, params={"lat": lat, "lon": lon, "radius": radius_meters}).all()
        return risultati

    def update_poi(self, poi_id: int, poi_in: POIUpdate) -> POI:
        db_poi = self.get_poi_by_id(poi_id)
        update_data = poi_in.model_dump(exclude_unset=True)
        db_poi.sqlmodel_update(update_data)

        self.session.add(db_poi)
        self.session.commit()
        return db_poi

    def delete_poi(self, poi_id: int) -> POI:
        db_poi = self.get_poi_by_id(poi_id)
        self.session.delete(db_poi)
        self.session.commit()
        return db_poi

    def _filter_by_mezzo_spostamento(self, query: Select, params: Dict[str, Any], mezzo_spostamento: str) -> Select:
        """Aggiunge il filtro basato sulle preferenze del mezzo di spostamento."""
        categoria_mappata = None
        if mezzo_spostamento in ["AUTO", "MOTO"]:
            categoria_mappata = "benzinaio"
        elif mezzo_spostamento == "AUTOBUS":
            categoria_mappata = "fermata"
        elif mezzo_spostamento == "TRENO":
            categoria_mappata = "stazione"
        elif mezzo_spostamento == "BICI A NOLEGGIO":
            categoria_mappata = "noleggio_bici"

        if categoria_mappata:
            query = query.where(
                text("poi.id_categoria IN (SELECT id FROM categoria_poi WHERE nome = :cat_nome)")
            )
            params["cat_nome"] = categoria_mappata
        return query

    def _filter_by_orario(
        self, query: Select, params: Dict[str, Any], orario_apertura: time | None, orario_chiusura: time | None
    ) -> Select:
        """Filtra i POI in base a un orario desiderato (include i POI H24 senza orari)."""
        if orario_apertura is None and orario_chiusura is None:
            return query

        now = datetime.now()
        giorno_db = (now.weekday() + 1) % 7
        params["giorno"] = giorno_db

        where_clauses = [
            "orario_poi.id_poi = poi.id",
            "orario_poi.giorno = :giorno"
        ]

        if orario_apertura is not None:
            where_clauses.append("orario_poi.orario_apertura <= :orario_apertura")
            params["orario_apertura"] = orario_apertura

        if orario_chiusura is not None:
            where_clauses.append("orario_poi.orario_chiusura >= :orario_chiusura")
            params["orario_chiusura"] = orario_chiusura

        clausole_sql = " AND ".join(where_clauses)

        query = query.where(
            text(f"""
                (
                    EXISTS (
                        SELECT 1 FROM orario_poi 
                        WHERE {clausole_sql}
                    )
                    OR
                    NOT EXISTS (
                        SELECT 1 FROM orario_poi 
                        WHERE orario_poi.id_poi = poi.id
                    )
                )
            """)
        )
        return query

    def _filter_by_spaziale(
        self, query: Select, params: Dict[str, Any], lat: float, lon: float, max_distance_meters: float | None
    ) -> Select:
        """Aggiunge il filtro spaziale PostGIS e l'ordinamento per distanza."""
        params["lat"] = lat
        params["lon"] = lon
        
        if max_distance_meters is not None:
            query = query.where(
                text("""
                    ST_DWithin(
                        ST_Transform(geometria, 32632), 
                        ST_Transform(ST_SetSRID(ST_MakePoint(:lon, :lat), 4326), 32632), 
                        :radius
                    )
                """)
            )
            params["radius"] = max_distance_meters

        query = query.order_by(
            text("""
                ST_Distance(
                    ST_Transform(geometria, 32632), 
                    ST_Transform(ST_SetSRID(ST_MakePoint(:lon, :lat), 4326), 32632)
                )
            """)
        )
        return query

    def _filter_by_campus(self, query: Select, params: Dict[str, Any], campus: str) -> Select:
        """Aggiunge il filtro basato sul campus di appartenenza."""
        query = query.where(POI.campus == campus)
        params["campus"] = campus
        return query

    def get_filtered_pois(
        self,
        lat: float | None = None,
        lon: float | None = None,
        id_categoria: int | None = None,
        max_distance_meters: float | None = None,
        orario_apertura: time | None = None,
        orario_chiusura: time | None = None,
        mezzo_spostamento: str | None = None,
        campus: str | None = None
    ) -> List[POI]:
        """
        Punto di ingresso per il filtraggio dinamico. 
        """
        query = select(POI)
        params: Dict[str, Any] = {}

        if id_categoria is not None:
            query = query.where(POI.id_categoria == id_categoria)
        
        if campus is not None:
            query = self._filter_by_campus(query, params, campus)
            
        if mezzo_spostamento is not None:
            query = self._filter_by_mezzo_spostamento(query, params, mezzo_spostamento)
            
        if orario_apertura is not None or orario_chiusura is not None:
            query = self._filter_by_orario(query, params, orario_apertura, orario_chiusura)
            
        if lat is not None and lon is not None:
            query = self._filter_by_spaziale(query, params, lat, lon, max_distance_meters)

        return self.session.exec(query, params=params).all()
    

    def get_pois_nearby_with_distance(self, lat: float, lon: float, radius_meters: float = 2000.0) -> List[POIDistance]:
        """
        Recupera i POI entro un raggio specificato (default 2km) e 
        restituisce una lista di oggetti POIDistance (che unisce i dati del POI e la distanza).
        """
        
        distance_expr = text("""
            ST_Distance(
                ST_Transform(geometria, 32632), 
                ST_Transform(ST_SetSRID(ST_MakePoint(:lon, :lat), 4326), 32632)
            )
        """)

        query = select(POI, distance_expr).where(
            text("""
                ST_DWithin(
                    ST_Transform(geometria, 32632), 
                    ST_Transform(ST_SetSRID(ST_MakePoint(:lon, :lat), 4326), 32632), 
                    :radius
                )
            """)
        )

        risultati_grezzi = self.session.exec(
            query, 
            params={"lat": lat, "lon": lon, "radius": radius_meters}
        ).all()
        
        lista_risultati = []
        for riga in risultati_grezzi:
            poi = riga[0]      
            distanza = riga[1]  
            poi_data = poi.model_dump()
            poi_distance_obj = POIDistance(**poi_data, distance=distanza)
            lista_risultati.append(poi_distance_obj)
            
        return lista_risultati