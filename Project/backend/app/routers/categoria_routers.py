from typing import List
from fastapi import APIRouter, Depends
from sqlmodel import Session

from session.database import get_session
from services.categoria_poi_service import CategoriaPOIService
from models.categooria_poi import CategoriaPOIPublic, NomeCategoria

router = APIRouter(prefix="/categorie", tags=["Categorie POI"])

def get_categoria_service(session: Session = Depends(get_session)) -> CategoriaPOIService:
    return CategoriaPOIService(session)

@router.get("/", response_model=List[CategoriaPOIPublic])
def get_all_categorie(service: CategoriaPOIService = Depends(get_categoria_service)):
    """Restituisce la lista di tutte le categorie disponibili."""
    return service.get_all_categorie()

@router.get("/{categoria_id}", response_model=CategoriaPOIPublic)
def get_categoria_by_id(
    categoria_id: int, 
    service: CategoriaPOIService = Depends(get_categoria_service)
):
    """Recupera una specifica categoria tramite il suo ID."""
    return service.get_categoria_by_id(categoria_id)

@router.get("/nome/{nome}", response_model=CategoriaPOIPublic)
def get_categoria_by_nome(
    nome: NomeCategoria, 
    service: CategoriaPOIService = Depends(get_categoria_service)
):
    """
    Recupera una categoria in base al nome (Enum). 
    FastAPI validerà automaticamente che il nome inserito sia tra quelli validi.
    """
    return service.get_categoria_by_nome(nome)

@router.get("/poi/{poi_id}", response_model=CategoriaPOIPublic)
def get_categoria_by_poi_id(
    poi_id: int, 
    service: CategoriaPOIService = Depends(get_categoria_service)
):
    """Recupera la categoria a cui appartiene un determinato POI."""
    return service.get_categoria_by_poi_id(poi_id)