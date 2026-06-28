from typing import List
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlmodel import Session

from session.database import get_session
from services.geofence_service import GeofenceService
from models.poi import POIPublic
from models.evento import EventoPublic
from models.geofence import GeofenceTriggerRequest

router = APIRouter(prefix="/geofence", tags=["Geofencing"])

class GeofenceConfigResponse(BaseModel):
    poi: POIPublic
    raggio: float
    motivo: str

def get_geofence_service(session: Session = Depends(get_session)) -> GeofenceService:
    return GeofenceService(session)

@router.post("/trigger", response_model=EventoPublic)
def trigger_geofence(
    request: GeofenceTriggerRequest,  
    service: GeofenceService = Depends(get_geofence_service)
):
    """
    Registra l'evento nel DB quando l'utente attraversa un geofence.
    """
    return service.trigger_evento_geofence(
        id_utente=request.id_utente, 
        id_poi=request.id_poi, 
        lat=request.lat, 
        lon=request.lon, 
        is_enter=request.is_enter
    )

@router.get("/config/{id_utente}", response_model=List[GeofenceConfigResponse])
def get_geofence_config(
    id_utente: int, 
    service: GeofenceService = Depends(get_geofence_service)
):
    """
    Restituisce la lista di POI e i relativi raggi (10m o 100m) 
    che l'app mobile deve sorvegliare per l'utente specificato.
    """
    return service.get_geofence_config(id_utente)