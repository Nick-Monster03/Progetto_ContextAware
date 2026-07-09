from datetime import datetime, timedelta, timezone

from sqlmodel import Session, select, text
from typing import Any, Dict, List
from fastapi import HTTPException, status
from models.poi import POI
from models.agenda_utente import AgendaUtente, AgendaUtenteCreate, AgendaUtenteUpdate, AgendaUtentePublic, AgendaUtenteContext

class AgendaService:
    def __init__(self, session: Session):
        self.session = session

    def _check_overlap(self, id_utente: int, inizio: datetime, fine: datetime, exclude_id: int | None = None) -> bool:
        """
        Ritorna True se l'utente ha già un impegno che si sovrappone con le date fornite.
        Formula di overlap: inizio_nuovo < fine_esistente AND fine_nuovo > inizio_esistente
        """
        statement = select(AgendaUtente).where(
            AgendaUtente.id_utente == id_utente,
            AgendaUtente.orario_inizio <= fine,
            AgendaUtente.orario_fine >= inizio
        )

        if exclude_id:
            statement = statement.where(AgendaUtente.id != exclude_id)
            
        return self.session.exec(statement).first() is not None

    def create_impegno(self, impegno_in: AgendaUtenteCreate) -> AgendaUtente:
        if impegno_in.orario_fine <= impegno_in.orario_inizio: 
            raise ValueError("L'orario di fine deve essere successivo all'orario di inizio.")

        if self._check_overlap(impegno_in.id_utente, impegno_in.orario_inizio, impegno_in.orario_fine):
            raise ValueError("L'utente ha già un impegno programmato in questo intervallo orario.")

        db_impegno = AgendaUtente.model_validate(impegno_in)
        #DEBUG
        #print(db_impegno.model_dump())
        self.session.add(db_impegno)
        self.session.commit()
        return db_impegno

    def get_impegno(self, impegno_id: int) -> AgendaUtentePublic:
        impegno = self.session.get(AgendaUtente, impegno_id)
        if not impegno:
            raise ValueError("Impegno in agenda non trovato.")
        return impegno

    def get_agenda_by_utente(self, id_utente: int, solo_futuri: bool = False) -> List[AgendaUtentePublic]:
        """
        Recupera l'agenda di uno studente. Se solo_futuri=True, filtra gli eventi passati.
        """
        statement = select(AgendaUtente).where(AgendaUtente.id_utente == id_utente)
        
        if solo_futuri:
            ora_corrente = datetime.now(timezone.utc)
            statement = statement.where(AgendaUtente.orario_inizio >= ora_corrente)
            
        statement = statement.order_by(AgendaUtente.orario_inizio)
        return self.session.exec(statement).all()

    def update_impegno(self, impegno_id: int, impegno_in: AgendaUtenteUpdate) -> AgendaUtentePublic:
        db_impegno = self.get_impegno(impegno_id)
        impegno_data = impegno_in.model_dump(exclude_unset=True)

        nuovo_inizio = impegno_data.get("orario_inizio", db_impegno.orario_inizio)
        nuovo_fine = impegno_data.get("orario_fine", db_impegno.orario_fine)
        id_utente = db_impegno.id_utente 

        if nuovo_fine <= nuovo_inizio:
            raise ValueError("L'orario di fine deve essere successivo all'orario di inizio.")

        if self._check_overlap(id_utente, nuovo_inizio, nuovo_fine, exclude_id=impegno_id):
            raise ValueError("L'aggiornamento fallito: si sovrappone a un altro impegno esistente.")

        db_impegno.sqlmodel_update(impegno_data)

        self.session.add(db_impegno)
        self.session.commit()
        return db_impegno

    def delete_impegno(self, impegno_id: int) -> AgendaUtentePublic:
        db_impegno = self.get_impegno(impegno_id)
        self.session.delete(db_impegno)
        self.session.commit()
        return db_impegno
    
    def get_impegni_critici(self, id_utente: int, lat: float, lon: float) -> List[AgendaUtenteContext]:
        """
        Restituisce gli impegni che iniziano entro i prossimi 15 minuti.
        Per ogni impegno calcola la distanza e genera un avviso contestuale.
        """
        ora_corrente = datetime.now(timezone.utc)
        tra_15_minuti = ora_corrente + timedelta(minutes=15)
        
        statement = select(AgendaUtente).where(
            AgendaUtente.id_utente == id_utente,
            AgendaUtente.orario_inizio >= ora_corrente,
            AgendaUtente.orario_inizio <= tra_15_minuti
        )
        impegni = self.session.exec(statement).all()
        
        risultati = []
        for imp in impegni:
            poi = self.session.get(POI, imp.id_poi)
            
            query_dist = text("""
                SELECT ST_Distance(
                    ST_Transform(ST_SetSRID(ST_MakePoint(:lon, :lat), 4326), 32632),
                    ST_Transform(geometria, 32632)
                )
                FROM poi
                WHERE id = :id_poi
            """)

            distanza = self.session.exec(query_dist, params={"lon": lon, "lat": lat, "id_poi": poi.id}).scalar() 
            distanza_metri = round(distanza, 2) if distanza else 0.0
            
            avviso = f"L'evento '{imp.titolo}' inizia tra poco! Sei a {distanza_metri} metri di distanza."
            
            impegno_data = imp.model_dump()
            
            risultato_obj = AgendaUtenteContext(
                **impegno_data,
                distanza_metri=distanza_metri,
                avviso=avviso
            )
            risultati.append(risultato_obj)
                
        return risultati