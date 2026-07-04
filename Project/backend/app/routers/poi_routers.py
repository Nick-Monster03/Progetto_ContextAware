from datetime import datetime, time
from typing import List
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlmodel import Session
from session.database import get_session
from services.poi_service import PoiService
from models.poi import POI, POIPublic, POIUpdate, POICreate, POIDistance
from models.categooria_poi import CategoriaPOIPublic, CategoriaPOI, CategoriaPOICreate, CategoriaPOIUpdate
from models.orari_poi import Orari_PoiPublic, Orari_PoiPublic, Orari_PoiPublic, Orari_Poi, Orari_PoiCreate, Orari_PoiUpdate

router = APIRouter(prefix="/poi", tags=["POI"])

def get_poi_service(session: Session = Depends(get_session)) -> PoiService:
    return PoiService(session)

def parse_orario(orario_str: str | None) -> time | None:
        """Prende una stringa orario (es. '8:00' o '19:30'), aggiunge lo zero se manca e la converte in time."""
        
        if not orario_str:
            return None
        
        parti = orario_str.split(":")
        if len(parti[0]) == 1:
            parti[0] = f"0{parti[0]}"
        orario_corretto = ":".join(parti)
        
        try:
            if len(parti) == 2:
                return datetime.strptime(orario_corretto, "%H:%M").time()
            else:
                return datetime.strptime(orario_corretto, "%H:%M:%S").time()
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=f"Formato orario non valido: {orario_str}. Usa il formato HH:MM (es. 8:00 o 08:00)."
            )
    

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

@router.get("/nearby-with-distance", response_model=List[POIDistance])
def get_pois_nearby_with_distance(
    lat: float, lon: float, radius: float = 2000.0, service: PoiService = Depends(get_poi_service)):
    """
    Recupera tutti i POI entro il raggio specificato, calcolando 
    la distanza esatta in metri per ciascuno di essi.
    """
    return service.get_pois_nearby_with_distance(lat=lat, lon=lon, radius_meters=radius)

@router.get("/search", response_model=List[POIPublic])
def search_pois(
    query: str, 
    campus: str | None = Query(default=None),
    service: PoiService = Depends(get_poi_service)
):
    """
    Ricerca POI per nome. Se viene passato il campus, i risultati sono contestualizzati.
    """
    return service.search_pois_by_name(query=query, campus=campus)

@router.get("/filter", response_model=List[POIPublic])
def get_filtered_pois(
    lat: float | None = Query(default=None),
    lon: float | None = Query(default=None),
    id_categoria: List[int] | None = Query(default=None),
    max_distance_meters: float | None = Query(default=None),
    orario_apertura: str | None = Query(default=None),
    orario_chiusura: str | None = Query(default=None),
    #mezzo_spostamento: str | None = Query(default=None),
    campus: str | None = Query(default=None),
    service: PoiService = Depends(get_poi_service)
):
    """
    Endpoint per il filtraggio avanzato e combinato dei Punti di Interesse.
    Tutti i parametri sono opzionali e possono essere combinati.
    """
    orario_apertura = parse_orario(orario_apertura)
    orario_chiusura = parse_orario(orario_chiusura)
    return service.get_filtered_pois(
        lat=lat,
        lon=lon,
        id_categoria=id_categoria,
        max_distance_meters=max_distance_meters,
        orario_apertura=orario_apertura,
        orario_chiusura=orario_chiusura,
        #mezzo_spostamento=mezzo_spostamento,
        campus=campus
    )

@router.get("/{poi_id}", response_model=POIPublic)
def get_poi_by_id(poi_id: int, service: PoiService = Depends(get_poi_service)):
    """Recupera un singolo POI tramite il suo ID."""
    return service.get_poi_by_id(poi_id)

@router.patch("/{poi_id}", response_model=POIPublic)
def update_poi(poi_id: int, poi_in: POIUpdate, service: PoiService = Depends(get_poi_service)):
    return service.update_poi(poi_id, poi_in)

@router.delete("/{poi_id}", response_model=POIPublic)
def delete_poi(poi_id: int, service: PoiService = Depends(get_poi_service)):
    db_poi = service.delete_poi(poi_id)
    return db_poi

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


