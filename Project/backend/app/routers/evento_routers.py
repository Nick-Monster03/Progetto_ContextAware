from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session
from typing import List
from session.database import get_session
from models.evento import EventoCreate, EventoUpdate, EventoPublic
from services.evento_service import EventoService


router = APIRouter(prefix="/eventi", tags=["Eventi"])

@router.post("/", response_model=EventoPublic, status_code=status.HTTP_201_CREATED)
def create_evento(evento_in: EventoCreate, session: Session = Depends(get_session)):
    """
    Crea un nuovo evento contestuale (suggerimento, notifica, ecc.).
    """
    try:
        return EventoService(session=session).create_evento(evento_in=evento_in)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Errore durante la creazione dell'evento: {str(e)}")

@router.get("/getAll", response_model=List[EventoPublic])
def read_all_eventi(session: Session = Depends(get_session)):
    """
    Recupera tutti gli eventi presenti nel database.
    """
    try:
        return EventoService(session=session).get_all_eventi()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@router.get("/{evento_id}", response_model=EventoPublic)
def read_evento(evento_id: int, session: Session = Depends(get_session)):
    """
    Recupera i dettagli di un singolo evento tramite il suo ID.
    """
    try:
        return EventoService(session=session).get_evento(evento_id=evento_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/utente/{id_utente}", response_model=List[EventoPublic])
def read_eventi_utente(
    id_utente: int, 
    session: Session = Depends(get_session)
):
    """
    Recupera lo storico degli eventi per un utente specifico.
    """
    try:
        return EventoService(session=session).get_eventi_by_utente(id_utente=id_utente)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
        


@router.patch("/{evento_id}", response_model=EventoPublic)
def update_evento(evento_id: int, evento_in: EventoUpdate, session: Session = Depends(get_session)):
    """
    Aggiorna un evento esistente (usato principalmente per inviare il feedback Utile/Non Utile).
    """
    try:
        return EventoService(session=session).update_evento_feedback(evento_id=evento_id, evento_in=evento_in)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{evento_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_evento(evento_id: int, session: Session = Depends(get_session)):
    """
    Elimina un evento dallo storico.
    """
    success = EventoService(session=session).delete_evento(evento_id=evento_id)
    if not success:
        raise HTTPException(status_code=404, detail="Evento non trovato")
    return None