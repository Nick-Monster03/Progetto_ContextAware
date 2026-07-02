from pydantic import BaseModel, Field

from models.poi import POIPublic

class GeofenceTriggerRequest(BaseModel):
    id_utente: int 
    id_poi: int 
    lat: float 
    lon: float 
    is_enter: bool 

class GeofenceConfigResponse(BaseModel):
    poi: POIPublic
    raggio: float
    motivo: str