from typing import List
from fastapi import APIRouter, Depends, status
from sqlmodel import Session
from session.database import get_session
from services.poi_service import PoiService
from models.poi import POI, POIPublic, POIUpdate, POICreate
from models.categooria_poi import CategoriaPOIPublic, CategoriaPOI, CategoriaPOICreate, CategoriaPOIUpdate
from models.orari_poi import Orari_PoiPublic, Orari_PoiPublic, Orari_PoiPublic, Orari_Poi, Orari_PoiCreate, Orari_PoiUpdate

router = APIRouter(prefix="/poi", tags=["POI"])

def get_poi_service(session: Session = Depends(get_session)) -> PoiService:
    return PoiService(session)

@router.post("/", response_model=POIPublic, status_code=status.HTTP_201_CREATED)
def create_poi(poi: POICreate, service: PoiService = Depends(get_poi_service)):
    """Crea un nuovo POI nel database."""
    return service.create_poi(poi)

@router.get("/", response_model=List[POIPublic])
def get_all_pois(service: PoiService = Depends(get_poi_service)):
    """Restituisce la lista di tutti i POI."""
    return service.get_all_poi()

@router.get("/nearby", response_model=List[POIPublic])
def get_pois_nearby(
    lat: float, 
    lon: float, 
    radius: float = 2000.0, 
    service: PoiService = Depends(get_poi_service)
):
    """Cerca POI vicino a una determinata posizione basata su Lat/Lon."""
    return service.get_pois_nearby(lat=lat, lon=lon, radius_meters=radius)

@router.get("/{poi_id}", response_model=POIPublic)
def get_poi_by_id(poi_id: int, service: PoiService = Depends(get_poi_service)):
    """Recupera un singolo POI tramite il suo ID."""
    return service.get_poi_by_id(poi_id)

@router.get("/categoria/{id_categoria}", response_model=List[POIPublic])
def get_pois_by_categoria(id_categoria: int, service: PoiService = Depends(get_poi_service)):
    """Filtra i POI in base alla loro categoria."""
    return service.get_poi_by_categoria(id_categoria)

@router.get("/{poi_id}/orari", response_model=List[Orari_PoiPublic])
def get_orari_poi(poi_id: int, service: PoiService = Depends(get_poi_service)):
    """Recupera tutti gli orari di apertura per uno specifico POI."""
    return service.get_orari_poi(poi_id)

@router.get("/{poi_id}/is-open", response_model=bool)
def check_poi_is_open(poi_id: int, service: PoiService = Depends(get_poi_service)):
    """Ritorna true/false a seconda se il POI è attualmente aperto."""
    return service.is_open(poi_id)
