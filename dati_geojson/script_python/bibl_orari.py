import geopandas
import matplotlib.pyplot as plt
import pandas as pd
from sqlalchemy import create_engine
from geoalchemy2 import Geometry

filename = "../Cesena/biblioteche_Cesena.geojson"
df = geopandas.read_file(filename)
print(df.info()) 


df = df.dropna(subset=['name', 'addr:city' ])
#df = df[df['operator:type'] == 'university']

df['descrizione'] = df['name']
poi = geopandas.GeoDataFrame()

poi['nome'] = df['name'].fillna("Biblioteca Sconosciuta")
poi['geometria'] = df['geometry']
poi['id_categoria'] = 1  

poi = poi.set_geometry('geometria', crs="EPSG:4326")

poi['campus'] = "Cesena"
poi['descrizione'] = df['descrizione']

print(poi.head())



DB_URL = "postgresql://postgres:changeme@localhost:5432/ProgettoCAS"
engine = create_engine(DB_URL)

print("\nInserimento dei POI nel Database...")
poi_to_db = poi[['nome', 'id_categoria', 'descrizione', 'geometria', 'campus']]

poi_to_db.to_postgis(
    "poi", 
    engine, 
    if_exists="append", 
    index=False,
    dtype={'geometria': Geometry('GEOMETRY', srid=4326)} # Assicura la corretta tipizzazione spaziale
)

"""
poi_dal_db = pd.read_sql("SELECT id, nome FROM poi WHERE id_categoria = 1", engine)

df_merged = pd.merge(df, poi_dal_db, left_on='name', right_on='nome', how='inner')

import re
from sqlalchemy.exc import SQLAlchemyError


def parse_osm_hours(hours_str, id_poi):
    if pd.isna(hours_str): 
        return []
        
    day_map = {'Su': 0, 'Mo': 1, 'Tu': 2, 'We': 3, 'Th': 4, 'Fr': 5, 'Sa': 6}
    days_list = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
    
    hours_str = hours_str.replace('.', '').strip()
    
    chunks = re.split(r'[;,]', hours_str)
    
    orari_estratti = []
    pending_days = set() 
    
    for chunk in chunks:
        chunk = chunk.strip()
        if not chunk: continue
        
        day_tokens = re.findall(r'([A-Z][a-z])\s*(?:-\s*([A-Z][a-z]))?', chunk)
        for start_d, end_d in day_tokens:
            if start_d in day_map:
                if end_d and end_d in day_map: 
                    start_idx = days_list.index(start_d)
                    end_idx = days_list.index(end_d)
                    for i in range(start_idx, end_idx + 1):
                        pending_days.add(day_map[days_list[i]])
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

tutti_gli_orari = []

for index, row in df_merged.iterrows():
    id_poi_reale = row['id']
    stringa_orari = row['opening_hours']
    
    orari_biblioteca = parse_osm_hours(stringa_orari, id_poi_reale)
    tutti_gli_orari.extend(orari_biblioteca)

df_orari = pd.DataFrame(tutti_gli_orari)

if not df_orari.empty:
    df_orari = df_orari.drop_duplicates(subset=['id_poi', 'giorno', 'orario_apertura', 'orario_chiusura'])


if not df_orari.empty:
    print(df_orari.head())
    
    try:
        df_orari.to_sql("orario_poi", engine, if_exists="append", index=False)
    except SQLAlchemyError as e:
        print(str(e._message()) if hasattr(e, '_message') else str(e))
else:
    print("\nNessun orario valido trovato da inserire. (Possibile problema nel merge tra DataFrame e Database)")


tutti_gli_orari = []

for index, row in df_merged.iterrows():
    id_poi_reale = row['id']
    stringa_orari = row['opening_hours']
    
    orari_biblioteca = parse_osm_hours(stringa_orari, id_poi_reale)
    tutti_gli_orari.extend(orari_biblioteca)

df_orari = pd.DataFrame(tutti_gli_orari)
df_orari = df_orari.drop_duplicates(subset=['id_poi', 'giorno', 'orario_apertura', 'orario_chiusura'])

if not df_orari.empty:
    print(df_orari.head())
    
    # Inserimento standard usando pandas (qui non c'è geometria)
    df_orari.to_sql("orario_poi", engine, if_exists="append", index=False)
else:
    print("\nNessun orario valido trovato da inserire.")
 
"""