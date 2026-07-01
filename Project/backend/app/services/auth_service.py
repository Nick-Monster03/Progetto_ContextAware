from fastapi import HTTPException, status
from sqlmodel import Session, select
from models.utente import Utente, UtenteCreate

class AuthService:
    def __init__(self, session: Session):
        self.session = session

    def register(self, utente_in: UtenteCreate) -> Utente:
        """Registra un nuovo utente verificando l'univocità di nome+cognome+password"""
        
        statement = select(Utente).where(
            Utente.nome == utente_in.nome,
            Utente.cognome == utente_in.cognome,
            Utente.password == utente_in.password
        )
        esistente = self.session.exec(statement).first()
        
        if esistente:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Un utente con questo nome, cognome e password esiste già."
            )
        
        db_utente = Utente.model_validate(utente_in)
        self.session.add(db_utente)
        self.session.commit()
        
        return db_utente

    def login(self, nome: str, cognome: str, password: str) -> Utente:
        """Effettua il login verificando i 3 campi"""
        statement = select(Utente).where(
            Utente.nome == nome,
            Utente.cognome == cognome,
            Utente.password == password
        )
        utente = self.session.exec(statement).first()
        
        if not utente:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Credenziali non valide."
            )
            
        return utente