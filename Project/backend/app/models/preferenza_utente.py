from sqlmodel import SQLModel, Field

class PreferenzaUtente(SQLModel, table=True):
    __tablename__ = "preferenza_utente"

    id_utente: int = Field(primary_key=True, foreign_key="utente.id", nullable=False)
    id_categoria: int = Field(primary_key=True, foreign_key="categoria_poi.id", nullable=False)

class PreferenzaUtenteCreate(SQLModel):
    id_utente: int
    id_categoria: int

class PreferenzaUtentePublic(SQLModel):
    id_utente: int
    id_categoria: int

class PreferenzaUtenteUpdate(SQLModel):
    id_utente: int | None = Field(default=None)
    id_categoria: int | None = Field(default=None)