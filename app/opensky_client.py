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
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        return data
    except requests.RequestException as e:
        print(f"Error consultando OpenSky API: {e}")
        return None
