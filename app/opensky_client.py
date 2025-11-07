import os
import json
import time
import requests

BASE_URL = "https://opensky-network.org/api"
AUTH_URL = "https://auth.opensky-network.org/auth/realms/opensky-network/protocol/openid-connect/token"
_CACHE_FILE = os.path.join(os.path.dirname(__file__), 'cache', 'opensky_last.json')
_BOOTSTRAP_FILE = os.environ.get(
    'OPEN_SKY_BOOTSTRAP_JSON',
    os.path.join(os.path.dirname(__file__), 'data', 'bootstrap_opensky.json')
)

def _read_oauth_credentials():
    """Lee credenciales OAuth2 desde JSON file."""
    path = os.environ.get('OPEN_SKY_CREDENTIALS_JSON')
    if not path:
        base_dir = os.path.dirname(__file__)
        default_paths = [
            os.path.join(base_dir, 'config', 'opensky.json'),
            os.path.join(base_dir, 'credentials.json'),
        ]
        for p in default_paths:
            if os.path.exists(p):
                path = p
                break
    
    if path and os.path.exists(path):
        try:
            with open(path, 'r') as f:
                cfg = json.load(f)
            # Busca clientId/clientSecret con diferentes nombres
            client_id = (cfg.get('clientId') or cfg.get('client_id') or 
                        cfg.get('OPEN_SKY_CLIENT_ID'))
            client_secret = (cfg.get('clientSecret') or cfg.get('client_secret') or 
                           cfg.get('OPEN_SKY_CLIENT_SECRET'))
            
            if client_id and client_secret:
                return client_id, client_secret
        except Exception as e:
            print(f"Error leyendo credenciales: {e}")
    
    return None, None

def get_access_token():
    """Obtiene token OAuth2 usando client_credentials."""
    client_id, client_secret = _read_oauth_credentials()
    
    if not client_id or not client_secret:
        print("Error: No se encontraron credenciales OAuth2")
        return None
    
    try:
        auth_data = {
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret
        }
        auth_headers = {"Content-Type": "application/x-www-form-urlencoded"}
        
        response = requests.post(AUTH_URL, data=auth_data, headers=auth_headers, timeout=10)
        response.raise_for_status()
        
        token = response.json().get("access_token")
        if not token:
            print("Error: token no recibido:", response.text)
            return None
        
        return token
    except Exception as e:
        print(f"Error al obtener el token: {e}")
        return None

def get_all_states(lamin=None, lomin=None, lamax=None, lomax=None):
    """Obtiene datos de vuelos actuales con cache y fallback."""
    url = f"{BASE_URL}/states/all"
    params = {}
    
    if all(v is not None for v in [lamin, lomin, lamax, lomax]):
        params.update({
            "lamin": lamin,
            "lomin": lomin,
            "lamax": lamax,
            "lomax": lomax
        })

    # Intentar obtener token OAuth2
    token = get_access_token()
    if not token:
        # Fallback a cache si no se puede obtener token
        return _get_cached_or_bootstrap()
    
    headers = {
        "Authorization": f"Bearer {token}",
        "User-Agent": "ZabbixFlights/1.0"
    }

    try:
        response = requests.get(url, params=params, timeout=10, headers=headers)
        response.raise_for_status()
        data = response.json()
        
        # Persistir a cache si contiene states
        _save_to_cache(data)
        return data
        
    except requests.HTTPError as he:
        status = getattr(he.response, "status_code", None)
        print(f"HTTP error consultando OpenSky API: {he}")
        return _get_cached_or_bootstrap(he, status)
        
    except requests.RequestException as e:
        print(f"Error consultando OpenSky API: {e}")
        return _get_cached_or_bootstrap(e, None)

def _save_to_cache(data):
    """Guarda datos en cache si son válidos."""
    try:
        if isinstance(data, dict) and data.get('states') is not None:
            os.makedirs(os.path.dirname(_CACHE_FILE), exist_ok=True)
            with open(_CACHE_FILE, 'w') as f:
                json.dump(data, f)
    except Exception as e:
        print(f"Error guardando cache: {e}")

def _get_cached_or_bootstrap(error=None, status_code=None):
    """Intenta obtener datos de cache o bootstrap."""
    # Primero intentar cache
    try:
        if os.path.exists(_CACHE_FILE):
            with open(_CACHE_FILE, 'r') as f:
                cached = json.load(f)
            if isinstance(cached, dict) and cached.get('states') is not None:
                cached['cached'] = True
                cached['time'] = int(time.time())  # Actualizar timestamp
                return cached
    except Exception:
        pass
    
    # Fallback a bootstrap
    try:
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
    
    # Si todo falla, retornar error
    result = {"error": str(error) if error else "No se pudo obtener datos", "status_code": status_code}
    if not error:
        result["error"] = "No se pudo conectar a OpenSky y no hay datos cacheados"
    return result