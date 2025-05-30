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
     * Create and add 10km grid WMS layer to the map
     * @param {L.Map} map - The Leaflet map instance
     * @param {string} tvk - Taxon Version Key for the species
     * @param {string} biocacheUrl - Base URL for biocache service
     * @param {string} datasetFilter - Optional dataset filter
     * @param {string} color - Optional color for the grid (default: df4a21)
     * @returns {L.Layer} The WMS layer
     */
    function addGridLayer(map, tvk, biocacheUrl, datasetFilter, color) {
        if (!tvk || !biocacheUrl) {
            console.warn('Missing required parameters for grid layer');
            return null;
        }

        // Default color if not provided
        color = color || 'df4a21';

        // Build the query string - match EasyMap_Shim format
        var query = "?q=lsid:" + encodeURIComponent(tvk);

        // Add dataset filter if provided - build druidurl like EasyMap_Shim
        if (datasetFilter) {
            var datasets = datasetFilter.split(',');
            var druidQueries = [];
            datasets.forEach(function(ds) {
                if (ds.trim()) {
                    druidQueries.push("data_resource_uid:" + ds.trim());
                }
            });
            if (druidQueries.length > 0) {
                if (druidQueries.length === 1) {
                    query += "&fq=" + encodeURIComponent(druidQueries[0]);
                } else {
                    query += "&fq=" + encodeURIComponent("(" + druidQueries.join(" OR ") + ")");
                }
            }
        }

        // Add presence filter to exclude absent records
        query += "&fq=" + encodeURIComponent("-occurrence_status:absent");

        // Build WMS URL using /ogc/wms/reflect endpoint like EasyMap_Shim
        var wmsUrl = biocacheUrl + "/ogc/wms/reflect" + query;

        // Configure grid parameters to match EasyMap_Shim with dynamic color
        var envProperty = "colourmode:osgrid;color:" + color + ";opacity:0.8;gridlabels:false;gridres:fixed_10km";

        // Create WMS layer using the correct format
        var gridLayer = L.tileLayer.wms(wmsUrl, {
            layers: 'ALA:occurrences',
            format: 'image/png',
            transparent: true,
            ENV: envProperty,
            opacity: 0.8
        });

        map.addLayer(gridLayer);
        console.log('10km grid layer added with URL:', wmsUrl);
        console.log('ENV parameters:', envProperty);

        return gridLayer;
    }

    /**
     * Fit map bounds to show all data or use provided bounds
     * @param {L.Map} map - The Leaflet map instance
     * @param {L.Layer} dataLayer - The data layer (could be WMS grid or marker group)
     * @param {Object} mapConfig - Map configuration with optional bounds
     */
    function fitMapBounds(map, dataLayer, mapConfig) {
        if (mapConfig.bounds) {
            var bounds = L.latLngBounds([
                [mapConfig.bounds.southwest.lat, mapConfig.bounds.southwest.lng],
                [mapConfig.bounds.northeast.lat, mapConfig.bounds.northeast.lng]
            ]);
            map.fitBounds(bounds, { padding: [10, 10] });
        } else if (dataLayer && typeof dataLayer.getBounds === 'function' && dataLayer.getLayers && dataLayer.getLayers().length > 0) {
            // For marker groups - fallback option (shouldn't be used with grid but kept for safety)
            map.fitBounds(dataLayer.getBounds(), { padding: [10, 10] });
        } else {
            // For WMS layers or when no bounds available, use default UK view
            map.setView([CONFIG.DEFAULT_COORDS.lat, CONFIG.DEFAULT_COORDS.lng], CONFIG.DEFAULT_COORDS.zoom);
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

        // Add 10km grid WMS layer
        var biocacheUrl = mapConfig.biocacheUrl;
        if (!biocacheUrl) {
            console.warn('biocacheUrl not provided in mapConfig, using fallback URL');
            biocacheUrl = 'https://records-ws.nbnatlas.org'; // Fallback URL
        }

        console.log('Using biocache URL:', biocacheUrl);

        var datasetFilter = options.datasetFilter || null;
        var color = options.color || 'df4a21';
        var gridLayer = addGridLayer(map, tvk, biocacheUrl, datasetFilter, color);

        // Fit map to show all data
        fitMapBounds(map, gridLayer, mapConfig);

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
        console.log('Grid mode: 10km grid');
        console.log('Dataset filter:', datasetFilter || 'none');
        console.log('Biocache URL:', biocacheUrl);

        return map;
    }

    // Public API
    return {
        init: initializeMap,
        CONFIG: CONFIG
    };

})();

console.log('EasyMap module loaded');
