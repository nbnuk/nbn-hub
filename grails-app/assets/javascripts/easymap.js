//= require leaflet/leaflet
//= require_self

/**
 * NBN Atlas EasyMap JavaScript Module
 * Provides reusable functionality for EasyMap species occurrence mapping
 */
window.EasyMap = (function() {
    'use strict';

    // Configuration constants
    var CONFIG = {
        DEFAULT_COORDS: {
            lat: 54.5,
            lng: -3.0,
            zoom: 6
        },
        TILE_LAYERS: {
            minimal: {
                url: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                attribution: '© OpenStreetMap contributors, © CartoDB',
                subdomains: 'abcd',
                maxZoom: 18
            },
            osm: {
                url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                attribution: '© OpenStreetMap contributors',
                maxZoom: 18
            }
        }
    };

    /**
     * Create and add occurrence markers to the map
     * @param {L.Map} map - The Leaflet map instance
     * @param {Array} occurrences - Array of occurrence data
     * @returns {L.FeatureGroup} Feature group containing all markers
     */
    function addOccurrenceMarkers(map, occurrences) {
        var markerGroup = L.featureGroup();

        if (!occurrences || occurrences.length === 0) {
            return markerGroup;
        }

        occurrences.forEach(function(occurrence) {
            if (occurrence.latitude && occurrence.longitude) {
                // Use consistent NBN Atlas orange color for all markers
                var markerColor = '#df4a21';

                var marker = L.circleMarker([occurrence.latitude, occurrence.longitude], {
                    radius: 6,
                    fillColor: markerColor,
                    color: '#fff',
                    weight: 2,
                    opacity: 1,
                    fillOpacity: 0.8
                });

                markerGroup.addLayer(marker);
            }
        });

        map.addLayer(markerGroup);
        return markerGroup;
    }

    /**
     * Fit map bounds to show all markers or use provided bounds
     * @param {L.Map} map - The Leaflet map instance
     * @param {L.FeatureGroup} markerGroup - Feature group containing markers
     * @param {Object} mapConfig - Map configuration with optional bounds
     */
    function fitMapBounds(map, markerGroup, mapConfig) {
        if (mapConfig.bounds && markerGroup.getLayers().length > 0) {
            var bounds = L.latLngBounds([
                [mapConfig.bounds.southwest.lat, mapConfig.bounds.southwest.lng],
                [mapConfig.bounds.northeast.lat, mapConfig.bounds.northeast.lng]
            ]);
            map.fitBounds(bounds, { padding: [10, 10] });
        } else if (markerGroup.getLayers().length > 0) {
            // Fallback: fit to marker bounds
            map.fitBounds(markerGroup.getBounds(), { padding: [10, 10] });
        }
    }

    /**
     * Initialize EasyMap with provided configuration and data
     * @param {Object} options - Configuration options
     * @param {string} options.containerId - ID of the map container element
     * @param {Object} options.mapConfig - Map configuration object
     * @param {Array} options.occurrences - Array of occurrence data
     * @param {Object} options.speciesInfo - Species information object
     * @param {string} options.tvk - Taxon Version Key
     * @returns {L.Map} The initialized Leaflet map instance
     */
    function initializeMap(options) {
        var containerId = options.containerId || 'easymap';
        var mapConfig = options.mapConfig || {};
        var occurrences = options.occurrences || [];
        var speciesInfo = options.speciesInfo || {};
        var tvk = options.tvk || '';

        // Set default coordinates (UK bounds)
        var defaultLat = mapConfig.defaultLatitude || CONFIG.DEFAULT_COORDS.lat;
        var defaultLng = mapConfig.defaultLongitude || CONFIG.DEFAULT_COORDS.lng;
        var defaultZoom = mapConfig.defaultZoom || CONFIG.DEFAULT_COORDS.zoom;

        // Initialize the map
        var map = L.map(containerId, {
            center: [defaultLat, defaultLng],
            zoom: defaultZoom,
            minZoom: 1,
            maxZoom: 18,
            zoomControl: false,        // Disable zoom control buttons (+/-)
            scrollWheelZoom: false,    // Disable mouse wheel zoom
            doubleClickZoom: false,    // Disable double-click zoom
            touchZoom: false,          // Disable touch/pinch zoom
            boxZoom: false,            // Disable shift+drag box zoom
            keyboard: false,           // Disable keyboard zoom (+ and - keys)
            worldCopyJump: true
        });

        // Create and add default base layer (no layer switching needed)
        var defaultBaseLayer = L.tileLayer(CONFIG.TILE_LAYERS.minimal.url, {
            attribution: CONFIG.TILE_LAYERS.minimal.attribution,
            subdomains: CONFIG.TILE_LAYERS.minimal.subdomains,
            maxZoom: CONFIG.TILE_LAYERS.minimal.maxZoom
        });
        map.addLayer(defaultBaseLayer);

        // Add occurrence markers
        var markerGroup = addOccurrenceMarkers(map, occurrences);

        // Fit map to show all markers
        fitMapBounds(map, markerGroup, mapConfig);

        // Add scale control
        L.control.scale({
            position: 'bottomright',
            imperial: false,
            metric: true
        }).addTo(map);

        // Add attribution control with NBN Atlas branding
        map.attributionControl.setPrefix('NBN Atlas EasyMap | Powered by <a href="http://leafletjs.com" title="A JS library for interactive maps">Leaflet</a>');

        // Log initialization for debugging
        console.log('EasyMap initialized for TVK:', tvk);
        console.log('Map config:', mapConfig);
        console.log('Occurrences:', occurrences.length);
        console.log('Species info:', speciesInfo);

        return map;
    }

    // Public API
    return {
        init: initializeMap,
        CONFIG: CONFIG
    };

})();

console.log('EasyMap module loaded');
