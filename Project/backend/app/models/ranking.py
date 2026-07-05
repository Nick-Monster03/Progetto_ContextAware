from pydantic import BaseModel
from models.poi import POIPublic

class RankingResult(BaseModel):
    poi: POIPublic
    punteggio: float