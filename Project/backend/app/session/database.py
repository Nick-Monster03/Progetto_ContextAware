import os

from sqlmodel import SQLModel, Session, create_engine

DB_USER = "postgres"            
DB_PASSWORD = "changeme"  
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "ProgettoCAS"   

FALLBACK_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@localhost:{DB_PORT}/{DB_NAME}"

# os.getenv cerca la variabile di Docker. Se non c'è, usa il fallback locale.
POSTGRES_URL = os.getenv("DATABASE_URL", FALLBACK_URL)

engine = create_engine(POSTGRES_URL, echo=True)

def get_session():
    """.
    Questo è il Factory/Generatore per connettersi al database, senza bisogno di codice ripetuto
    """
    with Session(engine) as session:
        yield session