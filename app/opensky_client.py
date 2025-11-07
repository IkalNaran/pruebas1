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

