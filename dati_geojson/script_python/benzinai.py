
import os
import numpy as np
import pandas as pd
import geopandas as gpd
from sqlalchemy import create_engine
from geoalchemy2 import Geometry

filename = "../Cesena/benzinaio_Cesena.geojson"

if not os.path.exists(filename):
    print(f"File '{filename}' non trovato!")
    raise FileNotFoundError(filename)

df = gpd.read_file(filename)

if df.crs is None:
    df = df.set_crs("EPSG:4326")
elif df.crs != "EPSG:4326":
    df = df.to_crs("EPSG:4326")

print(f"Caricato: {filename} ({len(df)} POI)")
totale_iniziale = len(df)

colonne_da_controllare = ['name', 'operator', 'addr:street']
for col in colonne_da_controllare:
    if col in df.columns:
        df[col] = df[col].replace(r'^\s*$', np.nan, regex=True)
        df[col] = df[col].replace(['null', 'None', 'N/A', '-'], np.nan)

df['nome'] = df['name']

df = df.dropna(subset=['nome']).copy()

if 'operator' in df.columns:
    df['descrizione'] = "Operatore: " + df['operator'].fillna("Non specificato")
else:
    df['descrizione'] = None


poi = gpd.GeoDataFrame()
poi['nome'] = df['nome']
poi['geometria'] = df['geometry']
poi['id_categoria'] = 9  # Benzinai
poi = poi.set_geometry('geometria', crs="EPSG:4326")
poi['campus'] = "Bologna"
poi['descrizione'] = df['descrizione']

print(poi.head())


DB_URL = "postgresql://postgres:changeme@localhost:5432/ProgettoCAS"
engine = create_engine(DB_URL)

poi_to_db = poi[['nome', 'id_categoria', 'descrizione', 'geometria', 'campus']]

poi_to_db.to_postgis(
    "poi",
    engine,
    if_exists="append",
    index=False,
    dtype={'geometria': Geometry('GEOMETRY', srid=4326)}
)
