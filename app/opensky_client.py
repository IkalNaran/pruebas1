import os
import requests

BASE_URL = "https://opensky-network.org/api"

def get_all_states(lamin=None, lomin=None, lamax=None, lomax=None):
    """
    Obtiene datos de vuelos actuales. Puede filtrar por área geográfica.
    """
    url = f"{BASE_URL}/states/all"
    params = {}

    if all(v is not None for v in [lamin, lomin, lamax, lomax]):
        params.update({
            "lamin": lamin,
            "lomin": lomin,
            "lamax": lamax,
            "lomax": lomax
        })

    try:
        # Optional Basic Auth to increase rate limits
        auth = None
        user = os.environ.get('OPEN_SKY_USER')
        pwd = os.environ.get('OPEN_SKY_PASS')
        if user and pwd:
            auth = (user, pwd)
        headers = {'User-Agent': 'ZabbixFlights/1.0'}
        response = requests.get(url, params=params, timeout=10, auth=auth, headers=headers)
        response.raise_for_status()
        data = response.json()
        return data
    except requests.HTTPError as he:
        # HTTP errors (e.g. 429 rate limit) -> return an error dict so caller can react
        status = None
        try:
            status = he.response.status_code
        except Exception:
            status = None
        print(f"HTTP error consultando OpenSky API: {he}")
        return {"error": str(he), "status_code": status}
    except requests.RequestException as e:
        print(f"Error consultando OpenSky API: {e}")
        return {"error": str(e), "status_code": None}
