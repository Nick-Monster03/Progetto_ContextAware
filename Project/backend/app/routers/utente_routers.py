# routers/utente_router.py
from typing import List
from fastapi import APIRouter, Depends, status
from sqlmodel import Session
from session.database import get_session
from services.utente_service import UtenteService
from models.utente import UtentePublic, UtenteCreate, UtenteUpdate, MezzoSpostamento
#from models.categooria_poi import CategoriaPOIPublic 

router = APIRouter(prefix="/utenti", tags=["Utenti"])

def get_utente_service(session: Session = Depends(get_session)) -> UtenteService:
    return UtenteService(session)

@router.post("/", response_model=UtentePublic, status_code=status.HTTP_201_CREATED)
def create_utente(
    utente_in: UtenteCreate, 
    service: UtenteService = Depends(get_utente_service)
):
    """Crea un nuovo utente nel sistema."""
    
    return service.create_utente(utente_in)

@router.get("/", response_model=List[UtentePublic])
def get_all_utenti(service: UtenteService = Depends(get_utente_service)):
    """Recupera tutti gli utenti del sistema."""

    return service.get_all_utenti()

@router.get("/{utente_id}", response_model=UtentePublic)
def get_utente(
    utente_id: int, 
    service: UtenteService = Depends(get_utente_service)
):
    """Recupera un utente tramite il suo ID."""
    
    return service.get_utente(utente_id)

@router.patch("/{utente_id}", response_model=UtentePublic)
def update_utente(
    utente_id: int, 
    utente_in: UtenteUpdate, 
    service: UtenteService = Depends(get_utente_service)
):
    """Aggiorna i dati del profilo di un utente esistente."""
    
    #print(f" da route Utente da aggiornare: {utente_in}")
    return service.update_utente(utente_id, utente_in)

@router.delete("/{utente_id}", status_code=status.HTTP_200_OK)
def delete_utente(
    utente_id: int, 
    service: UtenteService = Depends(get_utente_service)
):
    """Elimina un utente dal sistema."""
    
    return service.delete_utente(utente_id)


@router.get("/campus/{campus}", response_model=List[UtentePublic])
def get_utenti_by_campus(
    campus: str, 
    service: UtenteService = Depends(get_utente_service)
):
    """Recupera tutti gli utenti iscritti a un determinato campus."""

    return service.get_utenti_by_campus(campus)

@router.get("/mezzo/{mezzo}", response_model=List[UtentePublic])
def get_utenti_by_mezzo(
    mezzo: MezzoSpostamento, 
    service: UtenteService = Depends(get_utente_service)
):
    """Recupera tutti gli utenti che utilizzano un determinato mezzo di spostamento."""
    
    return service.get_utenti_by_mezzo(mezzo)

@router.get("/preferenza/{id_categoria}", response_model=List[UtentePublic])
def get_utenti_by_preferenza(
    id_categoria: int, 
    service: UtenteService = Depends(get_utente_service)
):
    """Recupera tutti gli utenti che hanno una specifica categoria di POI tra le preferenze."""
    return service.get_utenti_by_preferenza(id_categoria)


# @router.get("/{utente_id}/preferenze", response_model=List[CategoriaPOIPublic])
# def get_preferenze_utente(
#     utente_id: int, 
#     service: UtenteService = Depends(get_utente_service)
# ):
#     service.get_utente(utente_id) 
#     return service.get_preferenze_utente(utente_id)