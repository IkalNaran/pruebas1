import requests

BASE_URL = "https://opensky-network.org/api"

def get_all_states(
    lamin=18.8, lomin=-100.2, lamax=20.2, lomax=-98.6
):
    """
    Obtiene datos de vuelos actuales desde OpenSky.
    Por defecto, usa coordenadas aproximadas de la CDMX y alrededores.
    """
    url = f"{BASE_URL}/states/all"
    params = {
        "lamin": lamin,
        "lomin": lomin,
        "lamax": lamax,
        "lomax": lomax
    }

    try:
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        return data
    except requests.RequestException as e:
        print(f"Error consultando OpenSky API: {e}")
        return None
