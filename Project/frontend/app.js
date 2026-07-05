// INDIRIZZO DEL TUO BACKEND FASTAPI
const API_BASE_URL = 'http://127.0.0.1:8000';

const map = L.map('map').setView([44.4949, 11.3426], 14);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap contributors'
}).addTo(map);

let heatLayer = null;
let isHeatmapActive = false;

async function loadPOIs() {
    try {
        const response = await fetch(`${API_BASE_URL}/poi/`);
        const poiList = await response.json();
        
        const tableBody = document.getElementById('poi-table-body');
        tableBody.innerHTML = ''; 

        poiList.forEach(poi => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td class="py-2 px-4 border-b">${poi.id}</td>
                <td class="py-2 px-4 border-b font-medium">${poi.nome}</td>
                <td class="py-2 px-4 border-b">${poi.campus}</td>
                <td class="py-2 px-4 border-b text-sm text-gray-600">${poi.descrizione || '-'}</td>
            `;
            tableBody.appendChild(tr);

            if (poi.geometria) {
                L.geoJSON(poi.geometria, {
                    onEachFeature: function (feature, layer) {
                        layer.bindPopup(`<b>${poi.nome}</b><br>${poi.campus}`);
                    }
                }).addTo(map);
            }
        });
    } catch (error) {
        console.error("Errore caricamento POI:", error);
        document.getElementById('poi-table-body').innerHTML = '<tr><td colspan="4" class="text-red-500 text-center py-4">Errore di connessione API</td></tr>';
    }
}

async function loadHeatmap() {
    try {
        const response = await fetch(`${API_BASE_URL}/analytics/heatmap/pois`);
        const points = await response.json();

        const heatData = points.map(p => [p.lat, p.lon, 1.0]);
        
        heatLayer = L.heatLayer(heatData, {
            radius: 25, 
            blur: 15, 
            maxZoom: 16,
            gradient: {0.4: 'blue', 0.6: 'cyan', 0.7: 'lime', 0.8: 'yellow', 1.0: 'red'}
        });
    } catch (error) {
        console.error("Errore caricamento Heatmap:", error);
    }
}

function toggleHeatmap() {
    if (!heatLayer) return;
    if (isHeatmapActive) {
        map.removeLayer(heatLayer);
    } else {
        heatLayer.addTo(map);
    }
    isHeatmapActive = !isHeatmapActive;
}

async function loadAnalyticsDashboard() {
    try {
        const response = await fetch(`${API_BASE_URL}/analytics/dashboard`);
        const data = await response.json();

        const feedbackCtx = document.getElementById('feedbackChart').getContext('2d');
        const feedbackLabels = data.statistiche_feedback.map(f => f.is_utile ? 'Utile' : 'Non Utile');
        const feedbackCounts = data.statistiche_feedback.map(f => f.conteggio);
        
        new Chart(feedbackCtx, {
            type: 'doughnut',
            data: {
                labels: feedbackLabels,
                datasets: [{
                    data: feedbackCounts,
                    backgroundColor: ['#10b981', '#ef4444'] 
                }]
            }
        });

        const topPois = data.poi_piu_attivi.slice(0, 10);
        const poiCtx = document.getElementById('poiChart').getContext('2d');
        
        new Chart(poiCtx, {
            type: 'bar',
            data: {
                labels: topPois.map(p => p.nome_poi),
                datasets: [{
                    label: 'Totale Eventi Suggeriti',
                    data: topPois.map(p => p.totale_eventi),
                    backgroundColor: '#00ffff',
                    borderRadius: 4
                }]
            },
            options: { 
                scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
            }
        });

    } catch (error) {
        console.error("Errore caricamento Dashboard Stats:", error);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    loadPOIs();
    loadHeatmap();
    loadAnalyticsDashboard();
});