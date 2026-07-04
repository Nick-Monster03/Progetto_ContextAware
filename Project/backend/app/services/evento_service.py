from sqlmodel import Session
from sqlalchemy import text
from typing import List, Optional
from models.evento import Evento, EventoCreate, EventoUpdate, EventoPublic

class EventoService:
    def __init__(self, session: Session):
        self.session = session

    def create_evento(self, evento_in: EventoCreate) -> EventoPublic:
        evento_data = evento_in.model_dump(exclude={"latitudine", "longitudine"})
        db_evento = Evento(**evento_data)
        db_evento.posizione_utente_reale = f"SRID=4326;POINT({evento_in.longitudine} {evento_in.latitudine})"
        
        self.session.add(db_evento)
        self.session.commit()
        self.session.refresh(db_evento)
        
        return self.get_evento(db_evento.id)

    def get_evento(self, evento_id: int) -> Optional[EventoPublic]:
        query = text("""
            SELECT id, id_utente, id_poi, tipo, messaggio, feedback, motivo, time_stamp,
                   ST_X(posizione_utente_reale) AS longitudine,
                   ST_Y(posizione_utente_reale) AS latitudine
            FROM evento
            WHERE id = :id
        """)
        
        row = self.session.exec(query, params={"id": evento_id}).mappings().first()
        if not row:
            raise ValueError("Evento non trovato")
            
        return EventoPublic(
            id=row["id"],
            id_utente=row["id_utente"],
            id_poi=row["id_poi"],
            tipo=row["tipo"],
            messaggio=row["messaggio"],
            motivo=row["motivo"],
            feedback=row["feedback"],
            time_stamp=row["time_stamp"],
            latitudine=row["latitudine"],
            longitudine=row["longitudine"],
        )

    def get_eventi_by_utente(self, id_utente: int) -> List[EventoPublic]:
        query = text("""
            SELECT id, id_utente, id_poi, tipo, messaggio, feedback, motivo, time_stamp,
                   ST_X(posizione_utente_reale) AS longitudine,
                   ST_Y(posizione_utente_reale) AS latitudine
            FROM evento
            WHERE id_utente = :id_utente
            ORDER BY time_stamp DESC
        """)
        
        results = self.session.exec(query, params={"id_utente": id_utente}).mappings().all()
        
        eventi_pubblici = []
        for row in results:
            eventi_pubblici.append(
                EventoPublic(
                    id=row["id"],
                    id_utente=row["id_utente"],
                    id_poi=row["id_poi"],
                    tipo=row["tipo"],
                    messaggio=row["messaggio"],
                    motivo=row["motivo"],
                    feedback=row["feedback"],
                    time_stamp=row["time_stamp"],
                    latitudine=row["latitudine"],
                    longitudine=row["longitudine"],
                )
            )
        return eventi_pubblici

    def update_evento_feedback(self, evento_id: int, evento_in: EventoUpdate) -> EventoPublic:
        query = text("""
            UPDATE evento 
            SET feedback = COALESCE(:feedback, feedback), 
                motivo = COALESCE(:motivo, motivo)
            WHERE id = :id
        """)
        
        feedback_val = None
        if evento_in.feedback:
            feedback_val = evento_in.feedback.value if hasattr(evento_in.feedback, "value") else evento_in.feedback

        result = self.session.exec(query, params={
            "feedback": feedback_val,
            "motivo": evento_in.motivo,
            "id": evento_id
        })
        self.session.commit()
        
        if hasattr(result, 'rowcount') and result.rowcount == 0:
            raise ValueError("Evento non trovato")
            
        return self.get_evento(evento_id)

    def delete_evento(self, evento_id: int) -> bool:
        query = text("DELETE FROM evento WHERE id = :id")
        result = self.session.exec(query, params={"id": evento_id})
        self.session.commit()
        
        return result.rowcount > 0