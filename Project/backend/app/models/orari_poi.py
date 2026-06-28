from datetime import time
from typing import Optional
from sqlmodel import SQLModel, Field

class Orari_PoiBase(SQLModel):
    id_poi: int = Field(foreign_key="poi.id", index=True)
    giorno: int = Field(ge=0, le=6)  
    orario_apertura: time 
    orario_chiusura: time 

class Orari_Poi(Orari_PoiBase, table=True):
    __tablename__ = "orario_poi"
    id: int | None = Field(default=None, primary_key=True)
    
class Orari_PoiCreate(Orari_PoiBase):
    pass

class Orari_PoiPublic(Orari_PoiBase):
    id: int

class Orari_PoiUpdate(SQLModel):
    giorno: int | None = Field(default=None, ge=0, le=6)
    orario_apertura: time | None = Field(default=None)
    orario_chiusura: time | None = Field(default=None)