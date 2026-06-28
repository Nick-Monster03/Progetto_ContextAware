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
    return service.create_utente(utente_in)

@router.get("/{utente_id}", response_model=UtentePublic)
def get_utente(
    utente_id: int, 
    service: UtenteService = Depends(get_utente_service)
):
    return service.get_utente(utente_id)

@router.patch("/{utente_id}", response_model=UtentePublic)
def update_utente(
    utente_id: int, 
    utente_in: UtenteUpdate, 
    service: UtenteService = Depends(get_utente_service)
):
    return service.update_utente(utente_id, utente_in)

@router.delete("/{utente_id}", status_code=status.HTTP_200_OK)
def delete_utente(
    utente_id: int, 
    service: UtenteService = Depends(get_utente_service)
):
    return service.delete_utente(utente_id)


@router.get("/campus/{campus}", response_model=List[UtentePublic])
def get_utenti_by_campus(
    campus: str, 
    service: UtenteService = Depends(get_utente_service)
):
    return service.get_utenti_by_campus(campus)

@router.get("/mezzo/{mezzo}", response_model=List[UtentePublic])
def get_utenti_by_mezzo(
    mezzo: MezzoSpostamento, 
    service: UtenteService = Depends(get_utente_service)
):
    return service.get_utenti_by_mezzo(mezzo)

@router.get("/preferenza/{id_categoria}", response_model=List[UtentePublic])
def get_utenti_by_preferenza(
    id_categoria: int, 
    service: UtenteService = Depends(get_utente_service)
):
    return service.get_utenti_by_preferenza(id_categoria)


# @router.get("/{utente_id}/preferenze", response_model=List[CategoriaPOIPublic])
# def get_preferenze_utente(
#     utente_id: int, 
#     service: UtenteService = Depends(get_utente_service)
# ):
#     service.get_utente(utente_id) 
#     return service.get_preferenze_utente(utente_id)