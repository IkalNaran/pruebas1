import requests

BASE_URL = "https://opensky-network.org/api"

def get_all_states(
    lamin=18.8, lomin=-100.2, lamax=20.2, lomax=-98.6
):
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
