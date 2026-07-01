import os
import geopandas as gpd
import numpy as np
import pandas as pd


def carica_e_sistema_crs(filename):
    if not os.path.exists(filename):
        print(f"⚠️ ATTENZIONE: File '{filename}' non trovato!")
        return None
        
    gdf = gpd.read_file(filename)
    if gdf.crs is None:
        gdf = gdf.set_crs("EPSG:4326")
    elif gdf.crs != "EPSG:4326":
        gdf = gdf.to_crs("EPSG:4326")
        
    print(f"✅ Caricato: {filename} ({len(gdf)} POI)")
    return gdf


print("Inizio caricamento file...\n")

df_biblioteche = carica_e_sistema_crs("../Forlì/biblioteche_forlì.geojson")
df_sale_studio = carica_e_sistema_crs("../Forlì/sale_studio_forlì.geojson")
df_mense       = carica_e_sistema_crs("../Forlì/mense_forlì.geojson")
df_segreterie  = carica_e_sistema_crs("../Forlì/segreteria_forlì.geojson")
df_fermate     = carica_e_sistema_crs("../Forlì/bus_stop_forlì.geojson")
df_bici        = carica_e_sistema_crs("../Forlì/noleggio_bici_forlì.geojson")
df_stazioni    = carica_e_sistema_crs("../Forlì/station_forlì.geojson")
df_benzinai    = carica_e_sistema_crs("../Forlì/benzinaio_forlì.geojson")

print("\nTutti i DataFrame sono ora disponibili come variabili indipendenti!")

dataset_dict = {
    "Biblioteche": df_biblioteche,
    "Sale Studio": df_sale_studio,
    "Mense": df_mense,
    "Segreterie": df_segreterie,
    "Fermate Bus": df_fermate,
    "Noleggio Bici": df_bici,
    "Stazioni": df_stazioni,
    "Benzinai": df_benzinai
}



for nome, df in dataset_dict.items():
    if df is not None:
        num_righe, num_colonne = df.shape
        colonne = df.columns.tolist()
        print(f"{nome}")
        print(f"Dimensioni : {num_righe} POI, {num_colonne} attributi")
        print(f"Colonne    : {', '.join(colonne)}")
    else:
        print(f"{nome}")
        print("Dataset non caricato o vuoto.")
        
        
#######SALE STUDIO############

print("\nInizio pulizia dataset Sale Studio...")
colonne_studio = ['name', 'description']
for col in colonne_studio:
    if col in df_sale_studio.columns:
        df_sale_studio[col] = df_sale_studio[col].replace(r'^\s*$', np.nan, regex=True)
        df_sale_studio[col] = df_sale_studio[col].replace(['null', 'None', 'N/A', '-'], np.nan)

df_sale_studio_clean = df_sale_studio.dropna(subset=['name']).copy()
df_sale_studio_clean['nome'] = df_sale_studio_clean['name']
df_sale_studio_clean['id_categoria'] = 2
if 'description' in df_sale_studio_clean.columns:
    df_sale_studio_clean['descrizione'] = df_sale_studio_clean['description'].fillna(df_sale_studio_clean['name'])
else:
    df_sale_studio_clean['descrizione'] = df_sale_studio_clean['name']
colonne_db = ['nome', 'id_categoria', 'descrizione', 'geometry']
df_sale_studio_db = df_sale_studio_clean[colonne_db].copy()
#print(df_sale_studio_db.head())


#######MENSE#################
colonne_mense = ['name', 'cuisine']
for col in colonne_mense:
    if col in df_mense.columns:
        df_mense[col] = df_mense[col].replace(r'^\s*$', np.nan, regex=True)
        df_mense[col] = df_mense[col].replace(['null', 'None', 'N/A', '-'], np.nan)
df_mense_clean = df_mense.dropna(subset=['name', 'cuisine']).copy()
df_mense_clean['nome'] = df_mense_clean['name']
df_mense_clean['id_categoria'] = 3
def crea_descrizione_mense(row):
    dettagli = [f"Cucina: {row['cuisine']}"]
    if 'diet:vegan' in row and pd.notna(row['diet:vegan']) and str(row['diet:vegan']).lower() == 'yes':
        dettagli.append("Opzioni vegane")
    if 'diet:gluten_free' in row and pd.notna(row['diet:gluten_free']) and str(row['diet:gluten_free']).lower() == 'yes':
        dettagli.append("Senza glutine")
    if 'takeaway' in row and pd.notna(row['takeaway']) and str(row['takeaway']).lower() == 'yes':
        dettagli.append("Takeaway")
        
    return " | ".join(dettagli)

df_mense_clean['descrizione'] = df_mense_clean.apply(crea_descrizione_mense, axis=1)
colonne_db = ['nome', 'id_categoria', 'descrizione', 'geometry']
df_mense_db = df_mense_clean[colonne_db].copy()
#print(df_mense_db.head())


#######SEGRETERIE############
colonne_segreterie = ['name', 'addr:city', 'operator', 'office']
for col in colonne_segreterie:
    if col in df_segreterie.columns:
        df_segreterie[col] = df_segreterie[col].replace(r'^\s*$', np.nan, regex=True)
        df_segreterie[col] = df_segreterie[col].replace(['null', 'None', 'N/A', '-'], np.nan)

colonne_obbligatorie = ['name']
if 'addr:city' in df_segreterie.columns:
    colonne_obbligatorie.append('addr:city')

