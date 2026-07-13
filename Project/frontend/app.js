// CONFIGURAZIONI GLOBALI: Definizione URL base API, metadati di categorie ed eventi (colori e label) e inizializzazione mappa

const API_BASE_URL = 'http://localhost:8000';
const CATEGORIE_META = {
    biblioteca:    { label: 'Biblioteca',    codice: 'BIB', colore: '#3B5070' },
    sala_studio:   { label: 'Sala Studio',   codice: 'STU', colore: '#4C7A78' },
    mensa:         { label: 'Mensa',         codice: 'MEN', colore: '#B36B2E' },
    ufficio:       { label: 'Ufficio',       codice: 'UFF', colore: '#8C8577' },
    segreteria:    { label: 'Segreteria',    codice: 'SEG', colore: '#6E4C6E' },
    fermata:       { label: 'Fermata',       codice: 'FER', colore: '#55684A' },
    noleggio_bici: { label: 'Noleggio bici', codice: 'BIC', colore: '#8A9A3E' },
    stazione:      { label: 'Stazione',      codice: 'STA', colore: '#B23A2E' },
    benzinaio:     { label: 'Benzinaio',     codice: 'BEN', colore: '#A6792E' }
};

const TIPI_EVENTO_META = {
    suggerimento:     { label: 'Suggerimento',    colore: '#A6792E' },
    avviso_agenda:    { label: 'Avviso agenda',   colore: '#55684A' },
    poi_selezionato:  { label: 'POI selezionato', colore: '#3B5070' },
    geofencing_enter: { label: 'Geofence enter',  colore: '#B23A2E' },
    geofencing_exit:  { label: 'Geofence exit',   colore: '#8C8577' }
};

let eventiCache = [];

const GIORNI = ['Domenica', 'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì', 'Venerdì', 'Sabato'];

Chart.defaults.font.family = "'IBM Plex Sans', sans-serif";
Chart.defaults.color = '#6B6759';

const map = L.map('map').setView([44.4949, 11.3426], 14);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap contributors'
}).addTo(map);

let heatLayer = null;
let isHeatmapActive = false;
let editingPoiId = null; 

const categorieById = {};   
const categoryLayers = {};  
let poiById = {};            

