from typing import Any
from sqlmodel import Column, SQLModel, Field
from geoalchemy2 import Geometry
from geoalchemy2.elements import WKBElement
from geoalchemy2.shape import to_shape
from shapely.geometry import mapping
from shapely.geometry.base import BaseGeometry
from pydantic import field_serializer
 
 
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
 
    @field_serializer("geometria")
    def serialize_geometria(self, geometria: Any, _info):
        if geometria is None:
            return None
        if isinstance(geometria, WKBElement):
            geometria = to_shape(geometria)
        if isinstance(geometria, BaseGeometry):
            return mapping(geometria)
        return geometria
 
 
class POIUpdate(SQLModel):
    nome: str | None = Field(default=None, max_length=150)
    id_categoria: int | None = Field(default=None, foreign_key="categoria_poi.id")
    descrizione: str | None = Field(default=None, max_length=500)
    geometria: Any | None = Field(default=None, sa_column=Column(Geometry(geometry_type="GEOMETRY", srid=4326, spatial_index=True), nullable=True))
