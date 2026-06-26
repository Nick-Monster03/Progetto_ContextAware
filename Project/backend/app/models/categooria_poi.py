import enum
from typing import Optional
from sqlmodel import SQLModel, Field

class NomeCategoria(str, enum.Enum):
    BIBLIOTECA = "biblioteca"
    SALA_STUDIO = "sala_studio"
    MENSA = "mensa"
    UFFICIO = "ufficio"
    SEGRETERIA = "segreteria"
    FERMATA = "fermata"
    NOLEGGIO_BICI = "noleggio_bici"
    STAZIONE = "stazione"
    BENZINAIO = "benzinaio"

class CategoriaPOIBase(SQLModel):
    nome: NomeCategoria = Field(unique=True, index=True)

class CategoriaPOI(CategoriaPOIBase, table=True):
    __tablename__ = "categoria_poi"
    id: int | None = Field(default=None, primary_key=True)

class CategoriaPOICreate(CategoriaPOIBase):
    pass

class CategoriaPOIPublic(CategoriaPOIBase):
    id: int

class CategoriaPOIUpdate(SQLModel):
    nome: NomeCategoria | None = Field(default=None, unique=True)