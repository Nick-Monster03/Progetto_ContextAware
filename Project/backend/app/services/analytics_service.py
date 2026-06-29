from sqlmodel import Session
from sqlalchemy import text
from typing import List

from models.evento import FeedbackEvento
from models.analytics import DashboardResponse, StatisticaMezzo, StatisticaFeedback, StatisticaPOI

class AnalyticsService:
    def __init__(self, session: Session):
        self.session = session

    def get_statistiche_mezzi(self) -> List[StatisticaMezzo]:
        query = text("""
            SELECT mezzo_di_spostamento, COUNT(id) as conteggio
            FROM utente
            GROUP BY mezzo_di_spostamento
        """)
        risultati = self.session.exec(query).all()
        
        return [
            StatisticaMezzo(mezzo_di_spostamento=row[0], conteggio=row[1])
            for row in risultati
        ]

    def get_statistiche_feedback(self) -> List[StatisticaFeedback]:
        
        query = text("""
            SELECT feedback, COUNT(id) as conteggio
            FROM evento
            WHERE feedback IS NOT NULL
            GROUP BY feedback
        """)

        risultati = self.session.exec(query).all()
        
        stat_list = []
        for row in risultati:
            valore_db = row[0]  
            conteggio = row[1]
            is_utile = (valore_db == FeedbackEvento.UTILE.value)
            stat_list.append(StatisticaFeedback(is_utile=is_utile, conteggio=conteggio))
        
        return stat_list

    def get_statistiche_poi(self) -> List[StatisticaPOI]:
        query = text("""
            SELECT p.id, p.nome, COUNT(e.id) as totale_eventi
            FROM poi as p
            JOIN evento as e ON e.id_poi = p.id
            GROUP BY p.id, p.nome
            ORDER BY totale_eventi DESC
        """)
        risultati = self.session.exec(query).all()
        
        return [
            StatisticaPOI(id_poi=row[0], nome_poi=row[1], totale_eventi=row[2])
            for row in risultati
        ]

    def get_dashboard_stats(self) -> DashboardResponse:
        """
        Chiama le 3 funzioni di statistica 
        """
        return DashboardResponse(
            statistiche_mezzi=self.get_statistiche_mezzi(),
            statistiche_feedback=self.get_statistiche_feedback(),
            poi_piu_attivi=self.get_statistiche_poi()
        )