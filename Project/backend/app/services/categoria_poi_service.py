from datetime import datetime
from typing import List
from fastapi import HTTPException, status
from sqlmodel import Session, select
from models.categooria_poi import CategoriaPOI
from models.poi import POI
from models.orari_poi import OrariPOI

class categoria_poi_service:
    def __init__(self, session: Session):
        self.session = session
    
    def get_all_categorie(self) -> List[CategoriaPOI]:
        """Recupera tutte le categorie di POI presenti nel sistema."""
        query = select(CategoriaPOI)
        return self.session.exec(query).all()
    
    def get_categoria_by_poi_id(self, poi_id: int) -> CategoriaPOI:
        """Recupera tutte le categorie associate a un POI specifico."""
        query = (
            select(CategoriaPOI)
            .join(POI, CategoriaPOI.id == POI.id_categoria)
            .where(POI.id == poi_id)
        )
        return self.session.exec(query).all()