
import os
import numpy as np
import pandas as pd
import geopandas as gpd
from sqlalchemy import create_engine
from geoalchemy2 import Geometry

filename = "../Cesena/bus_stop_Cesena.geojson"

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

colonne_bus = ['name', 'ref', 'operator', 'network', 'route_ref', 'shelter', 'wheelchair']
for col in colonne_bus:
    if col in df.columns:
        df[col] = df[col].replace(r'^\s*$', np.nan, regex=True)
        df[col] = df[col].replace(['null', 'None', 'N/A', '-'], np.nan)

df = df.dropna(subset=['operator']).copy()

df['nome'] = df['name'].fillna("Fermata Anonima")
df['nome'] = df['nome'].fillna("Fermata " + df['ref'].fillna("Senza Nome"))

def crea_descrizione_bus(row):
    dettagli = []

    if 'network' in row and pd.notna(row['network']):
        if row['network'] != row['operator']:
            dettagli.append(f"Rete: {row['network']}")

    dettagli.append(f"Operatore: {row['operator']}")

    if 'route_ref' in row and pd.notna(row['route_ref']):
        dettagli.append(f"Linee: {row['route_ref']}")

    if 'shelter' in row and pd.notna(row['shelter']) and str(row['shelter']).lower() == 'yes':
        dettagli.append("Con pensilina")

    return " | ".join(dettagli)

df['descrizione'] = df.apply(crea_descrizione_bus, axis=1)

print(f"Pulizia completata! Fermate bus valide: {len(df)} su {totale_iniziale}")


poi = gpd.GeoDataFrame()
poi['nome'] = df['nome']
poi['geometria'] = df['geometry']
poi['id_categoria'] = 6  # Fermate Bus
poi = poi.set_geometry('geometria', crs="EPSG:4326")
poi['campus'] = "Cesena"
poi['descrizione'] = df['descrizione']

print(poi.head())


DB_URL = "postgresql://postgres:changeme@localhost:5432/ProgettoCAS"
engine = create_engine(DB_URL)

print("\nInserimento dei POI Fermate Bus nel Database...")
poi_to_db = poi[['nome', 'id_categoria', 'descrizione', 'geometria', 'campus']]

poi_to_db.to_postgis(
    "poi",
    engine,
    if_exists="append",
    index=False,
    dtype={'geometria': Geometry('GEOMETRY', srid=4326)}
)
