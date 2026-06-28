import enum
from typing import Optional
from sqlmodel import Field, SQLModel

class MezzoSpostamento(str, enum.Enum):
    A_PIEDI = "A PIEDI"
    BICI_A_NOLEGGIO = "BICI A NOLEGGIO"
    AUTOBUS = "AUTOBUS"
    TRENO = "TRENO"
    MOTO = "MOTO"
    AUTO = "AUTO"
    ALTRO = "ALTRO"

class UtenteBase(SQLModel):
    nome: str = Field(max_length=100, index=True)
    cognome: str = Field(max_length=100, index=True)
    campus: str | None = Field(default=None, max_length=100)
    mezzo_di_spostamento: MezzoSpostamento | None = Field(default=MezzoSpostamento.A_PIEDI)

class Utente(UtenteBase, table=True):
    __tablename__ = "utente"
    id: int | None = Field(default=None, primary_key=True)
    mezzo_di_spostamento: str | None = Field(default=MezzoSpostamento.A_PIEDI.value, max_length=50)

class UtenteCreate(UtenteBase):
    pass

class UtentePublic(UtenteBase):
    id: int

class UtenteUpdate(UtenteBase):
    nome: str | None = Field(default=None, max_length=100)
    cognome: str | None = Field(default=None, max_length=100)
    campus: str | None = Field(default=None, max_length=100)
    mezzo_di_spostamento: MezzoSpostamento | None = Field(default=None)
    