function escapeHtml(value) {
    if (value === null || value === undefined) return '';
    return String(value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

//Richiede le categorie all'API e prepara i layer della mappa e l'interfaccia utente
async function initCategorie() {
    try {
        const response = await fetch(`${API_BASE_URL}/categorie/`);
        const categorie = await response.json();

        categorie.forEach(cat => {
            const meta = CATEGORIE_META[cat.nome] || { label: cat.nome, codice: '???', colore: '#9ca3af' };
            categorieById[cat.id] = { ...meta, id: cat.id, nome: cat.nome };
            categoryLayers[cat.id] = L.layerGroup().addTo(map);
        });

        renderLegenda();
        renderSelectCategoria();
        renderFilterCategorie();
    } catch (error) {
        console.error(error);
    }
}

//Aggiornano visivamente il DOM popolando la legenda, le select e le checkbox di filtro delle categorie
function renderLegenda() {
    const legenda = document.getElementById('legenda');
    if (!legenda) return;
    legenda.innerHTML = '';
    Object.values(categorieById).forEach(cat => {
        const item = document.createElement('span');
        item.className = 'inline-flex items-center gap-1.5 text-xs mr-4 mb-1.5';
        item.innerHTML = `
            <span class="inline-block w-3 h-3" style="background:${cat.colore}"></span>
            <span>${escapeHtml(cat.label)}</span>
        `;
        legenda.appendChild(item);
    });
}

function renderSelectCategoria() {
    const select = document.getElementById('inputCategoria');
    if (!select) return;
    select.innerHTML = '<option value="" disabled selected>Seleziona una categoria</option>';
    Object.values(categorieById).forEach(cat => {
        const opt = document.createElement('option');
        opt.value = cat.id;
        opt.textContent = cat.label;
        select.appendChild(opt);
    });
}

function renderFilterCategorie() {
    const container = document.getElementById('filterCategorie');
    if (!container) return;
    container.innerHTML = '';
    Object.values(categorieById).forEach(cat => {
        const label = document.createElement('label');
        label.className = 'inline-flex items-center gap-1.5 text-sm mr-3 mb-2 cursor-pointer';
        label.innerHTML = `
            <input type="checkbox" value="${cat.id}" class="filter-categoria-checkbox">
            <span class="inline-block w-2.5 h-2.5" style="background:${cat.colore}"></span>
            ${escapeHtml(cat.label)}
        `;
        container.appendChild(label);
    });
}

//Carica i Punti di Interesse (POI) dal database, eventualmente applicando i filtri di ricerca
async function loadPOIs(queryString = '') {
    try {
        const url = queryString ? `${API_BASE_URL}/poi/filter?${queryString}` : `${API_BASE_URL}/poi/`;
        const response = await fetch(url);
        const poiList = await response.json();

        poiList.forEach(p => poiById[p.id] = p);

        renderPOITable(poiList);
        renderPOIMarkers(poiList);

        if (!queryString) {
            aggiornaListaCampus(poiList);
        }
    } catch (error) {
        console.error(error);
    }
}

//Genera dinamicamente le righe della tabella HTML con i dati dei POI e i pulsanti di azione
function renderPOITable(poiList) {
    const tableBody = document.getElementById('poi-table-body');
    if (!tableBody) return;
    tableBody.innerHTML = '';

    if (poiList.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="6" class="py-4 text-center" style="color:#6B6759">Nessun POI trovato con i filtri selezionati</td></tr>';
        return;
    }

    poiList.forEach(poi => {
        const cat = categorieById[poi.id_categoria];
        const catLabel = cat ? cat.label : '—';
        const catColore = cat ? cat.colore : '#9ca3af';

        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td class="py-2 px-3 font-mono text-xs border-b" style="border-color:#D2CCBA">${poi.id}</td>
            <td class="py-2 px-3 font-medium border-b" style="border-color:#D2CCBA">${escapeHtml(poi.nome)}</td>
            <td class="py-2 px-3 border-b" style="border-color:#D2CCBA">
                <span class="inline-flex items-center gap-1.5">
                    <span class="inline-block w-2.5 h-2.5" style="background:${catColore}"></span>
                    ${escapeHtml(catLabel)}
                </span>
            </td>
            <td class="py-2 px-3 border-b" style="border-color:#D2CCBA">${escapeHtml(poi.campus)}</td>
            <td class="py-2 px-3 text-sm border-b" style="border-color:#D2CCBA; color:#6B6759">${poi.descrizione ? escapeHtml(poi.descrizione) : '-'}</td>
            <td class="py-2 px-3 text-center whitespace-nowrap border-b" style="border-color:#D2CCBA">
                <button onclick="apriModal(${poi.id})" class="btn-amber px-2 py-1 text-xs mr-1">Modifica</button>
                <button onclick="eliminaPOI(${poi.id})" class="btn-ghost px-2 py-1 text-xs">Elimina</button>
            </td>
        `;
        tableBody.appendChild(tr);
    });
}

//Disegna i marker dei POI sulla mappa Leaflet, assegnando il colore corretto in base alla categoria
function renderPOIMarkers(poiList) {
    Object.values(categoryLayers).forEach(layer => layer.clearLayers());

    poiList.forEach(poi => {
        if (!poi.geometria) return;

        const cat = categorieById[poi.id_categoria];
        const colore = cat ? cat.colore : '#6b7280';
        const targetLayer = categoryLayers[poi.id_categoria];

        const descrizioneHtml = poi.descrizione
            ? `<br><span style="color:#666">${escapeHtml(poi.descrizione)}</span>`
            : '';

        const layer = L.geoJSON(poi.geometria, {
            pointToLayer: (feature, latlong) => L.circleMarker(latlong, {
                radius: 8,
                color: colore,
                fillColor: colore,
                fillOpacity: 0.85,
                weight: 1.5
            }),
            style: { color: colore, fillColor: colore, fillOpacity: 0.3, weight: 2 },
            onEachFeature: (feature, l) => {
                l.bindPopup(`<b>${escapeHtml(poi.nome)}</b><br>${cat ? escapeHtml(cat.label) : ''}<br>${escapeHtml(poi.campus)}${descrizioneHtml}`);
            }
        });

        layer.addTo(targetLayer || map);
    });
}

//Estrapola in automatico la lista dei campus dai POI e popola i menu a tendina
function aggiornaListaCampus(poiList) {
    const campusSet = new Set(poiList.map(p => p.campus));

    const datalist = document.getElementById('campusOptions');
    if (datalist) {
        datalist.innerHTML = '';
        campusSet.forEach(c => {
            const opt = document.createElement('option');
            opt.value = c;
            datalist.appendChild(opt);
        });
    }

    const select = document.getElementById('filterCampus');
    if (select) {
        const valorePrecedente = select.value;
        select.innerHTML = '<option value="">Tutti i campus</option>';
        campusSet.forEach(c => {
            const opt = document.createElement('option');
            opt.value = c;
            opt.textContent = c;
            select.appendChild(opt);
        });
        select.value = valorePrecedente;
    }
}


function applyFilters() {
    const params = new URLSearchParams();

    document.querySelectorAll('.filter-categoria-checkbox:checked').forEach(cb => {
        params.append('id_categoria', cb.value);
    });

    const campusEl = document.getElementById('filterCampus');
    if (campusEl && campusEl.value) params.append('campus', campusEl.value);

    const orarioAperturaEl = document.getElementById('filterOrarioApertura');
    if (orarioAperturaEl && orarioAperturaEl.value) params.append('orario_apertura', orarioAperturaEl.value);

    const orarioChiusuraEl = document.getElementById('filterOrarioChiusura');
    if (orarioChiusuraEl && orarioChiusuraEl.value) params.append('orario_chiusura', orarioChiusuraEl.value);

    loadPOIs(params.toString());
}

function resetFilters() {
    document.querySelectorAll('.filter-categoria-checkbox').forEach(cb => cb.checked = false);
    
    const campusEl = document.getElementById('filterCampus');
    if (campusEl) campusEl.value = '';
    
    const orarioAperturaEl = document.getElementById('filterOrarioApertura');
    if (orarioAperturaEl) orarioAperturaEl.value = '';
    
    const orarioChiusuraEl = document.getElementById('filterOrarioChiusura');
    if (orarioChiusuraEl) orarioChiusuraEl.value = '';
    
    loadPOIs();
}

function impostaOrarioAdesso() {
    const now = new Date();
    const hh = String(now.getHours()).padStart(2, '0');
    const mm = String(now.getMinutes()).padStart(2, '0');
    const adesso = `${hh}:${mm}`;
    
    const orarioAperturaEl = document.getElementById('filterOrarioApertura');
    if (orarioAperturaEl) orarioAperturaEl.value = adesso;
    
    const orarioChiusuraEl = document.getElementById('filterOrarioChiusura');
    if (orarioChiusuraEl) orarioChiusuraEl.value = adesso;
}

//Gestiscono l'apertura (per inserimento o modifica dati) e la chiusura della finestra modale dei POI

async function apriModal(poiId = null) {
    editingPoiId = poiId;

    const modalTitle = document.getElementById('modalTitle');
    const submitBtn = document.getElementById('submitPoiBtn');
    const orariSection = document.getElementById('orariSection');
    const geometriaInput = document.getElementById('inputGeometria');
    const geometriaHint = document.getElementById('geometriaHint');

    if (poiId === null) {
        modalTitle.textContent = 'Aggiungi un nuovo POI';
        submitBtn.textContent = 'Salva';
        orariSection.classList.add('hidden');
        
        geometriaInput.setAttribute('required', 'true');
        geometriaHint.textContent = 'Formato WKT, es. POINT(11.34 44.49). Obbligatorio.';
        
        document.getElementById('inputNome').value = '';
        document.getElementById('inputCategoria').value = '';
        document.getElementById('inputCampus').value = '';
        document.getElementById('inputDescrizione').value = '';
        geometriaInput.value = '';
        
    } else {
        const poi = poiById[poiId];
        if (!poi) return;

        document.getElementById('inputNome').value = poi.nome;
        document.getElementById('inputCategoria').value = poi.id_categoria;
        document.getElementById('inputCampus').value = poi.campus;
        document.getElementById('inputDescrizione').value = poi.descrizione || '';
        geometriaInput.value = '';
        
        geometriaInput.removeAttribute('required');
        geometriaHint.textContent = "Lascia vuoto per non modificare la posizione attuale.";

        modalTitle.textContent = `Modifica: ${poi.nome}`;
        submitBtn.textContent = 'Salva modifiche';
        orariSection.classList.remove('hidden');
        await caricaOrariPoi(poiId);
    }

    document.getElementById('modalPoi').classList.remove('hidden');
}

function chiudiModal() {
    document.getElementById('modalPoi').classList.add('hidden');
    document.getElementById('formPoi').reset();
    document.getElementById('listaOrari').innerHTML = '';
    editingPoiId = null;
}

function estraiErrore(errData, messaggioDefault) {
    if (!errData || !errData.detail) return messaggioDefault;
    return typeof errData.detail === 'string' ? errData.detail : JSON.stringify(errData.detail);
}

//Eseguono le chiamate API per creare (POST), aggiornare (PATCH) o eliminare (DELETE) un POI
async function salvaPOI(event) {
    event.preventDefault(); 

    const payload = {
        nome: document.getElementById('inputNome').value,
        id_categoria: parseInt(document.getElementById('inputCategoria').value),
        campus: document.getElementById('inputCampus').value,
        descrizione: document.getElementById('inputDescrizione').value
    };

    const geometriaRaw = document.getElementById('inputGeometria').value.trim();
    if (geometriaRaw) {
        let wkt = geometriaRaw.toUpperCase();
        
        if (!wkt.startsWith('POINT') && !wkt.startsWith('POLYGON') && !wkt.startsWith('MULTIPOLYGON') && !wkt.startsWith('SRID=')) {
            alert('Formato geometria non valido! Usa un formato come POINT(11.34 44.49).');
            return; 
        }

        if (!wkt.startsWith('SRID=4326;')) wkt = `SRID=4326;${wkt}`;
        payload.geometria = wkt;
    }

    try {
        let response;
        if (editingPoiId === null) {
            response = await fetch(`${API_BASE_URL}/poi/`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
        } else {
            response = await fetch(`${API_BASE_URL}/poi/${editingPoiId}`, {
                method: 'PATCH',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
        }

        if (response.ok) {
            chiudiModal();
            loadPOIs();
            loadAnalyticsDashboard();
        } else {
            const errData = await response.json().catch(() => null);
            console.error("Dettagli errore server:", errData);
            alert(estraiErrore(errData, 'Errore nel salvataggio del POI. Controlla che i dati siano validi.'));
        }
    } catch (error) {
        console.error("Errore di rete o fetch:", error);
        alert("Impossibile connettersi al server. Verifica che sia acceso e non ci siano errori CORS.");
    }
}

async function eliminaPOI(id) {
    if (!confirm('Eliminare questo POI?')) return;

    try {
        const response = await fetch(`${API_BASE_URL}/poi/${id}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            loadPOIs();
            loadAnalyticsDashboard();
        } else {
            alert("Errore durante l'eliminazione");
        }
    } catch (error) {
        console.error(error);
        alert("Errore di connessione al server.");
    }
}

async function caricaOrariPoi(idPoi) {
    const lista = document.getElementById('listaOrari');
    lista.innerHTML = '<li style="color:#6B6759">Caricamento...</li>';

    try {
        const response = await fetch(`${API_BASE_URL}/orari/poi/${idPoi}`);
        const orari = await response.json();

        if (orari.length === 0) {
            lista.innerHTML = '<li style="color:#6B6759">Nessun orario impostato (POI considerato sempre aperto)</li>';
            return;
        }

        lista.innerHTML = '';
        orari.forEach(o => {
            const li = document.createElement('li');
            li.className = 'flex justify-between items-center py-1';
            li.style.borderBottom = '1px solid #D2CCBA';
            li.innerHTML = `
                <span>${GIORNI[o.giorno]}: ${o.orario_apertura.slice(0, 5)} - ${o.orario_chiusura.slice(0, 5)}</span>
                <button type="button" onclick="eliminaOrario(${o.id}, ${idPoi})" class="btn-ghost text-xs px-2 py-0.5">Elimina</button>
            `;
            lista.appendChild(li);
        });
    } catch (error) {
        console.error(error);
    }
}

async function aggiungiOrario() {
    if (editingPoiId === null) return;

    const giorno = parseInt(document.getElementById('nuovoGiorno').value);
    const apertura = document.getElementById('nuovaApertura').value;
    const chiusura = document.getElementById('nuovaChiusura').value;

    if (!apertura || !chiusura) {
        alert('Inserisci sia orario di apertura che di chiusura.');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/orari/`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                id_poi: editingPoiId,
                giorno: giorno,
                orario_apertura: apertura,
                orario_chiusura: chiusura
            })
        });

        if (response.ok) {
            document.getElementById('nuovaApertura').value = '';
            document.getElementById('nuovaChiusura').value = '';
            caricaOrariPoi(editingPoiId);
        } else {
            const errData = await response.json().catch(() => null);
            alert(estraiErrore(errData, "Errore nel salvataggio dell'orario"));
        }
    } catch (error) {
        console.error(error);
        alert("Errore di connessione al server.");
    }
}

async function eliminaOrario(orarioId, idPoi) {
    if (!confirm('Eliminare questo orario?')) return;

    try {
        const response = await fetch(`${API_BASE_URL}/orari/${orarioId}`, { method: 'DELETE' });
        if (response.ok) {
            caricaOrariPoi(idPoi);
        } else {
            alert("Errore durante l'eliminazione dell'orario");
        }
    } catch (error) {
        console.error(error);
        alert("Errore di connessione al server.");
    }
}

async function loadHeatmap() {
    try {
        const response = await fetch(`${API_BASE_URL}/analytics/heatmap/pois`);
        const points = await response.json();
        const heatData = points.map(p => [p.lat, p.lon, 1.0]);

        heatLayer = L.heatLayer(heatData, {
            radius: 25, blur: 15, maxZoom: 16,
            gradient: { 0.4: 'blue', 0.6: 'cyan', 0.7: 'lime', 0.8: 'yellow', 1.0: 'red' }
        });
    } catch (error) {
        console.error(error);
    }
}

function toggleHeatmap() {
    if (!heatLayer) return;
    if (isHeatmapActive) map.removeLayer(heatLayer);
    else heatLayer.addTo(map);
    isHeatmapActive = !isHeatmapActive;
}

//Recupera i dati storici e popola il grafico a barre degli eventi, gestendone anche il filtraggio temporal
async function loadEventiPerOra() {
    try {
        const response = await fetch(`${API_BASE_URL}/eventi/getAll`);
        eventiCache = await response.json();
        renderEventiOraChart(eventiCache);
    } catch (error) {
        console.error(error);
    }
}

function renderEventiOraChart(eventi) {
    const buckets = {};
    eventi.forEach(e => {
        const ora = parseInt(e.time_stamp.slice(11, 13), 10);
        if (Number.isNaN(ora) || ora < 0 || ora > 23) return;
        const tipoKey = (e.tipo || 'altro').toLowerCase();
        if (!buckets[tipoKey]) buckets[tipoKey] = new Array(24).fill(0);
        buckets[tipoKey][ora]++;
    });

    const labels = Array.from({ length: 24 }, (_, h) => `${String(h).padStart(2, '0')}:00`);
    const datasets = Object.entries(buckets).map(([tipoKey, counts]) => {
        const meta = TIPI_EVENTO_META[tipoKey] || { label: tipoKey, colore: '#9ca3af' };
        return { label: meta.label, data: counts, backgroundColor: meta.colore, borderRadius: 2 };
    });

    const ctxEl = document.getElementById('eventiOraChart');
    if (!ctxEl) return;
    const ctx = ctxEl.getContext('2d');
    if (window.myEventiOraChart) window.myEventiOraChart.destroy();
    window.myEventiOraChart = new Chart(ctx, {
        type: 'bar',
        data: { labels: labels, datasets: datasets },
        options: {
            maintainAspectRatio: false,
            plugins: { legend: { position: 'bottom' } },
            scales: {
                x: { stacked: true, ticks: { maxRotation: 0, autoSkip: true } },
                y: { stacked: true, beginAtZero: true, ticks: { precision: 0 } }
            }
        }
    });
}

function applicaFiltroEventi() {
    const da = document.getElementById('filtroEventiDa').value; // "YYYY-MM-DD" oppure ""
    const a  = document.getElementById('filtroEventiA').value;
    const filtrati = eventiCache.filter(e => {
        if (!e.time_stamp) return false;
        const dataEvento = e.time_stamp.slice(0, 10);
        if (da && dataEvento < da) return false;
        if (a && dataEvento > a) return false;
        return true;
    });
    renderEventiOraChart(filtrati);
}

function resetFiltroEventi() {
    document.getElementById('filtroEventiDa').value = '';
    document.getElementById('filtroEventiA').value = '';
    renderEventiOraChart(eventiCache);
}

//Genera i grafici per feedback, POI più attivi e categorie maggiormente richieste
async function loadAnalyticsDashboard() {
    try {
        const response = await fetch(`${API_BASE_URL}/analytics/dashboard`);
        
        const data = await response.json(); //data ha tre oggeti: più attivi, conteggio per mezzi e conteggio epr feedback
        //console.log(data);

        const feedbackLabels = data.statistiche_feedback.map(f => f.is_utile ? 'Utile' : 'Non Utile');
        const feedbackCounts = data.statistiche_feedback.map(f => f.conteggio);

        const feedbackCtxEl = document.getElementById('feedbackChart');
        if (feedbackCtxEl) {
            const feedbackCtx = feedbackCtxEl.getContext('2d');
            if (window.myFeedbackChart) window.myFeedbackChart.destroy();
            window.myFeedbackChart = new Chart(feedbackCtx, {
                type: 'doughnut',
                data: {
                    labels: feedbackLabels,
                    datasets: [{ data: feedbackCounts, backgroundColor: ['#55684A', '#B23A2E'] }]
                },
                options: { maintainAspectRatio: false }
            });
        }
        
        const totaleSuggerimenti = feedbackCounts.reduce((a, b) => a + b, 0);
        const utili = (data.statistiche_feedback.find(f => f.is_utile) || {}).conteggio || 0;

        const kpiTotalePoi = document.getElementById('kpiTotalePoi');
        if(kpiTotalePoi) kpiTotalePoi.textContent = Object.keys(poiById).length;
        
        const kpiSuggerimenti = document.getElementById('kpiSuggerimenti');
        if(kpiSuggerimenti) kpiSuggerimenti.textContent = totaleSuggerimenti;
        
        const kpiPercentualeUtili = document.getElementById('kpiPercentualeUtili');
        if(kpiPercentualeUtili) kpiPercentualeUtili.textContent = totaleSuggerimenti > 0
            ? `${Math.round((utili / totaleSuggerimenti) * 100)}%`
            : 'N/D';

        const topPois = data.poi_piu_attivi.slice(0, 10);
        const poiCtxEl = document.getElementById('poiChart');
        if (poiCtxEl) {
            const poiCtx = poiCtxEl.getContext('2d');
            if (window.myPoiChart) window.myPoiChart.destroy();
            window.myPoiChart = new Chart(poiCtx, {
                type: 'bar',
                data: {
                    labels: topPois.map(p => p.nome_poi.length > 5 ? p.nome_poi.substring(0, 5) + '...' : p.nome_poi), 
                    datasets: [{
                        label: 'Totale Eventi',
                        data: topPois.map(p => p.totale_eventi),
                        backgroundColor: '#23281F', borderRadius: 2
                    }]
                },
                options: { 
                    maintainAspectRatio: false, 
                    scales: { y: { beginAtZero: true, ticks: { precision: 0 } } },
                    plugins: {
                        tooltip: {
                            callbacks: {
                                title: function(context) {
                                    return topPois[context[0].dataIndex].nome_poi;
                                }
                            }
                        }
                    }
                }
            });
        }

        const eventiPerCategoria = {};

        //funzione per ragguppare gli eventi per categoria usando prima l'id del Point of view a cui appartiene l'evento
        data.poi_piu_attivi.forEach(p => {
            const poi = poiById[p.id_poi];
            if (!poi) return; 
            const catId = poi.id_categoria;
            eventiPerCategoria[catId] = (eventiPerCategoria[catId] || 0) + p.totale_eventi;
        });
    
        //console.log("Eventi per categoria:", eventiPerCategoria);
        const categorieOrdinate = Object.entries(eventiPerCategoria)
            .map(([catId, totale]) => {
                const cat = categorieById[catId];
                return {
                    label: cat ? cat.label : `Cat. ${catId}`,
                    colore: cat ? cat.colore : '#9ca3af',
                    totale
                };
            })
            .sort((a, b) => b.totale - a.totale);

        const catCtxEl = document.getElementById('categorieChart');
        if (catCtxEl) {
            const catCtx = catCtxEl.getContext('2d');
            if (window.myCategorieChart) window.myCategorieChart.destroy();
            window.myCategorieChart = new Chart(catCtx, {
                type: 'bar',
                data: {
                    labels: categorieOrdinate.map(c => c.label),
                    datasets: [{
                        label: 'Eventi totali per categoria',
                        data: categorieOrdinate.map(c => c.totale),
                        backgroundColor: categorieOrdinate.map(c => c.colore),
                        borderRadius: 2
                    }]
                },
                options: {
                    indexAxis: 'y',
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { x: { beginAtZero: true, ticks: { precision: 0 } } }
                }
            });
        }

    } catch (error) {
        console.error(error);
    }
}

document.addEventListener('DOMContentLoaded', async () => {
    await initCategorie();
    await loadPOIs();
    loadHeatmap();
    loadAnalyticsDashboard();
    loadEventiPerOra();
});