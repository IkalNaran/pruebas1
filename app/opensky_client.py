import os
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
        headers = {}
        try:
            status = he.response.status_code
            headers = he.response.headers or {}
        except Exception:
            status = None
            headers = {}

        # handle rate limit specially
        if status == 429:
            retry_after = headers.get('Retry-After')
            ra = None
            try:
                ra = int(retry_after) if retry_after is not None else None
            except Exception:
                ra = None
            print(f"HTTP error consultando OpenSky API: 429 (rate limited). Retry-After={retry_after}")
            return {"error": "rate_limited", "status_code": 429, "retry_after": ra}

        print(f"HTTP error consultando OpenSky API: {he}")
        return {"error": str(he), "status_code": status}
    except requests.RequestException as e:
        print(f"Error consultando OpenSky API: {e}")
        return {"error": str(e), "status_code": None}
