// Dashboard client: optional Leaflet map + markers, DataTables tables, Socket.IO + REST fallback, advanced filters and chips, and index cards updates.
(function(){
  function onReady(fn){ if(document.readyState!=='loading') fn(); else document.addEventListener('DOMContentLoaded', fn); }

  onReady(function(){
    // Optional map (only if #map exists)
    var map = null;
    var markers = {};
    var mapEl = document.getElementById('map');
    if(mapEl && typeof L !== 'undefined'){
      try{
        map = L.map('map').setView([19.4326, -99.1332], 10);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{
          maxZoom:19, attribution:'© OpenStreetMap contributors'
        }).addTo(map);
      }catch(e){ console.warn('Leaflet init failed', e); map=null; }
    }

    // Socket (optional)
    var socket = null;
    try{ socket = io(); }catch(e){ console.warn('Socket.IO no disponible', e); }

    // Chart (only on monitoring page)
    var flightsChart = null;
    (function(){
      var chartEl = document.getElementById('flightsChart');
      if(chartEl && chartEl.getContext && typeof Chart !== 'undefined'){
        try{
          var ctx = chartEl.getContext('2d');
          flightsChart = new Chart(ctx, {
            type: 'line',
            data: { labels: [], datasets: [{ label: 'Vuelos / min', data: [], borderColor:'#4ade80', backgroundColor:'rgba(74,222,128,0.1)', tension:0.25 }] },
            options: { responsive:true, scales:{x:{display:true}, y:{beginAtZero:true}} }
          });
        }catch(e){ flightsChart=null; }
      }
    })();

    function pushChartPoint(value){
      if(flightsChart){
        var t = new Date().toLocaleTimeString();
        var labels = flightsChart.data.labels;
        var data = flightsChart.data.datasets[0].data;
        labels.push(t); data.push(value);
        if(labels.length>60){ labels.shift(); data.shift(); }
        flightsChart.update();
      }
      var avgEl = document.getElementById('avg-per-min'); if(avgEl) avgEl.textContent = value;
    }

    // State
    var currentFlights = {};
    var currentFilters = { airline:'', type:'', altMin:null, altMax:null, speedMin:null, speedMax:null };

    // UI helpers
    function setCard(id, status){
      var el = document.getElementById(id+'-status'); if(el) el.textContent = status ? status.toUpperCase() : '—';
      var parent = document.getElementById('card-'+id);
      if(parent){
        var color = status==='ok' ? 'var(--accent)' : status==='warn' ? '#f59e0b' : status==='down' ? '#ef4444' : 'var(--card-border)';
        parent.style.border = '2px solid '+color;
      }
    }
    function updateApiIndicator(status){
      var wrapper = document.getElementById('api-indicator');
      var textEl = document.getElementById('api-indicator-text');
      var timeEl = document.getElementById('api-last-checked');
      if(!wrapper || !textEl) return;
      wrapper.classList.remove('status-ok','status-warn','status-down','status-unknown');
      var cls = 'status-unknown'; var readable = 'API OpenSky: desconocido';
      if(status==='ok'){ cls='status-ok'; readable='API OpenSky: OK'; }
      else if(status==='warn'){ cls='status-warn'; readable='API OpenSky: Limitada'; }
      else if(status==='down'){ cls='status-down'; readable='API OpenSky: Caída'; }
      wrapper.classList.add(cls); textEl.textContent = readable;
      if(timeEl) timeEl.textContent = new Date().toLocaleTimeString();
    }

    function createPlaneIcon(heading){
      if(!L || !L.divIcon) return null;
      var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24">'
        + '<g transform="translate(12 12)">'
        + '<path d="M0-10 L2 -2 L10 0 L2 2 L0 10 L-2 2 L-10 0 L-2 -2 Z" fill="#1f2937"/>'
        + '</g>'
        + '</svg>';
      var html = '<div class="plane-div-icon" style="transform: rotate('+ (heading||0) +'deg);">'+svg+'</div>';
      return L.divIcon({ className:'plane-div-icon', html: html, iconSize:[28,28], iconAnchor:[14,14] });
    }

    function inferFlightType(f){
      var cs = (f.callsign||'').trim().toUpperCase();
      if(!cs) return 'unknown';
      // naive inference: airline codes 2-3 letters then digits => commercial
      if(/^[A-Z]{2,3}\d{1,4}/.test(cs)) return 'commercial';
      // Mexican private regs start with XB-, XA-, XC-
      if(/^X[ABC]-?/.test(cs) || /^N\d{1,5}/.test(cs)) return 'private';
      // business jets often EJM, XOJ, etc. Heuristic fallback
      if(/(EJM|XOJ|GA|PRV)/.test(cs)) return 'business';
      return 'unknown';
    }

    function passesFilters(f){
      if(!f) return false;
      if(currentFilters.type){
        var t = f.type || inferFlightType(f);
        if(t !== currentFilters.type) return false;
      }
      if(currentFilters.airline){
        var cs = (f.callsign||'').toUpperCase();
        if(!cs.startsWith(currentFilters.airline.toUpperCase())) return false;
      }
      if(currentFilters.altMin!=null){ if(!(f.altitude!=null) || f.altitude < currentFilters.altMin) return false; }
      if(currentFilters.altMax!=null){ if(!(f.altitude!=null) || f.altitude > currentFilters.altMax) return false; }
      if(currentFilters.speedMin!=null){ if(!(f.speed!=null) || f.speed < currentFilters.speedMin) return false; }
      if(currentFilters.speedMax!=null){ if(!(f.speed!=null) || f.speed > currentFilters.speedMax) return false; }
      return true;
    }

    function updateHomeCards(){
      var total = Object.keys(currentFlights).length;
      var activeEl = document.getElementById('active-flights-count'); if(activeEl) activeEl.textContent = total || '—';
      var airlines = new Set();
      Object.values(currentFlights).forEach(function(f){ var cs=(f.callsign||'').trim(); if(cs) airlines.add(cs.slice(0,3).toUpperCase()); });
      var alEl = document.getElementById('active-airlines-count'); if(alEl) alEl.textContent = airlines.size || '—';
      var ltSrc = document.getElementById('last-trigger');
      var ltSum = document.getElementById('last-trigger-summary'); if(ltSum) ltSum.textContent = ltSrc ? (ltSrc.textContent||'—') : '—';
    }

    // DataTables rendering
    function renderFlightsTable(list){
      var table = document.getElementById('flights-table');
      if(!table) { updateHomeCards(); return; }
      var thead = table.querySelector('thead');
      var tbody = table.querySelector('tbody');
      if(!thead || !tbody) return;
      var headers = Array.from(thead.querySelectorAll('th')).map(function(th){ return th.textContent.trim().toLowerCase(); });
      var hasLatLon = headers.indexOf('lat')>=0 && headers.indexOf('lon')>=0;
      var rowsHtml = '';
      (list||[]).forEach(function(f){
        var type = f.type || inferFlightType(f);
        var last = f.last_seen ? new Date(f.last_seen*1000).toLocaleTimeString() : '—';
        if(hasLatLon){
          rowsHtml += '<tr>'
            + '<td>'+(f.callsign||f.icao24||'—')+'</td>'
            + '<td>'+(f.icao24||'—')+'</td>'
            + '<td><span class="badge bg-secondary">'+type+'</span></td>'
            + '<td>'+(f.origin||'—')+'</td>'
            + '<td>'+(f.destination||'—')+'</td>'
            + '<td class="text-end">'+(f.altitude!=null?Math.round(f.altitude):'—')+'</td>'
            + '<td class="text-end">'+(f.speed!=null?Math.round(f.speed):'—')+'</td>'
            + '<td class="text-end">'+(f.heading!=null?Math.round(f.heading):'—')+'</td>'
            + '<td class="text-end">'+(f.lat!=null?f.lat.toFixed(4):'—')+'</td>'
            + '<td class="text-end">'+(f.lon!=null?f.lon.toFixed(4):'—')+'</td>'
            + '<td>'+last+'</td>'
            + '</tr>';
        } else {
          rowsHtml += '<tr>'
            + '<td>'+(f.callsign||f.icao24||'—')+'</td>'
            + '<td>'+(f.icao24||'—')+'</td>'
            + '<td><span class="badge bg-secondary">'+type+'</span></td>'
            + '<td>'+(f.origin||'—')+'</td>'
            + '<td>'+(f.destination||'—')+'</td>'
            + '<td class="text-end">'+(f.altitude!=null?Math.round(f.altitude):'—')+'</td>'
            + '<td class="text-end">'+(f.speed!=null?Math.round(f.speed):'—')+'</td>'
            + '<td class="text-end">'+(f.heading!=null?Math.round(f.heading):'—')+'</td>'
            + '<td>'+last+'</td>'
            + '</tr>';
        }
      });
      tbody.innerHTML = rowsHtml || '<tr><td colspan="'+headers.length+'" class="text-muted">Sin datos</td></tr>';

      // DataTables init or reinit if available
      try{
        if(window.$ && $.fn && $.fn.DataTable){
          var $t = $(table);
          if($.fn.dataTable.isDataTable(table)){
            $t.DataTable().destroy();
          }
          var isFlightsPage = (window.location && window.location.pathname.indexOf('/flights') !== -1) || (headers.length === 9 && headers.indexOf('lat') === -1);
          var dtOpts = {
            language:{
              decimal:",", thousands:".", search:"Buscar:", lengthMenu:"Mostrar _MENU_", info:"Mostrando _START_–_END_ de _TOTAL_", paginate:{ first:"Primero", previous:"Anterior", next:"Siguiente", last:"Último" }, zeroRecords:"No se encontraron resultados"
            },
            order: [],
            dom: 'frtip'
          };
          if(isFlightsPage){
            dtOpts.paging = false; // show all flights without pagination
            dtOpts.pageLength = -1;
            dtOpts.lengthMenu = [[-1, 25, 50, 100], ['Todos', 25, 50, 100]];
            // Remove search bar on flights page
            dtOpts.searching = false;
            dtOpts.dom = 'rtip';
          } else {
            dtOpts.pageLength = 25;
          }
          $t.DataTable(dtOpts);
        }
      }catch(e){ /* ignore datatables errors */ }
      updateHomeCards();
    }

    function processSnapshot(list, opts){
      list = list || [];
      var partial = !!(opts && opts.partial);
      var updateTable = !(opts && opts.updateTable === false);
      var seen = {};
      // Airlines select
      try{
        var airlineSet = new Set();
        list.forEach(function(d){ if(d.callsign){ airlineSet.add((d.callsign||'').substr(0,3).toUpperCase()); } });
        var sel = document.getElementById('filter-airline');
        if(sel){
          var prev = sel.value || '';
          sel.innerHTML = '<option value="">Todas</option>';
          Array.from(airlineSet).sort().forEach(function(a){ if(a) sel.innerHTML += '<option value="'+a+'">'+a+'</option>'; });
          sel.value = prev;
        }
      }catch(e){}

      var mapBounds = null; try{ if(map && map.getBounds) mapBounds = map.getBounds(); }catch(e){}
      list.forEach(function(d){
        var id = d.icao24; if(!id) return; seen[id]=true; currentFlights[id]=d;
        if(map){
          if(mapBounds && (d.lat==null || d.lon==null || !mapBounds.contains([d.lat, d.lon]))){
            // Skip markers outside current view; keep table full
            return;
          }
          if(markers[id]){
            markers[id].setLatLng([d.lat, d.lon]);
            var el = markers[id].getElement && markers[id].getElement(); if(el){ el.style.transform='rotate('+(d.heading||0)+'deg)'; el.style.opacity=d.estimated? '0.7':'1'; }
            markers[id].bindPopup && markers[id].bindPopup('<b>'+ (d.callsign||id) +'</b><br>Alt: '+(d.altitude||'—'));
          } else {
            var icon = createPlaneIcon(d.heading||0);
            var m = icon ? L.marker([d.lat, d.lon], {icon}) : L.marker([d.lat, d.lon]);
            m.addTo(map); m.bindPopup && m.bindPopup('<b>'+ (d.callsign||id) +'</b><br>Alt: '+(d.altitude||'—'));
            markers[id]=m;
          }
        }
      });
      // Remove missing only on full snapshots; keep existing on partial updates
      if(!partial){
        if(map){
          Object.keys(markers).forEach(function(id){ if(!seen[id]){ map.removeLayer(markers[id]); delete markers[id]; delete currentFlights[id]; } });
        } else {
          Object.keys(currentFlights).forEach(function(id){ if(!seen[id]){ delete currentFlights[id]; } });
        }
      }
      var totalEl = document.getElementById('total-flights'); if(totalEl) totalEl.textContent = Object.keys(currentFlights).length;
      var filtered = Object.values(currentFlights).filter(passesFilters);
      if(updateTable){
        renderFlightsTable(filtered);
      }
    }

    function applyFiltersToMarkers(){
      if(map){
        Object.keys(currentFlights).forEach(function(id){
          var f = currentFlights[id]; var m = markers[id]; if(!m) return; var show = passesFilters(f);
          var el = m.getElement && m.getElement(); if(el){ el.style.display = show ? '' : 'none'; }
        });
      }
      var filtered = Object.values(currentFlights).filter(passesFilters);
      var totalEl2 = document.getElementById('total-flights'); if(totalEl2) totalEl2.textContent = filtered.length;
      renderFlightsTable(filtered);
    }

    // Advanced filters (sliders + chips)
    function initAdvancedFilters(){
      try{
        var altSlider = document.getElementById('slider-alt');
        var speedSlider = document.getElementById('slider-speed');
        var altMinInput = document.getElementById('filter-alt-min');
        var altMaxInput = document.getElementById('filter-alt-max');
        var speedMinInput = document.getElementById('filter-speed-min');
        var speedMaxInput = document.getElementById('filter-speed-max');
        var altLabel = document.getElementById('alt-range-label');
        var speedLabel = document.getElementById('speed-range-label');
        if(window.noUiSlider && altSlider){
          noUiSlider.create(altSlider, { start:[0,20000], connect:true, tooltips:false, range:{min:0,max:20000} });
          altSlider.noUiSlider.on('update', function(values){ var a=Math.round(values[0]); var b=Math.round(values[1]); if(altLabel) altLabel.textContent=a+' — '+b; });
          altSlider.noUiSlider.on('change', function(values){ if(altMinInput) altMinInput.value=Math.round(values[0]); if(altMaxInput) altMaxInput.value=Math.round(values[1]); updateFiltersFromUI(); applyFiltersToMarkers(); renderFilterChips(); });
        }
        if(window.noUiSlider && speedSlider){
          noUiSlider.create(speedSlider, { start:[0,300], connect:true, tooltips:false, range:{min:0,max:300} });
          speedSlider.noUiSlider.on('update', function(values){ var a=Math.round(values[0]); var b=Math.round(values[1]); if(speedLabel) speedLabel.textContent=a+' — '+b; });
          speedSlider.noUiSlider.on('change', function(values){ if(speedMinInput) speedMinInput.value=Math.round(values[0]); if(speedMaxInput) speedMaxInput.value=Math.round(values[1]); updateFiltersFromUI(); applyFiltersToMarkers(); renderFilterChips(); });
        }
      }catch(e){ console.warn('initAdvancedFilters failed', e); }
    }

    function renderFilterChips(){
      var host = document.getElementById('filter-chips'); if(!host) return;
      var chips = [];
      // Fixed scope chip on flights page
      if(isFlightsPage()){
        chips.push({key:'scope', label:'Región: CDMX'});
      }
      if(currentFilters.type){ chips.push({key:'type', label:'Tipo: '+currentFilters.type}); }
      if(currentFilters.airline){ chips.push({key:'airline', label:'Aerolínea: '+currentFilters.airline}); }
      if(currentFilters.altMin!=null || currentFilters.altMax!=null){ chips.push({key:'alt', label:'Alt: '+(currentFilters.altMin??'0')+'–'+(currentFilters.altMax??'∞')}); }
      if(currentFilters.speedMin!=null || currentFilters.speedMax!=null){ chips.push({key:'speed', label:'Vel: '+(currentFilters.speedMin??'0')+'–'+(currentFilters.speedMax??'∞')}); }
      host.innerHTML = chips.map(function(c){ return '<span class="chip" data-key="'+c.key+'">'+c.label+' <span class="close" aria-label="Quitar">×</span></span>'; }).join(' ');
    }

    document.addEventListener('click', function(evt){
      var chip = evt.target.closest && evt.target.closest('.chip');
      if(chip){
        var key = chip.getAttribute('data-key');
        var selAir = document.getElementById('filter-airline');
        var selType = document.getElementById('filter-type');
        var altMin = document.getElementById('filter-alt-min');
        var altMax = document.getElementById('filter-alt-max');
        var speedMin = document.getElementById('filter-speed-min');
        var speedMax = document.getElementById('filter-speed-max');
        if(key==='type' && selType){ selType.value=''; }
        if(key==='airline' && selAir){ selAir.value=''; }
        if(key==='alt'){
          if(altMin) altMin.value=''; if(altMax) altMax.value='';
          try{ if(window.noUiSlider && document.getElementById('slider-alt')) document.getElementById('slider-alt').noUiSlider.set([0,20000]); }catch(e){}
        }
        if(key==='speed'){
          if(speedMin) speedMin.value=''; if(speedMax) speedMax.value='';
          try{ if(window.noUiSlider && document.getElementById('slider-speed')) document.getElementById('slider-speed').noUiSlider.set([0,300]); }catch(e){}
        }
        updateFiltersFromUI(); applyFiltersToMarkers(); renderFilterChips();
        return;
      }
      // Row click centers the map (if present)
      var row = evt.target.closest && evt.target.closest('#flights-table tbody tr');
      if(row && map){
        var icao24 = row.children[1] ? row.children[1].textContent.trim() : '';
        if(icao24 && markers[icao24]){
          map.panTo(markers[icao24].getLatLng()); markers[icao24].openPopup && markers[icao24].openPopup();
        }
      }
    });

    // Socket events
    if(socket){
      socket.on('connect', function(){ /* connected */ });
      socket.on('flight_update', function(d){ try{
        var id=d.icao24; if(!id) return; d.type = d.type || inferFlightType(d); currentFlights[id]=d;
        if(map){
          if(markers[id]){ markers[id].setLatLng([d.lat,d.lon]); var el=markers[id].getElement&&markers[id].getElement(); if(el){ el.style.transform='rotate('+(d.heading||0)+'deg)'; el.style.opacity=d.estimated?'0.7':'1'; } }
          else { var icon=createPlaneIcon(d.heading||0); var m = icon? L.marker([d.lat,d.lon],{icon}) : L.marker([d.lat,d.lon]); m.addTo(map); m.bindPopup && m.bindPopup('<b>'+ (d.callsign||id) +'</b><br>Alt: '+(d.altitude||'—')); markers[id]=m; }
        }
        // En la página de vuelos NO re-renderizamos la tabla con updates individuales del socket.
        if(!isFlightsPage()){ applyFiltersToMarkers(); }
      }catch(e){} });
      socket.on('flights_snapshot', function(list){ try{ processSnapshot(list, { partial: isFlightsPage(), updateTable: !isFlightsPage() }); }catch(e){} });
      socket.on('flight_remove', function(data){ var id=data.icao24; if(markers[id]&&map){ map.removeLayer(markers[id]); } delete markers[id]; delete currentFlights[id]; applyFiltersToMarkers(); });
      socket.on('zabbix_event', function(e){ var last=document.getElementById('last-trigger'); if(last) last.textContent = e.message || e.host || 'trigger'; updateHomeCards();
        try{ var events = document.getElementById('events'); if(events && e && (e.message||e.host)){ var el = document.createElement('div'); el.textContent = (new Date().toLocaleTimeString()) + ' — ' + (e.message || e.host); events.insertBefore(el, events.firstChild); }
          // If the event contains an icon:telegram flag, show the telegram indicator
          if(e && e.icon === 'telegram'){
            var t = document.getElementById('telegram-alert');
            if(t){
              t.style.display='block';
              try{ t.innerHTML = '🔔 <strong>Alerta Telegram</strong> — '+ (e.message || ''); }catch(ex){}
              // hide after 12 seconds
              setTimeout(function(){ t.style.display='none'; }, 12000);
            }
          }
        }catch(ex){}
      });
      socket.on('status_update', function(s){ if(s.api) { setCard('api', s.api); updateApiIndicator(s.api); } if(s.db) setCard('db', s.db); if(s.backend) setCard('backend', s.backend); if(s.zabbix) setCard('zabbix', s.zabbix); });
      socket.on('flights_per_min', function(n){ pushChartPoint(n); });
    } else {
      setTimeout(function(){ pushChartPoint(3); pushChartPoint(5); pushChartPoint(4); }, 600);
    }

    // REST fallback: initial snapshot + polling
    var BBOX = { lamin: 18.90, lomin: -99.60, lamax: 19.80, lomax: -98.90 };
    function isFlightsPage(){ return (window.location && window.location.pathname.indexOf('/flights') !== -1); }
    function fetchInitial(){
      // En la página de vuelos, limitamos a CDMX usando el BBOX
      var url = isFlightsPage() ? ('/api/opensky?lamin='+BBOX.lamin+'&lomin='+BBOX.lomin+'&lamax='+BBOX.lamax+'&lomax='+BBOX.lomax)
                                : ('/api/opensky?lamin='+BBOX.lamin+'&lomin='+BBOX.lomin+'&lamax='+BBOX.lamax+'&lomax='+BBOX.lomax);
      fetch(url).then(function(res){ if(!res.ok) throw new Error('HTTP '+res.status); return res.json(); })
      .then(function(data){
        var list = [];
        if(data && Array.isArray(data.states)){
          data.states.forEach(function(s){
            try{
              var icao24 = s[0]; var callsign=(s[1]||'').trim(); var lon=s[5]; var lat=s[6];
              var altitude = (s[13]!=null) ? s[13] : s[7]; var velocity = s[9]; var heading=s[10]; var last_seen=s[4];
              // Solo CDMX: requiere posición y dentro del BBOX
              if(lat==null || lon==null) return;
              if(lat < BBOX.lamin || lat > BBOX.lamax || lon < BBOX.lomin || lon > BBOX.lomax) return;
              var obj = { icao24, callsign, lon: lon, lat: lat, altitude, speed: velocity, heading, last_seen };
              obj.type = inferFlightType(obj);
              list.push(obj);
            }catch(e){}
          });
        }
        processSnapshot(list, { partial: false, updateTable: true });
      }).catch(function(err){ console.warn('opensky fallback failed', err); });
    }
    fetchInitial(); setInterval(fetchInitial, 15000);

    // Filters wiring
    function updateFiltersFromUI(){
      var selAir = document.getElementById('filter-airline');
      var selType = document.getElementById('filter-type');
      var altMin = document.getElementById('filter-alt-min');
      var altMax = document.getElementById('filter-alt-max');
      var speedMin = document.getElementById('filter-speed-min');
      var speedMax = document.getElementById('filter-speed-max');
      currentFilters.airline = selAir && selAir.value ? selAir.value : '';
      currentFilters.type = selType && selType.value ? selType.value : '';
      currentFilters.altMin = altMin && altMin.value ? Number(altMin.value) : null;
      currentFilters.altMax = altMax && altMax.value ? Number(altMax.value) : null;
      currentFilters.speedMin = speedMin && speedMin.value ? Number(speedMin.value) : null;
      currentFilters.speedMax = speedMax && speedMax.value ? Number(speedMax.value) : null;
    }

    try{
      var applyBtn = document.getElementById('apply-filters');
      var clearBtn = document.getElementById('clear-filters');
      var selAir = document.getElementById('filter-airline');
      var selType = document.getElementById('filter-type');
      var selRegion = document.getElementById('region-select');
      if(selAir) selAir.addEventListener('change', function(){ updateFiltersFromUI(); applyFiltersToMarkers(); renderFilterChips(); });
      if(selType) selType.addEventListener('change', function(){ updateFiltersFromUI(); applyFiltersToMarkers(); renderFilterChips(); });
      if(selRegion) selRegion.addEventListener('change', function(){
        if(map){ Object.keys(markers).forEach(function(id){ try{ map.removeLayer(markers[id]); }catch(e){} delete markers[id]; }); }
        currentFlights = {};
        var b = getActiveBBOX();
        try{ if(map && b && L && L.latLngBounds){ map.fitBounds(L.latLngBounds([[b.lamin,b.lomin],[b.lamax,b.lomax]])); } }catch(e){}
        renderFilterChips();
        fetchInitial();
      });
      if(applyBtn) applyBtn.addEventListener('click', function(){ updateFiltersFromUI(); applyFiltersToMarkers(); renderFilterChips(); });
      if(clearBtn) clearBtn.addEventListener('click', function(){
        if(selAir) selAir.value=''; if(selType) selType.value='';
        var altMin = document.getElementById('filter-alt-min'); var altMax = document.getElementById('filter-alt-max');
        var speedMin = document.getElementById('filter-speed-min'); var speedMax = document.getElementById('filter-speed-max');
        if(altMin) altMin.value=''; if(altMax) altMax.value=''; if(speedMin) speedMin.value=''; if(speedMax) speedMax.value='';
        try{ if(window.noUiSlider && document.getElementById('slider-alt')) document.getElementById('slider-alt').noUiSlider.set([0,20000]); }catch(e){}
        try{ if(window.noUiSlider && document.getElementById('slider-speed')) document.getElementById('slider-speed').noUiSlider.set([0,300]); }catch(e){}
        currentFilters = { airline:'', type:'', altMin:null, altMax:null, speedMin:null, speedMax:null };
        applyFiltersToMarkers(); renderFilterChips();
      });
      initAdvancedFilters(); renderFilterChips();
    }catch(e){ console.warn('filters wiring failed', e); }
  });
})();
// (Cleanup) Removed duplicate legacy block.
