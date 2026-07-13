# services/utente_service.py
from typing import List
from fastapi import HTTPException, status
from sqlmodel import Session, select
from models.preferenza_utente import PreferenzaUtente
from models.categooria_poi import CategoriaPOI
from models.utente import Utente, UtenteCreate, UtenteUpdate, MezzoSpostamento, UtentePublic

class UtenteService:
    def __init__(self, session: Session):
        self.session = session


    def create_utente(self, utente_in: UtenteCreate) -> Utente:
        db_utente = Utente.model_validate(utente_in)
        self.session.add(db_utente)
        self.session.commit()
        self.session.refresh(db_utente)
        return db_utente

    def get_utente(self, utente_id: int) -> UtentePublic:
        utente = self.session.get(Utente, utente_id)
        if not utente:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
                detail="Utente non trovato"
            )
        return utente

    def get_all_utenti(self) -> List[UtentePublic]:
        statement = select(Utente)
        risultati = self.session.exec(statement)
        return risultati.all()

    def update_utente(self, utente_id: int, utente_in: UtenteUpdate) -> Utente:
        #print(f"Utente aggiornato: {utente_in}")
        db_utente = self.get_utente(utente_id)
        
        update_data = utente_in.model_dump(exclude_unset=True)
        db_utente.sqlmodel_update(update_data)
        #print(f"Utente aggiornato: {db_utente}")
        self.session.add(db_utente)
        self.session.commit()
        return db_utente

    def delete_utente(self, utente_id: int):
        db_utente = self.get_utente(utente_id)
        self.session.delete(db_utente)
        self.session.commit()
        return {"message": f"Utente {utente_id} eliminato con successo"}

    def get_utenti_by_campus(self, campus: str) -> List[UtentePublic]:
        statement = select(UtentePublic).where(UtentePublic.campus == campus)
        risultati = self.session.exec(statement)
        return risultati.all()

    def get_utenti_by_mezzo(self, mezzo: MezzoSpostamento) -> List[UtentePublic]:
        statement = select(UtentePublic).where(UtentePublic.mezzo_di_spostamento == mezzo.value)
        risultati = self.session.exec(statement)
        return risultati.all()

    def get_utenti_by_preferenza(self, id_categoria: int) -> List[UtentePublic]:
        
        query = (
            select(Utente)
            .join(PreferenzaUtente, Utente.id == PreferenzaUtente.id_utente)
            .where(PreferenzaUtente.id_categoria == id_categoria)
        )
        return self.session.exec(query).all()
    
    # def get_preferenze_utente(self, utente_id: int) -> List[PreferenzaUtente]:
    #     """Recupera tutte le preferenze associate a un utente specifico."""
    #     statement = select(PreferenzaUtente).where(PreferenzaUtente.id_utente == utente_id)
    #     risultati = self.session.exec(statement)
    #     risultati = risultati.join(CategoriaPOI, PreferenzaUtente.id_categoria == CategoriaPOI.id)
    #     return risultati.all()
    
    