from fastapi import FastAPI, Depends, HTTPException 
from sqlmodel import Session, select 
from models.utente import Utente
from session.database import get_session
from routers import utente_routers, poi_routers, categoria_routers, evento_routers, preferenza_routers, orari_routers, agenda_utente_routers, raccomandation_routers, geofence_routers, analytics_routers, auth_routers
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Context-Aware Campus Assistant",
    description="API di backend per il sistema Campus Assistant con supporto PostGIS",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5500",
        "http://127.0.0.1:5500"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
) #FONTE:https://stackoverflow.com/questions/79415742/my-fastapi-service-is-giving-cors-errors-from-my-website-running-on-localhost-wh

#Tutte le route per ogni Tabella del DB
app.include_router(utente_routers.router)
app.include_router(poi_routers.router)
app.include_router(categoria_routers.router)
app.include_router(evento_routers.router)  
app.include_router(preferenza_routers.router)  
app.include_router(orari_routers.router)
app.include_router(agenda_utente_routers.router) 
app.include_router(raccomandation_routers.router) 
app.include_router(geofence_routers.router)
app.include_router(analytics_routers.router)
app.include_router(auth_routers.router)  


@app.get("/")
def home():
    """
    Endpoint di root per verificare che FastAPI sia attivo.
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