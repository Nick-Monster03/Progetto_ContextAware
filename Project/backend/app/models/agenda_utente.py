from datetime import datetime
from typing import Optional

from sqlalchemy import Column, DateTime
from sqlmodel import Field, SQLModel


class AgendaUtenteBase(SQLModel):
    id_utente: int = Field(foreign_key="utente.id", nullable=False)
    id_poi: int = Field(foreign_key="poi.id", nullable=False)
    titolo: str = Field(max_length=100, nullable=False)
    orario_inizio: datetime = Field(sa_column=Column(DateTime(timezone=True), nullable=False))
    orario_fine: datetime = Field(sa_column=Column(DateTime(timezone=True), nullable=False))


class AgendaUtente(AgendaUtenteBase, table=True):
    __tablename__ = "agenda_utente"

    id: int | None = Field(default=None, primary_key=True, index=True)


class AgendaUtenteCreate(AgendaUtenteBase):
    pass


class AgendaUtentePublic(AgendaUtenteBase):
    id: int


class AgendaUtenteUpdate(SQLModel):
    id_utente: int | None = Field(default=None)
    id_poi: int | None = Field(default=None)
    titolo: str | None = Field(default=None, max_length=100)
    orario_inizio: datetime | None = Field(default=None)
    orario_fine: datetime | None = Field(default=None)