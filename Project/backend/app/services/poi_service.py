from datetime import datetime
from typing import List
from fastapi import HTTPException, status
from sqlmodel import Session, select, text
from models.categooria_poi import CategoriaPOI
from models.poi import POI, POICreate
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