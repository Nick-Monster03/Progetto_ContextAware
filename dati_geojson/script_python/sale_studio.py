import os
import geopandas as gpd
from sqlalchemy import create_engine
from geoalchemy2 import Geometry

filename = "../Cesena/sala_studio_Cesena.geojson"

if not os.path.exists(filename):
    print(f"ATTENZIONE: File '{filename}' non trovato!")
    raise FileNotFoundError(filename)

df = gpd.read_file(filename)
df = df.dropna(subset=['name'])
if df.crs is None:
    df = df.set_crs("EPSG:4326")
elif df.crs != "EPSG:4326":
    df = df.to_crs("EPSG:4326")
print(f"Caricato: {filename} ({len(df)} POI)")
totale_iniziale = len(df)


if 'description' in df.columns:
    df['descrizione'] = df['description'].fillna(df['name'])
else:
    df['descrizione'] = df['name']

poi = gpd.GeoDataFrame()
poi['nome'] = df['name']
poi['geometria'] = df['geometry']
poi['id_categoria'] = 2  # Sale Studio
poi = poi.set_geometry('geometria', crs="EPSG:4326")
poi['campus'] = "Cesena"
poi['descrizione'] = df['descrizione']

print(poi.head())

DB_URL = "postgresql://postgres:changeme@localhost:5432/ProgettoCAS"
engine = create_engine(DB_URL)
print("\nInserimento dei POI Sale Studio nel Database...")
poi_to_db = poi[['nome', 'id_categoria', 'descrizione', 'geometria', 'campus']]

poi_to_db.to_postgis(
    "poi",
    engine,
    if_exists="append",
    index=False,
    dtype={'geometria': Geometry('GEOMETRY', srid=4326)}
)

