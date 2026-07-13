from typing import Any
from sqlmodel import Column, SQLModel, Field, String
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
    campus: str = Field(default="Bologna", max_length=100)

class POI(POIBase, table=True):
    __tablename__ = "poi"
    id: int | None = Field(default=None, primary_key=True)
 

class POICreate(POIBase):
    pass
 
 
class POIPublic(POIBase):
    id: int
    
    # Se geometria è None, restituisce None.
    # Se è un WKBElement (tipico formato geometrico letto dal DB PostGIS/GeoAlchemy), lo converte in oggetto Shapely con to_shape.
    # Se poi è una geometria Shapely (BaseGeometry), la trasforma in dizionario con mapping(), cioè un formato tipo GeoJSON 
    # Se non è nessuno di questi casi, restituisce il valore com’è.

    @field_serializer("geometria")
    def serialize_geometria(self, geometria: Any, _info):
        if geometria is None:
            return None
        if isinstance(geometria, WKBElement):
            geometria = to_shape(geometria)
        if isinstance(geometria, BaseGeometry):
            return mapping(geometria)
        return geometria
 
class POIDistance(POIPublic):
    distance: float
    
class POIUpdate(SQLModel):
    nome: str | None = Field(default=None, max_length=150)
    id_categoria: int | None = Field(default=None, foreign_key="categoria_poi.id")
    descrizione: str | None = Field(default=None, max_length=500)
    geometria: Any | None = Field(default=None, sa_column=Column(Geometry(geometry_type="GEOMETRY", srid=4326, spatial_index=True), nullable=True))
    campus: str | None = Field(default=None, max_length=100)