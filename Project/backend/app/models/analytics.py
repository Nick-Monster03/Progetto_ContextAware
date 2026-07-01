from pydantic import BaseModel
from typing import List, Optional

class StatisticaMezzo(BaseModel):
    mezzo_di_spostamento: str
    conteggio: int

class StatisticaFeedback(BaseModel):
    is_utile: bool
    conteggio: int

class HeatmapPoint(BaseModel):
    lat: float
    lon: float

class StatisticaPOI(BaseModel):
    id_poi: int
    nome_poi: str
    totale_eventi: int

class DashboardResponse(BaseModel):
    statistiche_mezzi: List[StatisticaMezzo]
    statistiche_feedback: List[StatisticaFeedback]
    poi_piu_attivi: List[StatisticaPOI]