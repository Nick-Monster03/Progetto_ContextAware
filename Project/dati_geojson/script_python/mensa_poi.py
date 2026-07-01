import os
import re
import numpy as np
import pandas as pd
import geopandas as gpd
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError
from geoalchemy2 import Geometry

filename = "../Cesena/mensa_Cesena.geojson"

if not os.path.exists(filename):
    print(f"ATTENZIONE: File '{filename}' non trovato!")
    raise FileNotFoundError(filename)

df = gpd.read_file(filename)
#df = df.dropna(subset=['name'])

if df.crs is None:
    df = df.set_crs("EPSG:4326")
elif df.crs != "EPSG:4326":
    df = df.to_crs("EPSG:4326")

print(f"Caricato: {filename} ({len(df)} POI)")
totale_iniziale = len(df)

colonne_da_pulire = ['name', 'cuisine']
for col in colonne_da_pulire:
    if col in df.columns:
        df[col] = df[col].replace(r'^\s*$', np.nan, regex=True)
        df[col] = df[col].replace(['null', 'None', 'N/A', '-'], np.nan)
        df = df.dropna(subset=[col])

def crea_descrizione_mense(row):
    dettagli = [f"Cucina: {row['cuisine']}"]

    if 'diet:vegan' in row and pd.notna(row['diet:vegan']) and str(row['diet:vegan']).lower() == 'yes':
        dettagli.append("Opzioni vegane")
    if 'diet:gluten_free' in row and pd.notna(row['diet:gluten_free']) and str(row['diet:gluten_free']).lower() == 'yes':
        dettagli.append("Senza glutine")
    if 'takeaway' in row and pd.notna(row['takeaway']) and str(row['takeaway']).lower() == 'yes':
        dettagli.append("Takeaway")

    return " | ".join(dettagli)

df['descrizione'] = df.apply(crea_descrizione_mense, axis=1)

poi = gpd.GeoDataFrame()
poi['nome'] = df['name']
poi['geometria'] = df['geometry']
poi['id_categoria'] = 3  # Mense
poi = poi.set_geometry('geometria', crs="EPSG:4326")
poi['campus'] = "Cesena"
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

"""
def parse_osm_hours(hours_str, id_poi):
    if pd.isna(hours_str):
        return []

    day_map = {'Su': 0, 'Mo': 1, 'Tu': 2, 'We': 3, 'Th': 4, 'Fr': 5, 'Sa': 6}
    order_settimana = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']

    hours_str = hours_str.replace('.', '').strip()
    chunks = re.split(r'[;,]', hours_str)

    orari_estratti = []
    pending_days = set()

    for chunk in chunks:
        chunk = chunk.strip()
        if not chunk:
            continue

        day_tokens = re.findall(r'([A-Z][a-z])\s*(?:-\s*([A-Z][a-z]))?', chunk)
        for start_d, end_d in day_tokens:
            if start_d in day_map:
                if end_d and end_d in day_map:
                    start_idx = order_settimana.index(start_d)
                    end_idx = order_settimana.index(end_d)
                    if end_idx >= start_idx:
                        giorni_range = order_settimana[start_idx:end_idx + 1]
                    else:
                        giorni_range = order_settimana[start_idx:] + order_settimana[:end_idx + 1]
                    for giorno_codice in giorni_range:
                        pending_days.add(day_map[giorno_codice])
                else:
                    pending_days.add(day_map[start_d])

        time_matches = re.findall(r'(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})', chunk)
        if time_matches:
            for d in pending_days:
                for t_ap, t_ch in time_matches:
                    orari_estratti.append({
                        'id_poi': id_poi,
                        'giorno': d,
                        'orario_apertura': t_ap.strip(),
                        'orario_chiusura': t_ch.strip()
                    })
            pending_days.clear()

    return orari_estratti

poi_dal_db = pd.read_sql("SELECT id, nome FROM poi WHERE id_categoria = 3 and campus='Forlì'", engine)
df_merged = pd.merge(df, poi_dal_db, left_on='name', right_on='nome', how='inner')

tutti_gli_orari = []
for _, row in df_merged.iterrows():
    tutti_gli_orari.extend(parse_osm_hours(row['opening_hours'], row['id']))

df_orari = pd.DataFrame(tutti_gli_orari)

if not df_orari.empty:
    df_orari = df_orari.drop_duplicates(
        subset=['id_poi', 'giorno', 'orario_apertura', 'orario_chiusura']
    )
    print(df_orari.head())

    try:
        df_orari.to_sql("orario_poi", engine, if_exists="append", index=False)
        print("\nOrari inseriti con successo nel database!")
    except SQLAlchemyError as e:
        print(str(e))
else:
    print("\nNessun orario valido trovato da inserire.")
    """