// Crear mapa centrado en la Ciudad de México
const map = L.map('map').setView([19.4, -99.1], 8);

// Capa base (OpenStreetMap)
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 10,
    attribution: '© OpenStreetMap contributors'
}).addTo(map);

let aircraftMarkers = {};

async function fetchFlights() {
    try {
        // Coordenadas aproximadas de CDMX y alrededores
        const lamin = 18.8;
        const lamax = 20.2;
        const lomin = -100.2;
        const lomax = -98.6;

        const response = await fetch(`/api/opensky?lamin=${lamin}&lomin=${lomin}&lamax=${lamax}&lomax=${lomax}`);
        const data = await response.json();

        console.log("Vuelos recibidos:", data.states?.length || 0);

        if (!data.states || data.states.length === 0) {
            console.warn("Sin vuelos detectados en esta región.");
            return;
        }

        // Eliminar marcadores antiguos que ya no están
        for (const icao24 in aircraftMarkers) {
            if (!data.states.some(s => s[0] === icao24)) {
                map.removeLayer(aircraftMarkers[icao24]);
                delete aircraftMarkers[icao24];
            }
        }

        // Agregar o actualizar marcadores
        data.states.forEach(state => {
            const icao24 = state[0];
            const callsign = state[1]?.trim() || "N/A";
            const country = state[2];
            const lon = state[5];
            const lat = state[6];
            const altitude = state[7];
            const velocity = state[9];

            if (!lat || !lon) return;

            const popup = `
                <b>${callsign}</b><br>
                País: ${country}<br>
                Velocidad: ${Math.round(velocity || 0)} m/s<br>
                Altitud: ${Math.round(altitude || 0)} m
            `;

            if (aircraftMarkers[icao24]) {
                // Actualizar posición existente
                aircraftMarkers[icao24].setLatLng([lat, lon]).setPopupContent(popup);
            } else {
                // Crear nuevo marcador
                const marker = L.marker([lat, lon])
                    .bindPopup(popup)
                    .addTo(map);
                aircraftMarkers[icao24] = marker;
            }
        });
    } catch (err) {
        console.error("Error al obtener datos de vuelos:", err);
    }
}

// Actualiza el mapa cada 10 segundos
fetchFlights();
setInterval(fetchFlights, 10000);
