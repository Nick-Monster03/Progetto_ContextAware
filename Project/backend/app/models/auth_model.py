from pydantic import BaseModel


class LoginRequest(BaseModel):
    nome: str
    cognome: str
    password: str