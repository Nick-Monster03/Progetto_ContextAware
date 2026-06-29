from datetime import datetime
from typing import Optional, Any
from sqlmodel import DateTime, Field, SQLModel, String
import enum
from sqlalchemy import Column, func
from geoalchemy2 import Geometry

class TipoEvento(str, enum.Enum):
    AVVISO_AGENDA = 'Avviso_agenda'
    SUGGERIMENTO = 'Suggerimento'
    POI_SELEZIONATO = 'poi_selezionato'
    GEOFENCING_ENTER = 'geofencing_enter'
    GEOFENCING_EXIT = 'geofencing_exit'

class FeedbackEvento(str, enum.Enum):
    UTILE = 'Utile'
    NON_UTILE = 'Non Utile'

class EventoBase(SQLModel):
    id_utente: int = Field(foreign_key="utente.id")
    id_poi: int | None = Field(default=None, foreign_key="poi.id")
    tipo: TipoEvento = Field(default=TipoEvento.SUGGERIMENTO, sa_type=String(50))
    messaggio: str | None = Field(default=None)
    feedback: FeedbackEvento | None = Field(default=FeedbackEvento.NON_UTILE.value, sa_type=String(20))
    motivo: str | None = Field(default=None)
    

class Evento(EventoBase, table=True):
    __tablename__ = "evento"

    id: int | None = Field(default=None, primary_key=True)
    time_stamp: datetime | None = Field(
        default=None,
        sa_column=Column(DateTime, server_default=func.now()), 
    )
    posizione_utente_reale: Any | None = Field(
        default=None,
        sa_column=Column(Geometry(geometry_type="POINT", srid=4326, spatial_index=True)),
    )

class EventoCreate(EventoBase):
    latitudine: float 
    longitudine: float 

class EventoUpdate(SQLModel):
    feedback: FeedbackEvento | None = Field(default=FeedbackEvento.UTILE.value)
    motivo: str | None = Field(default=None)

class EventoPublic(EventoBase):
    id: int
    time_stamp: datetime
    latitudine: float 
    longitudine: float