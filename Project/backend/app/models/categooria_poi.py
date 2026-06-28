import enum
from sqlmodel import SQLModel, Field, String, Column

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
    nome: NomeCategoria = Field(sa_column=Column(String(50), unique=True, index=True))

class CategoriaPOI(CategoriaPOIBase, table=True):
    __tablename__ = "categoria_poi"
    id: int | None = Field(default=None, primary_key=True)

class CategoriaPOICreate(CategoriaPOIBase):
    pass

class CategoriaPOIPublic(CategoriaPOIBase):
    id: int

class CategoriaPOIUpdate(SQLModel):
    nome: NomeCategoria | None = Field(default=None, sa_column=Column(String(50)))