import os
import numpy as np
import pandas as pd
import geopandas as gpd
from sqlalchemy import create_engine
from geoalchemy2 import Geometry


filename = "../Cesena/stazione_Cesena.geojson"

if not os.path.exists(filename):
    print(f"ATTENZIONE: File '{filename}' non trovato!")
    raise FileNotFoundError(filename)

df = gpd.read_file(filename)

if df.crs is None:
    df = df.set_crs("EPSG:4326")
elif df.crs != "EPSG:4326":
    df = df.to_crs("EPSG:4326")

totale_iniziale = len(df)


colonne_stazioni = ['name', 'operator', 'operator:short', 'network', 'wheelchair']
for col in colonne_stazioni:
    if col in df.columns:
        df[col] = df[col].replace(r'^\s*$', np.nan, regex=True)
        df[col] = df[col].replace(['null', 'None', 'N/A', '-'], np.nan)

df = df.dropna(subset=['operator', 'operator:short'], how='all').copy()

df['nome'] = df['name'].fillna("Stazione Sconosciuta")

def crea_descrizione_stazioni(row):
    dettagli = []

    op = row.get('operator', np.nan)
    op_short = row.get('operator:short', np.nan)

    operatore_finale = op if pd.notna(op) else op_short
    if pd.notna(operatore_finale):
        dettagli.append(f"Operatore: {operatore_finale}")

    if 'network' in row and pd.notna(row['network']):
        if row['network'] != operatore_finale:
            dettagli.append(f"Rete: {row['network']}")

    if 'wheelchair' in row and pd.notna(row['wheelchair']):
        val_wheelchair = str(row['wheelchair']).lower()
        if val_wheelchair == 'yes':
            dettagli.append("Accessibile in sedia a rotelle")
        elif val_wheelchair == 'no':
            dettagli.append("Non accessibile in sedia a rotelle")

    return " | ".join(dettagli)

df['descrizione'] = df.apply(crea_descrizione_stazioni, axis=1)


poi = gpd.GeoDataFrame()
poi['nome'] = df['nome']
poi['geometria'] = df['geometry']
poi['id_categoria'] = 8  # Stazioni
poi = poi.set_geometry('geometria', crs="EPSG:4326")
poi['campus'] = "Cesena"
poi['descrizione'] = df['descrizione']
print(poi.head())

DB_URL = "postgresql://postgres:changeme@localhost:5432/ProgettoCAS"
engine = create_engine(DB_URL)

print("\nInserimento dei POI Stazioni nel Database...")
poi_to_db = poi[['nome', 'id_categoria', 'descrizione', 'geometria', 'campus']]

poi_to_db.to_postgis(
    "poi",
    engine,
    if_exists="append",
    index=False,
    dtype={'geometria': Geometry('GEOMETRY', srid=4326)}
)
