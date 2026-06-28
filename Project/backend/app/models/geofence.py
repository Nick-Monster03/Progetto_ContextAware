from pydantic import BaseModel, Field

class GeofenceTriggerRequest(BaseModel):
    id_utente: int 
    id_poi: int 
    lat: float 
    lon: float 
    is_enter: bool 