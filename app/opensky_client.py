import os
import json
import requests
from pathlib import Path

BASE_URL = "https://opensky-network.org/api"
AUTH_URL = "https://auth.opensky-network.org/auth/realms/opensky-network/protocol/openid-connect/token"

def get_credentials():
    client_id = os.getenv("OPENSKY_CLIENT_ID")
    client_secret = os.getenv("OPENSKY_CLIENT_SECRET")

    if client_id and client_secret:
        return client_id, client_secret
    
    cred_file = Path("credentials.json")
    if cred_file.exists():
        try:
            with open(cred_file) as f:
                creds = json.load(f)
            return creds.get("clientId"), creds.get("clientSecret")
        except (json.JSONDecodeError, KeyError) as e:
            print(f"Error leyendo credential.json: {e}")
    return None, None    

def get_access_token():
    """Obtiene el token OAuth2 usando client_credentials."""
    try:
        client_id, client_secret = get_credentials()
        
        if not client_id or not client_secret:
            print("Error: No se encontraron credenciales. Configura las variables de entorno OPENSKY_CLIENT_ID y OPENSKY_CLIENT_SECRET, o crea un archivo credentials.json")
            return None
        
        auth_data = {
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret
        }
        auth_headers = {"Content-Type": "application/x-www-form-urlencoded"}
        response = requests.post(AUTH_URL, data=auth_data, headers=auth_headers)
        response.raise_for_status()
        token = response.json().get("access_token")
        if not token:
            print("Error: token no recibido:", response.text)
            return None
        return token
    except Exception as e:
        print(f"Error al obtener el token: {e}")
        return None
    
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

