import os
import pandas as pd
import geopandas as gpd
from sqlalchemy import create_engine
from geoalchemy2 import Geometry

filename = "../Cesena/noleggio_bici_cesena.geojson"

if not os.path.exists(filename):
    print(f"ATTENZIONE: File '{filename}' non trovato!")
    raise FileNotFoundError(filename)

df = gpd.read_file(filename)

if df.crs is None:
    df = df.set_crs("EPSG:4326")
elif df.crs != "EPSG:4326":
    df = df.to_crs("EPSG:4326")

print(f"Caricato: {filename} ({len(df)} POI)")
totale_iniziale = len(df)

df['nome'] = df['name'].fillna('Stazione Noleggio Bici')

def crea_descrizione_bici(row):
    dettagli = []
    if 'operator' in row and pd.notna(row['operator']):
        dettagli.append(f"Operatore: {row['operator']}")
    if 'capacity' in row and pd.notna(row['capacity']):
        dettagli.append(f"Capacità: {int(float(row['capacity']))} posti")
    if 'fee' in row and pd.notna(row['fee']) and str(row['fee']).lower() != 'no':
        dettagli.append(f"A pagamento: {row['fee']}")

    return " | ".join(dettagli) if dettagli else None

df['descrizione'] = df.apply(crea_descrizione_bici, axis=1)


poi = gpd.GeoDataFrame()
poi['nome'] = df['nome']
poi['geometria'] = df['geometry']
poi['id_categoria'] = 7  # Noleggio Bici
poi = poi.set_geometry('geometria', crs="EPSG:4326")
poi['campus'] = "Cesena"
poi['descrizione'] = df['descrizione']

print(poi.head())

DB_URL = "postgresql://postgres:changeme@localhost:5432/ProgettoCAS"
engine = create_engine(DB_URL)

print("\nInserimento dei POI Noleggio Bici nel Database...")
poi_to_db = poi[['nome', 'id_categoria', 'descrizione', 'geometria', 'campus']]

poi_to_db.to_postgis(
    "poi",
    engine,
    if_exists="append",
    index=False,
    dtype={'geometria': Geometry('GEOMETRY', srid=4326)}
)

