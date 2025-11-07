console.log("Zabbix Flights frontend cargado correctamente.");

// Theme management: apply persisted theme and wire UI controls
(function(){
		function applyTheme(theme){
			if(!theme) theme = 'light';
			// set data-theme on root for CSS hooks
			document.documentElement.setAttribute('data-theme', theme);
			// update navbar classes for better contrast
			var nav = document.querySelector('.navbar');
			if(nav){
				if(theme==='dark'){
					nav.classList.remove('navbar-light','bg-white'); nav.classList.add('navbar-dark','bg-dark');
				} else {
					nav.classList.remove('navbar-dark','bg-dark'); nav.classList.add('navbar-light','bg-white');
				}
			}
			// highlight selected button
			var bl = document.getElementById('theme-light');
			var bd = document.getElementById('theme-dark');
			if(bl && bd){
				if(theme==='dark'){ bl.classList.remove('active'); bd.classList.add('active'); }
				else { bd.classList.remove('active'); bl.classList.add('active'); }
			}
			// persist
			try{ localStorage.setItem('zabbix_flights_theme', theme); }catch(e){}
		}

		function initThemeUI(){
		var stored = null;
		try{ stored = localStorage.getItem('zabbix_flights_theme'); }catch(e){}
		var theme = stored || 'light';
		applyTheme(theme);

		var bl = document.getElementById('theme-light');
		var bd = document.getElementById('theme-dark');
		if(bl) bl.addEventListener('click', function(){ applyTheme('light'); });
		if(bd) bd.addEventListener('click', function(){ applyTheme('dark'); });
	}

	if(document.readyState !== 'loading') initThemeUI(); else document.addEventListener('DOMContentLoaded', initThemeUI);
})();
