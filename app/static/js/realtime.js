// Crear mapa centrado en Europa
const map = L.map('map').setView([48.5, 9.0], 5);

// Capa base (OpenStreetMap)
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 10,
    attribution: '© OpenStreetMap contributors'
}).addTo(map);

let aircraftMarkers = {};

async function fetchFlights() {
    try {
        const lamin = 35;
        const lamax = 55;
        const lomin = -10;
        const lomax = 20;

        const response = await fetch(`/api/opensky?lamin=${lamin}&lomin=${lomin}&lamax=${lamax}&lomax=${lomax}`);
        const data = await response.json();

        if (!data.states) return;

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
    console.log("Vuelos recibidos:", data.states?.length || 0);

}

// Actualiza el mapa cada 10 segundos
fetchFlights();
setInterval(fetchFlights, 10000);
