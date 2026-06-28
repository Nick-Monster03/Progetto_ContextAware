from typing import List
from fastapi import APIRouter, Depends, status
from sqlmodel import Session

from session.database import get_session
from models.preferenza_utente import PreferenzaUtentePublic, PreferenzaUtenteCreate
from services.preferenza_service import PreferenzaService

router = APIRouter(prefix="/preferenze", tags=["Preferenze Utente"])

# Perfetto: questa dependency si occuperà di creare l'istanza del servizio per ogni richiesta
def get_preferenza_service(session: Session = Depends(get_session)) -> PreferenzaService:
    return PreferenzaService(session=session)

@router.get("/utente/{id_utente}", response_model=List[PreferenzaUtentePublic])
def read_categorie_by_utente(id_utente: int, service: PreferenzaService = Depends(get_preferenza_service)):
    """
    Ottiene tutte le associazioni (preferenze) di un utente. 
    """
    return service.get_categorie_by_utente(id_utente=id_utente)

@router.get("/categoria/{id_categoria}", response_model=List[PreferenzaUtentePublic])
def read_utenti_by_categoria(id_categoria: int, service: PreferenzaService = Depends(get_preferenza_service)):
    """
    Ottiene tutte le associazioni (preferenze) per una determinata categoria.
    """
    return service.get_utenti_by_categoria(id_categoria=id_categoria)

@router.post("/", response_model=PreferenzaUtentePublic, status_code=status.HTTP_201_CREATED)
def create_preferenza(preferenza_in: PreferenzaUtenteCreate, service: PreferenzaService = Depends(get_preferenza_service)):
    """
    Crea una nuova preferenza utente-categoria.
    """
    return service.create_preferenza(preferenza_in=preferenza_in)

@router.delete("/", status_code=status.HTTP_204_NO_CONTENT)
def delete_preferenza(id_utente: int, id_categoria: int, service: PreferenzaService = Depends(get_preferenza_service)):
    """
    Elimina una preferenza specifica passando id_utente e id_categoria come query parameters.
    """
    service.delete_preferenza(id_utente=id_utente, id_categoria=id_categoria)
    return