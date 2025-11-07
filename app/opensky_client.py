import os
import json
import requests
from pathlib import Path

BASE_URL = "https://opensky-network.org/api"
AUTH_URL = "https://auth.opensky-network.org/auth/realms/opensky-network/protocol/openid-connect/token"

def get_all_states(
    lamin=18.8, lomin=-100.2, lamax=20.2, lomax=-98.6
):
    """Obtiene datos de vuelos actuales (por defecto zona CDMX)."""
    url = f"{BASE_URL}/states/all"
    params = {}
    if all(v is not None for v in [lamin, lomin, lamax, lomax]):
        params.update({
            "lamin": lamin,
            "lomin": lomin,
            "lamax": lamax,
            "lomax": lomax
        })
        
        
    def get_access_token():
        """Obtiene un token de acceso usando clientId y clientSecret desde credentials.json."""
        creds_path = Path(__file__).parent / "credentials.json"

        if not creds_path.exists():
            print("No se encontró el archivo credentials.json")
            return None

        with open(creds_path, "r") as f:
            creds = json.load(f)

        client_id = creds.get("clientId")
        client_secret = creds.get("clientSecret")

        if not client_id or not client_secret:
            print("Faltan clientId o clientSecret en credentials.json")
            return None

        data = {
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret
        }

        try:
            response = requests.post(AUTH_URL, data=data, timeout=10)
            response.raise_for_status()
            token_data = response.json()
            return token_data.get("access_token")
        except requests.RequestException as e:
            print(f"Error al obtener el token de OpenSky: {e}")
            return None

    
    token = get_access_token()
    if not token:
        return {"error": "No se pudo obtener el token", "status_code": None}

    headers = {
        "Authorization": f"Bearer {token}",
        "User-Agent": "ZabbixFlights/1.0"
    }

    try:
        response = requests.get(url, params=params, timeout=10, headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.HTTPError as he:
        status = getattr(he.response, "status_code", None)
        print(f"HTTP error consultando OpenSky API: {he}")
        return {"error": str(he), "status_code": status}
    except requests.RequestException as e:
        print(f"Error consultando OpenSky API: {e}")
        return None

