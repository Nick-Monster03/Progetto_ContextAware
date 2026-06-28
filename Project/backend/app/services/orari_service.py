from sqlmodel import Session, select
from typing import List, Optional
from models.orari_poi import Orari_Poi, Orari_PoiCreate, Orari_PoiUpdate, Orari_PoiPublic

class OrariPoiService:
    def __init__(self, session: Session):
        self.session = session

    def create_orario(self, orario_in: Orari_PoiCreate) -> Orari_Poi:
        if orario_in.orario_chiusura <= orario_in.orario_apertura:
            raise ValueError("L'orario di chiusura deve essere successivo all'orario di apertura.")

        statement = select(Orari_Poi).where(
            Orari_Poi.id_poi == orario_in.id_poi,
            Orari_Poi.giorno == orario_in.giorno,
            Orari_Poi.orario_apertura == orario_in.orario_apertura,
            Orari_Poi.orario_chiusura == orario_in.orario_chiusura
        )
        if self.session.exec(statement).first():
            raise ValueError("Questo orario esiste già per il POI e il giorno specificati.")

        db_orario = Orari_Poi.model_validate(orario_in)
        self.session.add(db_orario)
        self.session.commit()
        
        return db_orario

    def get_orario(self, orario_id: int) -> Orari_Poi:
        orario = self.session.get(Orari_Poi, orario_id)
        if not orario:
            raise ValueError("Orario non trovato")
        return orario

    def get_orari_by_poi(self, id_poi: int) -> List[Orari_Poi]:
        """Recupera tutti gli orari di un POI ordinati per giorno e orario di apertura"""
        statement = select(Orari_Poi).where(Orari_Poi.id_poi == id_poi).order_by(Orari_Poi.giorno, Orari_Poi.orario_apertura)
        return self.session.exec(statement).all()

    def update_orario(self, orario_id: int, orario_in: Orari_PoiUpdate) -> Orari_Poi:
        db_orario = self.get_orario(orario_id)
        orario_data = orario_in.model_dump(exclude_unset=True)
        
        new_apertura = orario_data.get("orario_apertura", db_orario.orario_apertura)
        new_chiusura = orario_data.get("orario_chiusura", db_orario.orario_chiusura)
        
        if new_chiusura <= new_apertura:
            raise ValueError("L'orario di chiusura deve essere successivo all'orario di apertura.")

        db_orario.sqlmodel_update(orario_data)

        self.session.add(db_orario)
        self.session.commit()
        
        return db_orario

    def delete_orario(self, orario_id: int) -> bool:
        db_orario = self.get_orario(orario_id)
        self.session.delete(db_orario)
        self.session.commit()
        return True