from sqlmodel import SQLModel, Session, create_engine

DB_USER = "postgres"            
DB_PASSWORD = "changeme"  
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "ProgettoCAS"   

POSTGRES_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

engine = create_engine(POSTGRES_URL, echo=True)

def get_session():
    """
    Questo è il Factory/Generatore della sessione.
    Verrà richiamato tramite la Dependency Injection di FastAPI (Depends)
    all'inizio di ogni richiesta nelle tue repository o nei tuoi endpoint.
    Garantisce che la connessione si chiuda automaticamente alla fine.
    """
    with Session(engine) as session:
        yield session