from typing import List
from sqlmodel import Session, select
from fastapi import HTTPException, status

from models.preferenza_utente import PreferenzaUtente, PreferenzaUtenteCreate

class PreferenzaService:

    def __init__(self, session: Session):
        self.session = session

    def get_categorie_by_utente(self, id_utente: int) -> List[PreferenzaUtente]:
        """
        Restituisce tutte le preferenze di un dato utente.
        """
        statement = select(PreferenzaUtente).where(PreferenzaUtente.id_utente == id_utente)
        risultati = self.session.exec(statement).all()
        return risultati

    
    def get_utenti_by_categoria(self, id_categoria: int) -> List[PreferenzaUtente]:
        """
        Restituisce tutti gli utenti che hanno una preferenza per una data categoria.
        """
        statement = select(PreferenzaUtente).where(PreferenzaUtente.id_categoria == id_categoria)
        risultati = self.session.exec(statement).all()
        return risultati

    
    def create_preferenza(self, preferenza_in: PreferenzaUtenteCreate) -> PreferenzaUtente:
        """
        Crea una nuova preferenza utente-categoria.
        Controlla prima che non esista già per evitare errori di Primary Key duplicata,
        anche se l'azione verrebbe bloccata dalla base di dati.
        """
        statement = select(PreferenzaUtente).where(
            PreferenzaUtente.id_utente == preferenza_in.id_utente,
            PreferenzaUtente.id_categoria == preferenza_in.id_categoria
        )
        preferenza_esistente = self.session.exec(statement).first()
        
        if preferenza_esistente:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Questa preferenza esiste già per l'utente e la categoria specificati."
            )

        db_preferenza = PreferenzaUtente(
            id_utente=preferenza_in.id_utente,
            id_categoria=preferenza_in.id_categoria
        )
        
        self.session.add(db_preferenza)
        self.session.commit()
        return db_preferenza

    def delete_preferenza(self, id_utente: int, id_categoria: int) -> bool:
        """
        Elimina un'associazione utente-categoria.
        """
        statement = select(PreferenzaUtente).where(
            PreferenzaUtente.id_utente == id_utente,
            PreferenzaUtente.id_categoria == id_categoria
        )
        db_preferenza = self.session.exec(statement).first()
        
        if not db_preferenza:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Preferenza non trovata."
            )
            
        self.session.delete(db_preferenza)
        self.session.commit()
        return True