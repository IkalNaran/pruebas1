import time
import math
from threading import Event, Thread
from app.providers import get_states_any
from app import socketio

# Bounding box for Mexico City (approx)
LAMIN = 18.90
LOMIN = -99.60
LAMAX = 19.80
LOMAX = -98.90

stop_event = Event()
_current_flights = {}
_last_snapshot_ts = 0.0

def _parse_states(data):
    """Parse OpenSky /states/all response into a list of flight dicts."""
    if not data or 'states' not in data or not data['states']:
        return []

    flights = []
    for s in data['states']:
        # OpenSky state vector format (index):
        # 0: icao24, 1: callsign, 2: origin_country, 4: last_contact,
        # 5: longitude, 6: latitude, 7: baro_altitude, 8: on_ground,
        # 9: velocity, 10: true_track, 11: vertical_rate, 13: geo_altitude, 14: squawk
        try:
            icao24 = s[0]
            callsign = (s[1] or '').strip() if s[1] else ''
            origin_country = s[2] if len(s) > 2 else None
            lon = s[5]
            lat = s[6]
            altitude = s[7]
            on_ground = s[8] if len(s) > 8 else None
            velocity = s[9]
            heading = s[10]
            last_seen = s[4]
            vrate = s[11] if len(s) > 11 else None
            geo_alt = s[13] if len(s) > 13 else None
            squawk = s[14] if len(s) > 14 else None
            if lat is None or lon is None:
                continue
            flights.append({
                'icao24': icao24,
                'callsign': callsign,
                'country': origin_country,
                'origin_country': origin_country,
                'lat': lat,
                'lon': lon,
                'altitude': altitude,
                'geo_altitude': geo_alt,
                'speed': velocity,
                'heading': heading,
                'vrate': vrate,
                'on_ground': on_ground,
                'squawk': squawk,
                'dest_country': None,
                'last_seen': last_seen
            })
        except Exception:
            continue

    return flights