df_segreterie_clean = df_segreterie.dropna(subset=colonne_obbligatorie).copy()
df_segreterie_clean['nome'] = df_segreterie_clean['name']
df_segreterie_clean['id_categoria'] = 5
def crea_descrizione_segreterie(row):
    dettagli = []
    if 'operator' in row and pd.notna(row['operator']):
        dettagli.append(f"Operatore: {row['operator']}")
    if 'office' in row and pd.notna(row['office']):
        dettagli.append(f"Tipo ufficio: {row['office']}")
    testo_base = " | ".join(dettagli) if dettagli else "Segreteria"
    
    if 'addr:city' in row and pd.notna(row['addr:city']):
        testo_base += f" ({row['addr:city']})"
        
    return testo_base

df_segreterie_clean['descrizione'] = df_segreterie_clean.apply(crea_descrizione_segreterie, axis=1)
colonne_db = ['nome', 'id_categoria', 'descrizione', 'geometry']
df_segreterie_db = df_segreterie_clean[colonne_db].copy()
#print(df_segreterie_db.head())


########BUS STOP#############
colonne_bus = ['name', 'name:it', 'ref', 'operator', 'network', 'route_ref', 'shelter', 'wheelchair']
for col in colonne_bus:
    if col in df_fermate.columns:
        df_fermate[col] = df_fermate[col].replace(r'^\s*$', np.nan, regex=True)
        df_fermate[col] = df_fermate[col].replace(['null', 'None', 'N/A', '-'], np.nan)
df_fermate_clean = df_fermate.dropna(subset=['operator']).copy()
df_fermate_clean['nome'] = df_fermate_clean['name'].fillna(df_fermate_clean['name:it'])
df_fermate_clean['nome'] = df_fermate_clean['nome'].fillna("Fermata " + df_fermate_clean['ref'].fillna("Senza Nome"))
df_fermate_clean['id_categoria'] = 6

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

df_fermate_clean['descrizione'] = df_fermate_clean.apply(crea_descrizione_bus, axis=1)

colonne_db = ['nome', 'id_categoria', 'descrizione', 'geometry']
df_fermate_db = df_fermate_clean[colonne_db].copy()
print(df_fermate_db.head())


########BICI NOLEGGIO########

colonne_bici = ['name', 'network', 'operator', 'capacity', 'fee']
for col in colonne_bici:
    if col in df_bici.columns:
        df_bici[col] = df_bici[col].replace(r'^\s*$', np.nan, regex=True)
        df_bici[col] = df_bici[col].replace(['null', 'None', 'N/A', '-'], np.nan)

df_bici['nome'] = df_bici['name'].fillna(df_bici['network']).fillna(df_bici['operator']).fillna('Stazione Noleggio Bici')

df_bici['id_categoria'] = 7

def crea_descrizione_bici(row):
    dettagli = []
    if 'operator' in row and pd.notna(row['operator']):
        dettagli.append(f"Operatore: {row['operator']}")
    if 'capacity' in row and pd.notna(row['capacity']):
        dettagli.append(f"Capacità: {int(float(row['capacity']))} posti")
    if 'fee' in row and pd.notna(row['fee']) and str(row['fee']).lower() != 'no':
        dettagli.append(f"A pagamento: {row['fee']}")
        
    return " | ".join(dettagli) if dettagli else None

df_bici['descrizione'] = df_bici.apply(crea_descrizione_bici, axis=1)

colonne_db = ['nome', 'id_categoria', 'descrizione', 'geometry']
df_bici_db = df_bici[colonne_db].copy()

#print(df_bici_db.head())


########STAZIONE############
colonne_stazioni = ['name', 'name:it', 'operator', 'operator:short', 'network', 'wheelchair']
for col in colonne_stazioni:
    if col in df_stazioni.columns:
        df_stazioni[col] = df_stazioni[col].replace(r'^\s*$', np.nan, regex=True)
        df_stazioni[col] = df_stazioni[col].replace(['null', 'None', 'N/A', '-'], np.nan)
df_stazioni_clean = df_stazioni.dropna(subset=['operator', 'operator:short'], how='all').copy()
df_stazioni_clean['nome'] = df_stazioni_clean['name'].fillna(df_stazioni_clean['name:it']).fillna("Stazione Sconosciuta")
df_stazioni_clean['id_categoria'] = 8
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

df_stazioni_clean['descrizione'] = df_stazioni_clean.apply(crea_descrizione_stazioni, axis=1)

colonne_db = ['nome', 'id_categoria', 'descrizione', 'geometry']
df_stazioni_db = df_stazioni_clean[colonne_db].copy()

#print(df_stazioni_db.head())


########BENZINAIO############

colonne_da_controllare = ['brand', 'name', 'operator', 'addr:street']
for col in colonne_da_controllare:
    if col in df_benzinai.columns:
        df_benzinai[col] = df_benzinai[col].replace(r'^\s*$', np.nan, regex=True)
        df_benzinai[col] = df_benzinai[col].replace(['null', 'None', 'N/A', '-'], np.nan)

df_benzinai['nome'] = df_benzinai['brand'].fillna(df_benzinai['name'])

df_benzinai_clean = df_benzinai.dropna(subset=['nome']).copy()

df_benzinai_clean['id_categoria'] = 9

if 'operator' in df_benzinai_clean.columns:
    df_benzinai_clean['descrizione'] = "Operatore: " + df_benzinai_clean['operator'].fillna("Non specificato")
else:
    df_benzinai_clean['descrizione'] = None

colonne_db = ['nome', 'id_categoria', 'descrizione', 'geometry']
df_benzinai_db = df_benzinai_clean[colonne_db]

print(df_benzinai_db.head())







