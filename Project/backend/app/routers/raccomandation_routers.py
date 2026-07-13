from typing import List
from fastapi import APIRouter, Depends, Query
from sqlmodel import Session
from pydantic import BaseModel

from models.evento import EventoPublic
from session.database import get_session
from services.poi_service import PoiService
from services.raccomandation_service import RaccomandationService
from models.poi import POIDistance
from models.ranking import RankingResult

router = APIRouter(prefix="/recommendations", tags=["Raccomandazioni"])


def get_poi_service(session: Session = Depends(get_session)) -> PoiService:
    return PoiService(session)

def get_recommendation_service(session: Session = Depends(get_session),
    poi_service: PoiService = Depends(get_poi_service)) -> RaccomandationService:
    return RaccomandationService(session, poi_service)


@router.get("/ranking", response_model=List[RankingResult])
def get_ranking(id_utente: int, lat: float, lon: float, service: RaccomandationService = Depends(get_recommendation_service)):
    """
    Calcola il ranking contestuale per i POI vicini in base a distanza, 
    orari di apertura, preferenze e mezzo di spostamento dell'utente.
    """
    return service.calculate_ranking(id_utente=id_utente, lat=lat, lon=lon)

@router.post("/startup-suggestion", response_model=EventoPublic | dict)
def trigger_startup_suggestion(id_utente: int, lat: float, lon: float, service: RaccomandationService = Depends(get_recommendation_service)):
    """
    Genera il suggerimento iniziale per l'app: calcola il ranking,
    prende il POI migliore e salva un evento di tipo SUGGERIMENTO nel DB.
    """
    return service.generate_startup_suggestion(id_utente=id_utente, lat=lat, lon=lon)

@router.get("/top_20_ranking", response_model=List[RankingResult])
def get_servizi_ordinati(id_utente: int, lat: float, lon: float, service: RaccomandationService = Depends(get_recommendation_service)):
    """
    Restituisce i primi 20 servizi vicini ordinati per rilevanza.
    """
    risultati = service.get_ranking_list(id_utente, lat, lon)
    return risultati