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
        MARKER_COLORS: {
            'HumanObservation': '#df4a21',      // NBN Atlas orange
            'PreservedSpecimen': '#2e8b57',     // Sea green
            'MachineObservation': '#4169e1',    // Royal blue
            'default': '#808080'                // Gray for unknown
        },
        MARKER_NAMES: {
            'HumanObservation': 'Human Observation',
            'PreservedSpecimen': 'Preserved Specimen',
            'MachineObservation': 'Machine Observation'
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
     * Get marker color based on basis of record
     * @param {string} basisOfRecord - The basis of record type
     * @returns {string} Hex color code
     */
    function getMarkerColor(basisOfRecord) {
        return CONFIG.MARKER_COLORS[basisOfRecord] || CONFIG.MARKER_COLORS.default;
    }

    /**
     * Get readable basis of record name
     * @param {string} basisOfRecord - The basis of record type
     * @returns {string} Human-readable name
     */
    function getBasisOfRecordName(basisOfRecord) {
        return CONFIG.MARKER_NAMES[basisOfRecord] || basisOfRecord || 'Unknown';
    }

    /**
     * Create base layers for the map
     * @returns {Object} Object containing base layer definitions
     */
    function createBaseLayers() {
        var defaultBaseLayer = L.tileLayer(CONFIG.TILE_LAYERS.minimal.url, {
            attribution: CONFIG.TILE_LAYERS.minimal.attribution,
            subdomains: CONFIG.TILE_LAYERS.minimal.subdomains,
            maxZoom: CONFIG.TILE_LAYERS.minimal.maxZoom
        });

        return {
            "Minimal": defaultBaseLayer,
            "OpenStreetMap": L.tileLayer(CONFIG.TILE_LAYERS.osm.url, {
                attribution: CONFIG.TILE_LAYERS.osm.attribution,
                maxZoom: CONFIG.TILE_LAYERS.osm.maxZoom
            }),
            defaultLayer: defaultBaseLayer
        };
    }

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
                var markerColor = getMarkerColor(occurrence.basisOfRecord);

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
     * Create and add legend control to the map
     * @param {L.Map} map - The Leaflet map instance
     */
    function addLegendControl(map) {
        var legend = L.control({position: 'bottomleft'});
        legend.onAdd = function(map) {
            var div = L.DomUtil.create('div', 'legend');
            div.innerHTML = '<h4>Record Types</h4>' +
                '<div class="legend-item"><i style="background: ' + CONFIG.MARKER_COLORS.HumanObservation + '"></i>Human Observation</div>' +
                '<div class="legend-item"><i style="background: ' + CONFIG.MARKER_COLORS.PreservedSpecimen + '"></i>Preserved Specimen</div>' +
                '<div class="legend-item"><i style="background: ' + CONFIG.MARKER_COLORS.MachineObservation + '"></i>Machine Observation</div>' +
                '<div class="legend-item"><i style="background: ' + CONFIG.MARKER_COLORS.default + '"></i>Unknown/Other</div>';
            return div;
        };
        legend.addTo(map);
        return legend;
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

        // Create and add base layers
        var baseLayers = createBaseLayers();
        map.addLayer(baseLayers.defaultLayer);

        // Add layer control
        var layerControl = L.control.layers(baseLayers, {}, {
            collapsed: true,
            position: 'topleft'
        });
        layerControl.addTo(map);

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

        // Add legend control
        addLegendControl(map);

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
        getMarkerColor: getMarkerColor,
        getBasisOfRecordName: getBasisOfRecordName,
        CONFIG: CONFIG
    };

})();

console.log('EasyMap module loaded');
