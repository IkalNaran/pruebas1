import time
from threading import Event
from app.opensky_client import get_all_states
from app import socketio

# Bounding box for Mexico City (approx)
LAMIN = 18.90
LOMIN = -99.60
LAMAX = 19.80
LOMAX = -98.90

stop_event = Event()

def _parse_states(data):
    """Parse OpenSky /states/all response into a list of flight dicts."""
    if not data or 'states' not in data or not data['states']:
        return []

    flights = []
    for s in data['states']:
        # OpenSky state vector format (index):
        # 0: icao24, 1: callsign, 5: longitude, 6: latitude, 7: baro_altitude,
        # 9: velocity, 10: true_track, 4: last_contact
        try:
            icao24 = s[0]
            callsign = (s[1] or '').strip() if s[1] else ''
            lon = s[5]
            lat = s[6]
            altitude = s[7]
            velocity = s[9]
            heading = s[10]
            last_seen = s[4]
            if lat is None or lon is None:
                continue
            flights.append({
                'icao24': icao24,
                'callsign': callsign,
                'lat': lat,
                'lon': lon,
                'altitude': altitude,
                'speed': velocity,
                'heading': heading,
                'last_seen': last_seen
            })
        except Exception:
            continue

    return flights


def _poll_opensky(interval_seconds=5):
    """Background task: poll OpenSky and emit snapshots via Socket.IO."""
    # simple sliding window to estimate flights per minute
    history = []  # timestamps of snapshots (counts)
    while not stop_event.is_set():
        data = get_all_states(LAMIN, LOMIN, LAMAX, LOMAX)
        if data is None:
            # emit status down
            try:
                socketio.emit('status_update', {'api': 'down'}, namespace='/')
            except Exception:
                pass
            time.sleep(interval_seconds)
            continue

        flights = _parse_states(data)
        try:
            # Emit a snapshot (list) — dashboard will diff/create markers
            socketio.emit('flights_snapshot', flights, namespace='/')
            # status ok
            socketio.emit('status_update', {'api': 'ok'}, namespace='/')
        except Exception:
            pass

        # record history length for simple per-minute metric
        now = time.time()
        history.append((now, len(flights)))
        # drop older than 70 seconds
        history = [(t,c) for (t,c) in history if now - t < 70]
        # compute approx average (mean of last entries)
        avg = 0
        if history:
            avg = int(sum(c for (_,c) in history)/len(history))
        try:
            socketio.emit('flights_per_min', avg, namespace='/')
        except Exception:
            pass

        time.sleep(interval_seconds)


def start_background_tasks(app=None):
    """Start the polling background task. Call this once after SocketIO is initialized."""
    # start background using socketio helper
    try:
        socketio.start_background_task(_poll_opensky)
    except Exception:
        # fallback to plain thread if start_background_task unavailable
        import threading
        t = threading.Thread(target=_poll_opensky, daemon=True)
        t.start()
