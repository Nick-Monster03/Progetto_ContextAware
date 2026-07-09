from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session
from typing import Any, Dict, List

from session.database import get_session
from models.agenda_utente import AgendaUtenteCreate, AgendaUtenteUpdate, AgendaUtentePublic, AgendaUtenteContext
from services.agenda_utente_service import AgendaService

router = APIRouter(prefix="/agenda", tags=["Agenda Utente"])

def get_agenda_service(session: Session = Depends(get_session)) -> AgendaService:
    return AgendaService(session=session)

@router.post("/", response_model=AgendaUtentePublic, status_code=status.HTTP_201_CREATED)
def create_impegno(impegno_in: AgendaUtenteCreate, service: AgendaService = Depends(get_agenda_service)):
    """
    Aggiunge una lezione o un evento all'agenda personale dello studente.
    """
    try:
        return service.create_impegno(impegno_in=impegno_in)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    
@router.get("/imminenti", response_model=List[AgendaUtenteContext])
def get_impegni_imminenti(id_utente: int, lat: float, lon: float, service: AgendaService = Depends(get_agenda_service)):
    """
    Restituisce gli impegni che iniziano entro i prossimi 15 minuti.
    Fornisce la distanza esatta in metri e un avviso contestuale.
    """
    return service.get_impegni_critici(id_utente=id_utente, lat=lat, lon=lon)

@router.get("/utente/{id_utente}", response_model=List[AgendaUtentePublic])
def read_agenda_utente(id_utente: int, solo_futuri: bool =False, service: AgendaService = Depends(get_agenda_service)):
    """
    Recupera tutti gli impegni in agenda per uno studente specifico, ordinati cronologicamente.
    Può filtrare solo gli eventi futuri usando il parametro query ?solo_futuri=true
    """
    return service.get_agenda_by_utente(id_utente=id_utente, solo_futuri=solo_futuri)



@router.get("/{impegno_id}", response_model=AgendaUtentePublic)
def read_impegno(impegno_id: int, service: AgendaService = Depends(get_agenda_service)):
    """
    Mostra i dettagli di un singolo appuntamento dell'agenda.
    """
    try:
        return service.get_impegno(impegno_id=impegno_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

@router.patch("/{impegno_id}", response_model=AgendaUtentePublic)
def update_impegno(impegno_id: int, impegno_in: AgendaUtenteUpdate, service: AgendaService = Depends(get_agenda_service)):
    """
    Aggiorna un impegno. Se si desidera cambiare giorno, basta inviare i nuovi orari 
    con la componente 'data' aggiornata (es: "2026-06-29T09:00:00Z").
    """
    try:
        return service.update_impegno(impegno_id=impegno_id, impegno_in=impegno_in)
    except ValueError as e:
        if "non trovato" in str(e).lower():
            raise HTTPException(status_code=404, detail=str(e))
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{impegno_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_impegno(impegno_id: int, service: AgendaService = Depends(get_agenda_service)):
    """
    Rimuove un impegno dall'agenda.
    """
    try:
        service.delete_impegno(impegno_id=impegno_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    return None

