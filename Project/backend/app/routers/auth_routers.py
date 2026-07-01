from fastapi import APIRouter, Depends
from sqlmodel import Session
from models.auth_model import LoginRequest
from models.utente import UtentePublic, UtenteCreate
from services.auth_service import AuthService
from session.database import get_session 

router = APIRouter(prefix="/auth", tags=["Autenticazione"])


@router.post("/register", response_model=UtentePublic, status_code=201)
def register_utente(utente_in: UtenteCreate, session: Session = Depends(get_session)):
    """API per registrare un nuovo utente"""
    auth_service = AuthService(session)
    return auth_service.register(utente_in)

@router.post("/login", response_model=UtentePublic)
def login_utente(credentials: LoginRequest, session: Session = Depends(get_session)):
    """API per effettuare il login"""
    auth_service = AuthService(session)
    return auth_service.login(
        nome=credentials.nome, 
        cognome=credentials.cognome, 
        password=credentials.password
    )