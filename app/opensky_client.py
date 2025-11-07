import os
import json
import time
import requests

BASE_URL = "https://opensky-network.org/api"
_CACHE_FILE = os.path.join(os.path.dirname(__file__), 'cache', 'opensky_last.json')
# Optional bootstrap snapshot used when API fails and no cache exists yet
_BOOTSTRAP_FILE = os.environ.get(
    'OPEN_SKY_BOOTSTRAP_JSON',
    os.path.join(os.path.dirname(__file__), 'data', 'bootstrap_opensky.json')
)


def _read_json_credentials():
    """Read OpenSky credentials from a JSON file.
    Priority: env var OPEN_SKY_CREDENTIALS_JSON; else default app/config/opensky.json.
    Accepts keys: username/password or user/pass or OPEN_SKY_USER/OPEN_SKY_PASS.
    Returns tuple (user, pwd) or (None, None).
    """
    path = os.environ.get('OPEN_SKY_CREDENTIALS_JSON')
    if not path:
        base_dir = os.path.dirname(__file__)
        default_paths = [
            os.path.join(base_dir, 'config', 'opensky.json'),
            os.path.join(base_dir, 'credentials.json'),  # fallback to project credentials file
        ]
        for p in default_paths:
            if os.path.exists(p):
                path = p
                break
    if path and os.path.exists(path):
        try:
            with open(path, 'r') as f:
                cfg = json.load(f)
            # Accept common key variants; also map clientId/clientSecret if provided
            user = (
                cfg.get('username') or cfg.get('user') or cfg.get('OPEN_SKY_USER') or cfg.get('IsaacMdzXhdz')
            )
            pwd = (
                cfg.get('password') or cfg.get('pass') or cfg.get('OPEN_SKY_PASS') or cfg.get('Isaacmdz13')
            )
            if user and pwd:
                return user, pwd
        except Exception:
            pass
    return None, None

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
        if not (user and pwd):
            ju, jp = _read_json_credentials()
            if ju and jp:
                user, pwd = ju, jp
        if user and pwd:
            auth = (user, pwd)
        headers = {'User-Agent': 'ZabbixFlights/1.0'}
        response = requests.get(url, params=params, timeout=10, auth=auth, headers=headers)
        response.raise_for_status()
        data = response.json()
        # persist to disk cache if contains states
        try:
            if isinstance(data, dict) and data.get('states') is not None:
                os.makedirs(os.path.dirname(_CACHE_FILE), exist_ok=True)
                with open(_CACHE_FILE, 'w') as f:
                    json.dump(data, f)
        except Exception:
            pass
        return data
    except requests.HTTPError as he:
        # HTTP errors (e.g. 429 rate limit) -> return an error dict so caller can react
        status = None
        try:
            status = he.response.status_code
        except Exception:
            status = None
        # On 401/429 or other HTTP errors, try to return last cached snapshot if available
        try:
            if os.path.exists(_CACHE_FILE):
                with open(_CACHE_FILE, 'r') as f:
                    cached = json.load(f)
                if isinstance(cached, dict) and cached.get('states') is not None:
                    cached['cached'] = True
                    return cached
            # Fallback to bootstrap snapshot if present
            if _BOOTSTRAP_FILE and os.path.exists(_BOOTSTRAP_FILE):
                with open(_BOOTSTRAP_FILE, 'r') as f:
                    bootstrap = json.load(f)
                if isinstance(bootstrap, dict) and bootstrap.get('states') is not None:
                    # Stamp a current-ish time and mark as bootstrap
                    bootstrap = dict(bootstrap)
                    bootstrap['time'] = int(time.time())
                    bootstrap['cached'] = True
                    bootstrap['bootstrap'] = True
                    return bootstrap
        except Exception:
            pass
        print(f"HTTP error consultando OpenSky API: {he}")
        return {"error": str(he), "status_code": status}
    except requests.RequestException as e:
        # On network error, try to return cached snapshot
        try:
            if os.path.exists(_CACHE_FILE):
                with open(_CACHE_FILE, 'r') as f:
                    cached = json.load(f)
                if isinstance(cached, dict) and cached.get('states') is not None:
                    cached['cached'] = True
                    return cached
            # Fallback to bootstrap snapshot if present
            if _BOOTSTRAP_FILE and os.path.exists(_BOOTSTRAP_FILE):
                with open(_BOOTSTRAP_FILE, 'r') as f:
                    bootstrap = json.load(f)
                if isinstance(bootstrap, dict) and bootstrap.get('states') is not None:
                    bootstrap = dict(bootstrap)
                    bootstrap['time'] = int(time.time())
                    bootstrap['cached'] = True
                    bootstrap['bootstrap'] = True
                    return bootstrap
        except Exception:
            pass
        print(f"Error consultando OpenSky API: {e}")
        return {"error": str(e), "status_code": None}
