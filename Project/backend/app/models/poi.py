from typing import Optional, Any
from sqlmodel import Column, SQLModel, Field
from sqlalchemy import Column
from geoalchemy2 import Geometry

class POIBase(SQLModel):    
    nome: str = Field(max_length=150, nullable=False, index=True)
    id_categoria: int = Field(foreign_key="categoria_poi.id", index=True)
    descrizione: str | None = Field(default=None, max_length=500)
    geometria: Any = Field(sa_column=Column(Geometry(geometry_type="GEOMETRY", srid=4326, spatial_index=True)))

class POI(POIBase, table=True):
    __tablename__ = "poi"
    id: int | None = Field(default=None, primary_key=True)

class POICreate(POIBase):
    pass

class POIPublic(POIBase):
    id: int

class POIUpdate(SQLModel):
    nome: str | None = Field(default=None, max_length=150)
    id_categoria: int | None = Field(default=None, foreign_key="categoria_poi.id")
    descrizione: str | None = Field(default=None, max_length=500)
    geometria: Any | None = Field(default=None, sa_column=Column(Geometry(geometry_type="GEOMETRY", srid=4326, spatial_index=True), nullable=True))