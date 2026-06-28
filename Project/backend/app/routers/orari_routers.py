from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session
from typing import List

from session.database import get_session
from models.orari_poi import Orari_PoiCreate, Orari_PoiUpdate, Orari_PoiPublic
from services.orari_service import OrariPoiService

router = APIRouter(prefix="/orari", tags=["Orari POI"])

def get_orari_poi_service(session: Session = Depends(get_session)) -> OrariPoiService:
    return OrariPoiService(session=session)

@router.post("/", response_model=Orari_PoiPublic, status_code=status.HTTP_201_CREATED)
def create_orario(orario_in: Orari_PoiCreate, service: OrariPoiService = Depends(get_orari_poi_service)):
    """
    Aggiunge un nuovo orario di apertura/chiusura per un POI.
    Il giorno deve essere compreso tra 0 (Domenica) e 6 (Sabato).
    """
    try:
        return service.create_orario(orario_in=orario_in)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{orario_id}", response_model=Orari_PoiPublic)
def read_orario(orario_id: int, service: OrariPoiService = Depends(get_orari_poi_service)):
    """
    Recupera un singolo orario tramite il suo ID (metodo più di debug).
    """
    try:
        return service.get_orario(orario_id=orario_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

@router.get("/poi/{id_poi}", response_model=List[Orari_PoiPublic])
def read_orari_by_poi(id_poi: int, service: OrariPoiService = Depends(get_orari_poi_service)):
    """
    Ottiene tutti gli orari associati a un determinato POI.
    """
    return service.get_orari_by_poi(id_poi=id_poi)

@router.patch("/{orario_id}", response_model=Orari_PoiPublic)
def update_orario(orario_id: int, orario_in: Orari_PoiUpdate, service: OrariPoiService = Depends(get_orari_poi_service)):
    """
    Modifica un orario esistente. Invia solo i campi che vuoi aggiornare.
    """
    try:
        return service.update_orario(orario_id=orario_id, orario_in=orario_in)
    except ValueError as e:
        if "non trovato" in str(e).lower():
            raise HTTPException(status_code=404, detail=str(e))
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{orario_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_orario(orario_id: int, service: OrariPoiService = Depends(get_orari_poi_service)):
    """
    Elimina un orario specifico.
    """
    try:
        service.delete_orario(orario_id=orario_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    return None