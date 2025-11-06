// Dashboard JS: initialize Leaflet map, Chart.js chart, and Socket.IO connection.
// Data contracts (expected events):
// - 'flight_update': {icao24, callsign, lat, lon, altitude, heading, speed, last_seen}
// - 'flight_remove': {icao24}
// - 'zabbix_event': {type: 'trigger'|'recovery', host, severity, message, time}
// - 'status_update': {api: 'ok'|'warn'|'down', db:..., backend:..., zabbix:...}

(function(){
  // Safe-guard: run after DOM ready
  function ready(fn){
    if(document.readyState!='loading') fn(); else document.addEventListener('DOMContentLoaded',fn);
  }

  ready(function(){
    // Map init (center CDMX)
    var map = L.map('map').setView([19.4326, -99.1332], 10);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{
      maxZoom:19, attribution:'© OpenStreetMap contributors'
    }).addTo(map);

    // Markers store
    var markers = {};

    // Flights per minute chart (only initialize if canvas exists on the page)
    var flightsChart = null;
    (function(){
      var chartEl = document.getElementById('flightsChart');
      if(chartEl && chartEl.getContext && typeof Chart !== 'undefined'){
        try{
          var ctx = chartEl.getContext('2d');
          flightsChart = new Chart(ctx, {
            type: 'line',
            data: { labels: [], datasets: [{ label: 'Vuelos / min', data: [], borderColor:'#4ade80', backgroundColor:'rgba(74,222,128,0.1)', tension:0.2 }] },
            options: { responsive:true, scales:{x:{display:true}, y:{beginAtZero:true}} }
          });
        }catch(e){ console.warn('Could not init flightsChart',e); flightsChart = null; }
      }
    })();

    function pushChartPoint(value){
      // update chart if present
      if(flightsChart){
        var labels = flightsChart.data.labels;
        var data = flightsChart.data.datasets[0].data;
        var t = new Date().toLocaleTimeString();
        labels.push(t); data.push(value);
        if(labels.length>30){ labels.shift(); data.shift(); }
        flightsChart.update();
      }
      // always update avg-per-min element if present
      var avgEl = document.getElementById('avg-per-min');
      if(avgEl) avgEl.textContent = value;
    }

    // Utility: set card status
    function setCard(id, status){
      var el = document.getElementById(id+'-status');
      if(!el) return;
      el.textContent = status.toUpperCase();
      var parent = document.getElementById('card-'+id);
      if(!parent) return;
      parent.style.border = '2px solid '+(status=='ok'? '#b71212ff' : status=='warn'? '#f59e0b' : '#ef4444');
    }

    // Flights table renderer
    function renderFlightsTable(list){
      var root = document.getElementById('flights-table');
      if(!root) return;
      if(!list || list.length===0){ root.innerHTML = '<div>No hay vuelos</div>'; return; }
      var html = '<table class="flights-table"><thead><tr><th>Callsign</th><th>Alt</th><th>Vel</th><th>Últ.</th></tr></thead><tbody>';
      list.forEach(function(f){
        html += '<tr><td>'+ (f.callsign||f.icao24) +'</td><td>'+(f.altitude||'—')+'</td><td>'+(f.speed||'—')+'</td><td>'+new Date((f.last_seen||0)*1000).toLocaleTimeString()+'</td></tr>';
      });
      html += '</tbody></table>';
      root.innerHTML = html;
    }

    // Events list
    function pushEvent(e){
      var container = document.getElementById('events');
      if(!container) return;
      var div = document.createElement('div');
      div.className = 'event';
      div.innerHTML = '<strong>['+ (e.severity || e.type || 'info') +']</strong> '+ (e.message || JSON.stringify(e));
      container.insertBefore(div, container.firstChild);
      // keep limited
      while(container.children.length>50) container.removeChild(container.lastChild);
    }

    // Socket.IO connection (if available)
    var socket;
    try{
      socket = io();
    }catch(err){ console.warn('Socket.IO no disponible', err); }

  var currentFlights = {};

    // Filters state
    var currentFilters = { airline: '', altMin: null, altMax: null };

    // Create a simple rotated plane icon using an inline SVG inside a divIcon.
    function createPlaneIcon(heading, color){
      color = color || '#000000ff';
      var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24">'
        + '<g transform="translate(12 12)">'
        + '<path d="M0-10 L2 -2 L10 0 L2 2 L0 10 L-2 2 L-10 0 L-2 -2 Z" fill="'+color+'"/>'
        + '</g>'
        + '</svg>';
      var html = '<div class="plane-icon" style="transform: rotate('+ (heading||0) +'deg);">'+svg+'</div>';
      return L.divIcon({ className: 'plane-div-icon', html: html, iconSize: [28,28], iconAnchor: [14,14] });
    }

    function passesFilters(f){
      if(!f) return false;
      if(currentFilters.airline){
        var cs = (f.callsign||'').toUpperCase();
        if(!cs.startsWith(currentFilters.airline.toUpperCase())) return false;
      }
      if(currentFilters.altMin!=null){
        if(!(f.altitude!=null) || f.altitude < currentFilters.altMin) return false;
      }
      if(currentFilters.altMax!=null){
        if(!(f.altitude!=null) || f.altitude > currentFilters.altMax) return false;
      }
      return true;
    }

    // Reusable snapshot processor (list = array of flight objects with keys: icao24,callsign,lat,lon,altitude,speed,heading,last_seen)
    function processSnapshot(list){
      var seen = {};
      // collect airline options
      try{
        var airlineSet = new Set();
        list.forEach(function(d){ if(d.callsign){ airlineSet.add((d.callsign||'').substr(0,3).toUpperCase()); } });
        var sel = document.getElementById('filter-airline');
        if(sel){
          // preserve selection
          var prev = sel.value || '';
          sel.innerHTML = '<option value="">Todas</option>';
          Array.from(airlineSet).sort().forEach(function(a){ if(a && a.trim()!='') sel.innerHTML += '<option value="'+a+'">'+a+'</option>'; });
          sel.value = prev;
        }
      }catch(e){}

      list.forEach(function(data){
        var id = data.icao24;
        if(!id) return;
        seen[id]=true;
        currentFlights[id]=data;
        var shouldShow = passesFilters(data);
        if(markers[id]){
          markers[id].setLatLng([data.lat, data.lon]);
          // update icon rotation
          var el = markers[id].getElement && markers[id].getElement();
          if(el){ el.style.transform = 'rotate('+(data.heading||0)+'deg)'; }
          markers[id].bindPopup('<b>'+ (data.callsign||id) +'</b><br>Alt: '+(data.altitude||'—'));
          // show/hide based on filter
          if(shouldShow) markers[id].getElement && (markers[id].getElement().style.display=''); else markers[id].getElement && (markers[id].getElement().style.display='none');
        } else {
          // create div icon rotated
          var icon = createPlaneIcon(data.heading||0);
          var m = L.marker([data.lat, data.lon], {icon: icon}).addTo(map);
          m.bindPopup('<b>'+ (data.callsign||id) +'</b><br>Alt: '+(data.altitude||'—'));
          markers[id]=m;
          if(!shouldShow){
            var el2 = m.getElement && m.getElement(); if(el2) el2.style.display='none';
          }
        }
      });
      // remove markers not present
      Object.keys(markers).forEach(function(id){
        if(!seen[id]){
          map.removeLayer(markers[id]);
          delete markers[id];
          delete currentFlights[id];
        }
      });
      var totalEl = document.getElementById('total-flights'); if(totalEl) totalEl.textContent = Object.keys(currentFlights).length;
      renderFlightsTable(Object.values(currentFlights).slice(0,50));
    }

    // Apply filters from UI to existing markers (use when filters change)
    function applyFiltersToMarkers(){
      Object.keys(currentFlights).forEach(function(id){
        var f = currentFlights[id];
        var m = markers[id];
        if(!m) return;
        var should = passesFilters(f);
        var el = m.getElement && m.getElement();
        if(el){ el.style.display = should ? '' : 'none'; }
      });
      var totalEl2 = document.getElementById('total-flights'); if(totalEl2) totalEl2.textContent = Object.keys(currentFlights).filter(function(k){ return passesFilters(currentFlights[k]); }).length;
      renderFlightsTable(Object.values(currentFlights).filter(function(f){ return passesFilters(f); }).slice(0,50));
    }

    if(socket){
      socket.on('connect', function(){ console.log('socket connected'); });

      socket.on('flight_update', function(data){
        // place/update marker
        try{
          var id = data.icao24;
          currentFlights[id] = data;
          var shouldShow = passesFilters(data);
          if(markers[id]){
            markers[id].setLatLng([data.lat, data.lon]);
            var el = markers[id].getElement && markers[id].getElement();
            if(el){ el.style.transform = 'rotate('+(data.heading||0)+'deg)'; el.style.display = shouldShow ? '' : 'none'; }
            markers[id].bindPopup('<b>'+ (data.callsign||id) +'</b><br>Alt: '+(data.altitude||'—'));
          } else {
            var icon = createPlaneIcon(data.heading||0);
            var m = L.marker([data.lat, data.lon], {icon: icon}).addTo(map);
            m.bindPopup('<b>'+ (data.callsign||id) +'</b><br>Alt: '+(data.altitude||'—'));
            markers[id]=m;
            if(!shouldShow){ var el2 = m.getElement && m.getElement(); if(el2) el2.style.display='none'; }
          }
          // update summary and table (apply filters)
          applyFiltersToMarkers();
        }catch(e){ console.error(e); }
      });

      // snapshot handler: full list of flights
      socket.on('flights_snapshot', function(list){
        try{
          processSnapshot(list);
        }catch(e){ console.error(e); }
      });

      // If socket disconnects, periodic REST polling will be used as a fallback (see below)

      socket.on('flight_remove', function(data){
        var id = data.icao24;
        if(markers[id]){ map.removeLayer(markers[id]); delete markers[id]; }
        delete currentFlights[id];
        var totalEl3 = document.getElementById('total-flights'); if(totalEl3) totalEl3.textContent = Object.keys(currentFlights).length;
        renderFlightsTable(Object.values(currentFlights).slice(0,50));
      });

      socket.on('zabbix_event', function(e){
        pushEvent(e);
        document.getElementById('last-trigger').textContent = e.message || e.host || 'trigger';
      });

      socket.on('status_update', function(s){
        if(s.api) setCard('api', s.api);
        if(s.db) setCard('db', s.db);
        if(s.backend) setCard('backend', s.backend);
        if(s.zabbix) setCard('zabbix', s.zabbix);
      });

      socket.on('flights_per_min', function(n){
        document.getElementById('avg-per-min').textContent = n;
        pushChartPoint(n);
      });
    } else {
      // no socket: show placeholder sample data
      setTimeout(function(){
        pushEvent({type:'info', message:'Socket.IO no conectado — usando datos de ejemplo'});
        pushChartPoint(3);
        pushChartPoint(5);
        pushChartPoint(4);
      },500);
    }

    // --- REST fallback: fetch initial snapshot from project API and poll periodically ---
    var BBOX = { lamin: 18.90, lomin: -99.60, lamax: 19.80, lomax: -98.90 };
    function fetchInitial(){
      var url = '/api/opensky?lamin='+BBOX.lamin+'&lomin='+BBOX.lomin+'&lamax='+BBOX.lamax+'&lomax='+BBOX.lomax;
      fetch(url).then(function(res){
        if(!res.ok) throw new Error('HTTP '+res.status);
        return res.json();
      }).then(function(data){
        // OpenSky returns { time:..., states: [...] }
        if(data && data.states){
          var list = [];
          data.states.forEach(function(s){
            // s is an array per OpenSky spec
            try{
              var icao24 = s[0];
              var callsign = (s[1]||'').trim();
              var lon = s[5];
              var lat = s[6];
              var altitude = s[7];
              var velocity = s[9];
              var heading = s[10];
              var last_seen = s[4];
              if(lat==null||lon==null) return;
              list.push({icao24:icao24,callsign:callsign,lat:lat,lon:lon,altitude:altitude,speed:velocity,heading:heading,last_seen:last_seen});
            }catch(e){}
          });
          processSnapshot(list);
        }
      }).catch(function(err){
        console.warn('Error fetching /api/opensky',err);
      });
    }

    // fetch once on load
    fetchInitial();
    // poll every 15s as a fallback when socket is not available
    setInterval(fetchInitial, 15000);

    // Wire filter UI
    try{
      var applyBtn = document.getElementById('apply-filters');
      var clearBtn = document.getElementById('clear-filters');
      var selAir = document.getElementById('filter-airline');
      var altMin = document.getElementById('filter-alt-min');
      var altMax = document.getElementById('filter-alt-max');
      if(applyBtn){
        applyBtn.addEventListener('click', function(){
          currentFilters.airline = selAir && selAir.value ? selAir.value : '';
          currentFilters.altMin = altMin && altMin.value ? Number(altMin.value) : null;
          currentFilters.altMax = altMax && altMax.value ? Number(altMax.value) : null;
          applyFiltersToMarkers();
        });
      }
      if(clearBtn){
        clearBtn.addEventListener('click', function(){
          if(selAir) selAir.value = '';
          if(altMin) altMin.value = '';
          if(altMax) altMax.value = '';
          currentFilters = { airline:'', altMin:null, altMax:null };
          applyFiltersToMarkers();
        });
      }
    }catch(e){ console.warn('Filter UI wiring failed',e); }

  });
})();
