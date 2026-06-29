from fastapi import APIRouter, Depends
from sqlmodel import Session
from typing import List

from session.database import get_session
from services.analytics_service import AnalyticsService
from models.analytics import DashboardResponse, StatisticaMezzo, StatisticaFeedback, StatisticaPOI

router = APIRouter(prefix="/analytics", tags=["Statistiche Dashboard"])

def get_analytics_service(session: Session = Depends(get_session)) -> AnalyticsService:
    return AnalyticsService(session)

@router.get("/mezzi", response_model=List[StatisticaMezzo])
def get_statistiche_mezzi(service: AnalyticsService = Depends(get_analytics_service)):
    """
    Restituisce il conteggio degli utenti raggruppati per mezzo di spostamento preferito.
    """
    return service.get_statistiche_mezzi()

@router.get("/feedback", response_model=List[StatisticaFeedback])
def get_statistiche_feedback(service: AnalyticsService = Depends(get_analytics_service)):
    """
    Restituisce il bilancio dei feedback sugli eventi (Quanti Utili vs Quanti Non Utili).
    """
    return service.get_statistiche_feedback()

@router.get("/poi", response_model=List[StatisticaPOI])
def get_statistiche_poi(service: AnalyticsService = Depends(get_analytics_service)):
    """
    Restituisce i POI che hanno generato il maggior numero di eventi/suggerimenti.
    """
    return service.get_statistiche_poi()

@router.get("/dashboard", response_model=DashboardResponse)
def get_dashboard_completa(service: AnalyticsService = Depends(get_analytics_service)):
    """
    Recupera tutte le statistiche in un'unica chiamata. 
    Ideale per il primo caricamento della pagina della Dashboard Web.
    """
    return service.get_dashboard_stats()