from fastapi import FastAPI, Depends, HTTPException
from sqlmodel import Session, select

# IMPORT AGGIORNATO: indica a FastAPI di cercare dentro la cartella session
from session.database import get_session

# Importiamo il modello Utente dal file utente.py dentro la cartella models
from models.utente import Utente, MezzoSpostamento

app = FastAPI(
    title="Context-Aware Campus Assistant",
    description="API di backend per il sistema Campus Assistant con supporto PostGIS",
    version="1.0.0"
)

@app.get("/")
def home():
    """
    Endpoint di rotto per verificare che FastAPI sia attivo.
    """
    return {
        "status": "online",
        "project": "Context-Aware Campus Assistant",
        "messaggio": "Usa la rotta /docs per vedere la documentazione interattiva Swagger!"
    }

@app.get("/test-db")
def test_database_connection(session: Session = Depends(get_session)):
    """
    Endpoint di test per verificare la connessione al database PostGIS.
    Prova a fare una query di SELECT sulla tabella 'utente'.
    """
    try:
        statement = select(Utente)
        primo_utente = session.exec(statement).first()
        
        return {
            "status": "success",
            "database": "Connesso correttamente!",
            "messaggio": "La sessione Factory dentro la cartella session funziona alla perfezione.",
            "dati_test": primo_utente if primo_utente else "Nessun utente presente nel DB, ma la tabella esiste!"
        }
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Errore critico di connessione al Database: {str(e)}"
        )

