from typing import List, Optional
from fastapi import HTTPException, status
from sqlmodel import Session, select
from models.categooria_poi import CategoriaPOI, NomeCategoria
from models.poi import POI

class CategoriaPOIService:
    def __init__(self, session: Session):
        self.session = session
    
    def get_all_categorie(self) -> List[CategoriaPOI]:
        """Recupera tutte le categorie di POI presenti nel sistema."""
        query = select(CategoriaPOI)
        return self.session.exec(query).all()
    
    def get_categoria_by_poi_id(self, poi_id: int) -> CategoriaPOI:
        """Recupera la singola categoria associata a un POI specifico."""
        query = (
            select(CategoriaPOI)
            .join(POI, CategoriaPOI.id == POI.id_categoria)
            .where(POI.id == poi_id)
        )
        categoria = self.session.exec(query).first() #POI ha solo una categoria
        
        if not categoria:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, 
                detail=f"Categoria per il POI con id {poi_id} non trovata"
            )
            
        return categoria

    def get_categoria_by_id(self, categoria_id: int) -> CategoriaPOI:
        """Recupera una categoria tramite il suo ID primario."""
        categoria = self.session.get(CategoriaPOI, categoria_id)
        if not categoria:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, 
                detail=f"Categoria con id {categoria_id} non trovata"
            )
        return categoria

    def get_categoria_by_nome(self, nome: NomeCategoria) -> CategoriaPOI:
        """Recupera una categoria tramite il suo nome Enum (es. 'biblioteca')."""
        query = select(CategoriaPOI).where(CategoriaPOI.nome == nome)
        categoria = self.session.exec(query).first()
        if not categoria:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
                detail=f"Categoria '{nome}' non trovata"
            )
        return categoria
    
    