from fastapi import APIRouter, Depends
from sqlmodel import Session
from typing import List

from session.database import get_session
from services.analytics_service import AnalyticsService
from models.analytics import DashboardResponse, HeatmapPoint, StatisticaMezzo, StatisticaFeedback, StatisticaPOI

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
    Restituisce il bilancio dei feedback sugli  marchiati come "Suggerimento" (Quanti Utili vs Quanti Non Utili).
    """
    return service.get_statistiche_feedback()

@router.get("/poi", response_model=List[StatisticaPOI])
def get_statistiche_poi(service: AnalyticsService = Depends(get_analytics_service)):
    """
    Restituisce il numero di eventi raggruppati per POI a cui sono stati associati.
    """
    return service.get_statistiche_poi()

@router.get("/dashboard", response_model=DashboardResponse)
def get_dashboard_completa(service: AnalyticsService = Depends(get_analytics_service)):
    """
    Restituisce un oggetto DashboardResponse con i dati aggregati per la dashboard:
    utenti raggruppati per mezzo di spostamento, 
    riepilogo dei feedback ricevuti dai suggerimenti
    e classifica dei POI con piu eventi registrati.
    """
    return service.get_dashboard_stats()

@router.get("/heatmap/pois", response_model=List[HeatmapPoint])
def get_poi_heatmap(id_utente: int | None = None, service: AnalyticsService = Depends(get_analytics_service)):
    """
    Restituisce i centroidi (lat, lon) dei POI coinvolti nei suggerimenti.
    Può essere globale (tutti gli utenti) o mirata al singolo utente se viene passato l'id_utente.
    """
    return service.get_heatmap_poi_suggeriti(id_utente=id_utente)