def _poll_opensky(interval_seconds=15):
    """Background task: poll OpenSky and emit snapshots via Socket.IO."""
    # simple sliding window to estimate flights per minute
    history = []  # timestamps of snapshots (counts)
    while not stop_event.is_set():
        data = get_states_any(LAMIN, LOMIN, LAMAX, LOMAX)
        # get_all_states may return a dict with 'error' and 'status_code' on failure
        if data is None or (isinstance(data, dict) and data.get('error')):
            # Rate limit (429) -> backoff longer
            status_code = None
            try:
                status_code = data.get('status_code') if isinstance(data, dict) else None
            except Exception:
                status_code = None

            if status_code == 429:
                # emit warning and sleep longer to avoid hammering the API
                try:
                    socketio.emit('status_update', {'api': 'warn'}, namespace='/')
                except Exception:
                    pass
                # longer backoff when rate limited
                time.sleep(max(interval_seconds, 30))
                continue

            # Other errors -> mark as down and retry later
            try:
                socketio.emit('status_update', {'api': 'down'}, namespace='/')
            except Exception:
                pass
            time.sleep(interval_seconds)
            continue

        # if data came from cache/bootstrap, mark status as warn later
        is_cached = isinstance(data, dict) and (data.get('cached') is True or data.get('bootstrap') is True)
        flights = _parse_states(data)
        now = time.time()
        # Try to derive speed/heading if missing using previous snapshot
        try:
            prev_map = dict(_current_flights) if _current_flights else {}
            dt_global = max(1.0, now - _last_snapshot_ts) if _last_snapshot_ts else None
            for f in flights:
                icao = f.get('icao24')
                if not icao:
                    continue
                # If missing speed or heading, estimate from previous position
                if (f.get('speed') in (None, 0)) or (f.get('heading') is None):
                    prev = prev_map.get(icao)
                    if prev and prev.get('lat') is not None and prev.get('lon') is not None and dt_global:
                        # Haversine distance (meters) and bearing (degrees)
                        try:
                            lat1 = math.radians(prev['lat']); lon1 = math.radians(prev['lon'])
                            lat2 = math.radians(f['lat']);    lon2 = math.radians(f['lon'])
                            dlat = lat2 - lat1; dlon = lon2 - lon1
                            a = math.sin(dlat/2)**2 + math.cos(lat1)*math.cos(lat2)*math.sin(dlon/2)**2
                            c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
                            distance = 6371000.0 * c
                            speed = distance / dt_global if dt_global else 0
                            y = math.sin(dlon) * math.cos(lat2)
                            x = math.cos(lat1)*math.sin(lat2) - math.sin(lat1)*math.cos(lat2)*math.cos(dlon)
                            bearing = (math.degrees(math.atan2(y, x)) + 360.0) % 360.0
                            if f.get('speed') in (None, 0):
                                f['speed'] = speed
                            if f.get('heading') is None:
                                f['heading'] = bearing
                        except Exception:
                            pass
        except Exception:
            pass
        # Mark fresh snapshot flights as not estimated
        for f in flights:
            f['estimated'] = False
        # store snapshot for predictive movement
        global _current_flights, _last_snapshot_ts
        _current_flights = {f['icao24']: f for f in flights if f.get('icao24')}
        _last_snapshot_ts = now
        try:
            # Emit a snapshot (list) — dashboard will diff/create markers
            socketio.emit('flights_snapshot', flights, namespace='/')
            # status ok if live, warn if cached snapshot
            provider = None
            try:
                provider = data.get('provider') if isinstance(data, dict) else None
            except Exception:
                provider = None
            socketio.emit('status_update', {'api': 'warn' if is_cached else 'ok', 'provider': provider}, namespace='/')
            # Optionally emit individual updates (limited) to keep markers moving per-flight
            for f in flights[:80]:
                socketio.emit('flight_update', f, namespace='/')
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

    # Start predictive movement emitter (dead-reckoning) to animate markers between snapshots.
    def _predictive_motion_loop():
        # run until stop
        last_emit = time.time()
        while not stop_event.is_set():
            now = time.time()
            dt = now - last_emit
            last_emit = now
            # Only proceed if we have a recent snapshot (within 90s)
            if now - _last_snapshot_ts > 90:
                time.sleep(1)
                continue
            updated = []
            for icao, f in list(_current_flights.items()):
                try:
                    speed = f.get('speed')  # m/s
                    heading = f.get('heading')  # degrees (true_track)
                    lat = f.get('lat')
                    lon = f.get('lon')
                    if speed is None or heading is None or lat is None or lon is None:
                        continue
                    # Clamp unrealistic speeds
                    if speed <= 0 or speed > 350:  # ignore if stationary or unrealistic for snapshot
                        continue
                    # Dead-reckoning simple equirectangular approximation
                    distance = speed * dt  # meters traveled since last iteration
                    # Convert heading degrees to radians
                    rad = math.radians(heading)
                    # Approx degree conversions
                    dlat = (distance * math.cos(rad)) / 111320.0
                    # prevent division by zero at poles (not relevant here)
                    dlon = (distance * math.sin(rad)) / (111320.0 * math.cos(math.radians(lat)))
                    new_lat = lat + dlat
                    new_lon = lon + dlon
                    # Keep inside an expanded bounding box (slightly larger than query area)
                    if new_lat < LAMIN - 0.5 or new_lat > LAMAX + 0.5 or new_lon < LOMIN - 0.5 or new_lon > LOMAX + 0.5:
                        continue
                    # Update stored flight
                    f['lat'] = new_lat
                    f['lon'] = new_lon
                    f['last_seen'] = int(now)
                    f['estimated'] = True
                    updated.append(f)
                except Exception:
                    continue
            # Emit per-flight updates (limit to 120 to avoid flooding)
            if updated:
                try:
                    for uf in updated[:120]:
                        socketio.emit('flight_update', uf, namespace='/')
                except Exception:
                    pass
            time.sleep(1)

    try:
        socketio.start_background_task(_predictive_motion_loop)
    except Exception:
        Thread(target=_predictive_motion_loop, daemon=True).start()
