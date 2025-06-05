//= require leaflet/leaflet
//= require_self

/**
 * NBN Atlas EasyMap JavaScript Module
 *
 * This module provides functionality for displaying species occurrence maps in the NBN Atlas style.
 * It implements the EasyMap API specification for consistent mapping across NBN Atlas platforms.
 *
 * Key features:
 * - Grid-based occurrence visualization
 * - Support for multiple dataset filters
 * - Configurable grid colors and styles
 * - WMS layer integration with biocache service
 * - Leaflet map integration
 *
 * @module EasyMap
 * @requires leaflet
 * @version 1.0.0
 */
window.EasyMap = (function() {
    'use strict';

    /**
     * Create and add 10km grid WMS layer to the map
     * @param {L.Map} map - The Leaflet map instance
     * @param {string} tvk - Taxon Version Key for the species
     * @param {string} biocacheUrl - Base URL for biocache service
     * @param {string} datasetFilter - Optional dataset filter
     * @param {string} color - Optional color for the grid
     * @param {Object} gridConfig - Grid layer configuration
     * @returns {L.Layer} The WMS layer
     */
    function addGridLayer(map, tvk, biocacheUrl, datasetFilter, color, gridConfig) {
        if (!tvk || !biocacheUrl) {
            console.warn('Missing required parameters for grid layer');
            return null;
        }

        // Use provided color or fall back to configuration
        color = color || (gridConfig && gridConfig.defaultColor) || 'df4a21';

        // Build the query string
        var query = "?q=lsid:" + encodeURIComponent(tvk);

        // Add dataset filter if provided
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

        // Add presence filter to exclude absent records ( TODO is this needed ?)
        query += "&fq=" + encodeURIComponent("-occurrence_status:absent");

        // Build WMS URL using /mapping/wms/reflect endpoint like EasyMap_Shim
        var wmsUrl = biocacheUrl + "/mapping/wms/reflect" + query;

        // Configure grid parameters using configuration
        var opacity = (gridConfig && gridConfig.opacity) || '0.8';
        var colourMode = (gridConfig && gridConfig.colourMode) || 'osgrid';
        var gridLabels = (gridConfig && gridConfig.gridLabels) || 'false';
        var gridResolution = (gridConfig && gridConfig.gridResolution) || 'fixed_10km';

        var envProperty = "colourmode:" + colourMode + ";color:" + color + ";opacity:" + opacity + ";gridlabels:" + gridLabels + ";gridres:" + gridResolution;

        // Create WMS layer using configuration
        var gridLayer = L.tileLayer.wms(wmsUrl, {
            layers: (gridConfig && gridConfig.layers) || 'ALA:occurrences',
            format: (gridConfig && gridConfig.format) || 'image/png',
            transparent: true,
            ENV: envProperty,
            opacity: parseFloat(opacity)
        });

        map.addLayer(gridLayer);
        console.log('10km grid layer added with URL:', wmsUrl);
        console.log('ENV parameters:', envProperty);
        console.log('Grid resolution from config:', gridResolution);

        return gridLayer;
    }

    /**
     * Create and add grid WMS layers for date bands to the map
     * @param {L.Map} map - The Leaflet map instance
     * @param {string} tvk - Taxon Version Key for the species
     * @param {string} biocacheUrl - Base URL for biocache service
     * @param {string} datasetFilter - Optional dataset filter
     * @param {Object} dateBands - Date bands configuration
     * @param {Object} gridConfig - Grid layer configuration
     * @returns {Array} Array of WMS layers
     */
    function addGridLayersWithDateBands(map, tvk, biocacheUrl, datasetFilter, dateBands, gridConfig) {
        if (!tvk || !biocacheUrl) {
            console.warn('Missing required parameters for grid layer');
            return [];
        }

        var layers = [];

        // If no date bands specified, use default single layer
        if (!dateBands || !dateBands.bands || dateBands.bands.length === 0) {
            var defaultColor = dateBands && dateBands.bands && dateBands.bands[0] ? dateBands.bands[0].fillColor : 'df4a21';
            var layer = addGridLayer(map, tvk, biocacheUrl, datasetFilter, defaultColor, gridConfig);
            if (layer) layers.push(layer);
            return layers;
        }

        // Add layers for each date band (bottom to top)
        dateBands.bands.forEach(function(band, index) {
            // Create layer for each defined band (WMS will filter based on date range)
            if (band.fromYear !== undefined && band.fillColor) {
                console.log('Adding date band layer:', band.name, 'from', band.fromYear, 'to', band.toYear, 'color:', band.fillColor);

                // Build the query string with date range
                var query = "?q=lsid:" + encodeURIComponent(tvk);

                // Add date range filter
                if (band.fromYear !== undefined && band.toYear !== undefined) {
                    query += "&fq=" + encodeURIComponent("year:[" + band.fromYear + " TO " + band.toYear + "]");
                } else if (band.fromYear !== undefined) {
                    // Open-ended range (e.g., from 2020 onwards)
                    query += "&fq=" + encodeURIComponent("year:[" + band.fromYear + " TO *]");
                }

                // Add dataset filter if provided
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

                // Build WMS URL using /mapping/wms/reflect endpoint like EasyMap_Shim
                var wmsUrl = biocacheUrl + "/mapping/wms/reflect" + query;

                // Configure grid parameters using configuration
                var opacity = (gridConfig && gridConfig.opacity) || '0.8';
                var colourMode = (gridConfig && gridConfig.colourMode) || 'osgrid';
                var gridLabels = (gridConfig && gridConfig.gridLabels) || 'false';
                var gridResolution = (gridConfig && gridConfig.gridResolution) || 'fixed_10km';

                var envProperty = "colourmode:" + colourMode + ";color:" + band.fillColor + ";opacity:" + opacity + ";gridlabels:" + gridLabels + ";gridres:" + gridResolution;

                // Create WMS layer using configuration
                var gridLayer = L.tileLayer.wms(wmsUrl, {
                    layers: (gridConfig && gridConfig.layers) || 'ALA:occurrences',
                    format: (gridConfig && gridConfig.format) || 'image/png',
                    transparent: true,
                    ENV: envProperty,
                    opacity: parseFloat(opacity)
                });

                map.addLayer(gridLayer);
                layers.push(gridLayer);

                console.log('Date band layer added:', band.name);
                console.log('WMS URL:', wmsUrl);
                console.log('ENV parameters:', envProperty);
                console.log('Date range filter: year:[' + band.fromYear + ' TO ' + (band.toYear || '*') + ']');
            }
        });

        return layers;
    }

    /**
     * Fit map bounds to show all data or use provided bounds
     * @param {L.Map} map - The Leaflet map instance
     * @param {L.Layer} dataLayer - The data layer (could be WMS grid or marker group)
     * @param {Object} mapConfig - Map configuration with optional bounds
     * @param {Object} boundingParams - Bounding box parameters (zoomArea, viceCounty, etc.)
     */
    function fitMapBounds(map, dataLayer, mapConfig, boundingParams) {
        boundingParams = boundingParams || {};

        // Priority 1: Use predefined zoom area bounds if specified and available in mapConfig
        if (boundingParams.zoomArea && mapConfig.bounds) {
            console.log('Applying zoom area bounds for:', boundingParams.zoomArea);
            var bounds = L.latLngBounds([
                [mapConfig.bounds.southwest.lat, mapConfig.bounds.southwest.lng],
                [mapConfig.bounds.northeast.lat, mapConfig.bounds.northeast.lng]
            ]);
            map.fitBounds(bounds, { padding: [10, 10] });
            return;
        }

        // Priority 2: Use vice-county bounds if specified and available in mapConfig
        if (boundingParams.viceCounty && mapConfig.bounds) {
            console.log('Applying vice-county bounds for VC:', boundingParams.viceCounty);
            var bounds = L.latLngBounds([
                [mapConfig.bounds.southwest.lat, mapConfig.bounds.southwest.lng],
                [mapConfig.bounds.northeast.lat, mapConfig.bounds.northeast.lng]
            ]);
            map.fitBounds(bounds, { padding: [10, 10] });
            return;
        }

        // Priority 3: Use grid reference bounding box if specified and available in mapConfig
        if ((boundingParams.bottomLeft && boundingParams.topRight) && mapConfig.bounds) {
            console.log('Applying grid reference bounds:', boundingParams.bottomLeft, 'to', boundingParams.topRight);
            var bounds = L.latLngBounds([
                [mapConfig.bounds.southwest.lat, mapConfig.bounds.southwest.lng],
                [mapConfig.bounds.northeast.lat, mapConfig.bounds.northeast.lng]
            ]);
            map.fitBounds(bounds, { padding: [10, 10] });
            return;
        }

        // Priority 4: Use coordinate bounding box if specified and available in mapConfig
        if ((boundingParams.bottomLeftCoord && boundingParams.topRightCoord) && mapConfig.bounds) {
            console.log('Applying coordinate bounds:', boundingParams.bottomLeftCoord, 'to', boundingParams.topRightCoord);
            var bounds = L.latLngBounds([
                [mapConfig.bounds.southwest.lat, mapConfig.bounds.southwest.lng],
                [mapConfig.bounds.northeast.lat, mapConfig.bounds.northeast.lng]
            ]);
            map.fitBounds(bounds, { padding: [10, 10] });
            return;
        }

        // Priority 5: Use default UK bounds if no specific bounds are set and no data layer
        if (!dataLayer && mapConfig.bounds) {
            console.log('Applying default bounds - no data available');
            var bounds = L.latLngBounds([
                [mapConfig.bounds.southwest.lat, mapConfig.bounds.southwest.lng],
                [mapConfig.bounds.northeast.lat, mapConfig.bounds.northeast.lng]
            ]);
            map.fitBounds(bounds, { padding: [10, 10] });
            return;
        }

        // Priority 6: Calculate bounds from occurrence data as fallback
        if (mapConfig.bounds) {
            console.log('Applying calculated bounds from occurrence data');
            var bounds = L.latLngBounds([
                [mapConfig.bounds.southwest.lat, mapConfig.bounds.southwest.lng],
                [mapConfig.bounds.northeast.lat, mapConfig.bounds.northeast.lng]
            ]);
            map.fitBounds(bounds, { padding: [10, 10] });
            return;
        }

        // Fallback: Try to fit bounds based on data layer
        if (dataLayer && typeof dataLayer.getBounds === 'function') {
            try {
                var layerBounds = dataLayer.getBounds();
                if (layerBounds.isValid()) {
                    console.log('Fitting bounds to data layer');
                    map.fitBounds(layerBounds, { padding: [20, 20] });
                    return;
                }
            } catch (e) {
                console.warn('Error getting layer bounds:', e);
            }
        }

        // Final fallback: Use default UK view
        console.log('Using default UK view');
        var fallbackLat = mapConfig.easymapDefaultLatitude || mapConfig.defaultLatitude || 55.378051;
        var fallbackLng = mapConfig.easymapDefaultLongitude || mapConfig.defaultLongitude || -3.435973;
        var fallbackZoom = mapConfig.easymapDefaultZoom || mapConfig.defaultZoom || 6;
        map.setView([fallbackLat, fallbackLng], fallbackZoom);
    }

    /**
     * Initialize EasyMap with provided configuration and data
     * @param {Object} options - Configuration options
     * @param {string} options.containerId - ID of the map container element
     * @param {Object} options.mapConfig - Map configuration object
     * @param {Array} options.occurrences - Array of occurrence data
     * @param {Object} options.dateBands - Date bands configuration
     * @param {Object} options.speciesInfo - Species information object
     * @param {string} options.tvk - Taxon Version Key
     * @param {string} options.zoomArea - Optional predefined zoom area
     * @param {string} options.viceCounty - Optional vice-county number
     * @param {string} options.bottomLeft - Optional bottom left grid reference
     * @param {string} options.topRight - Optional top right grid reference
     * @param {string} options.bottomLeftCoord - Optional bottom left coordinates
     * @param {string} options.topRightCoord - Optional top right coordinates
     * @returns {L.Map} The initialized Leaflet map instance
     */
    function initializeMap(options) {
        var containerId = options.containerId || 'easymap';
        var mapConfig = options.mapConfig || {};
        var occurrences = options.occurrences || [];
        var dateBands = options.dateBands || null;
        var speciesInfo = options.speciesInfo || {};
        var tvk = options.tvk;
        var zoomArea = options.zoomArea;
        var viceCounty = options.viceCounty;
        var bottomLeft = options.bottomLeft;
        var topRight = options.topRight;
        var bottomLeftCoord = options.bottomLeftCoord;
        var topRightCoord = options.topRightCoord;

        console.log('Initializing EasyMap for:', speciesInfo.scientificName || tvk);
        console.log('Date bands:', dateBands);
        console.log('Bounding parameters:', {
            zoomArea: zoomArea,
            viceCounty: viceCounty,
            bottomLeft: bottomLeft,
            topRight: topRight,
            bottomLeftCoord: bottomLeftCoord,
            topRightCoord: topRightCoord
        });

        // Set default coordinates using mapConfig or fallback values
        var defaultLat = mapConfig.easymapDefaultLatitude || mapConfig.defaultLatitude || 54.5;
        var defaultLng = mapConfig.easymapDefaultLongitude || mapConfig.defaultLongitude || -3.0;
        var defaultZoom = mapConfig.easymapDefaultZoom || mapConfig.defaultZoom || 6;

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

        // Get tile layer configuration from mapConfig or use defaults (TODO - move defaults to app config)
        var tileLayerUrl = mapConfig.easymapTileLayerMinimalUrl || 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png';
        var tileLayerAttribution = mapConfig.easymapTileLayerMinimalAttribution || '© OpenStreetMap contributors, © CartoDB';
        var tileLayerSubdomains = mapConfig.easymapTileLayerMinimalSubdomains || 'abcd';
        var tileLayerMaxZoom = parseInt(mapConfig.easymapTileLayerMinimalMaxZoom) || 18;

        // Create and add default base layer (no layer switching needed)
        var defaultBaseLayer = L.tileLayer(tileLayerUrl, {
            attribution: tileLayerAttribution,
            subdomains: tileLayerSubdomains,
            maxZoom: tileLayerMaxZoom
        });
        map.addLayer(defaultBaseLayer);

        // Add 10km grid WMS layer (TODO - use default from app config)
        var biocacheUrl = mapConfig.biocacheUrl || mapConfig.easymapBiocacheFallbackUrl || 'https://records-ws.nbnatlas.org';

        console.log('Using biocache URL:', biocacheUrl);

        var datasetFilter = options.datasetFilter || null;
        var color = options.color || mapConfig.easymapGridDefaultColor || 'df4a21';

        // Prepare grid configuration from mapConfig
        var gridConfig = {
            defaultColor: mapConfig.easymapGridDefaultColor,
            opacity: mapConfig.easymapGridOpacity,
            layers: mapConfig.easymapGridLayers,
            format: mapConfig.easymapGridFormat,
            colourMode: mapConfig.easymapGridColourMode,
            gridLabels: mapConfig.easymapGridGridLabels,
            gridResolution: mapConfig.easymapGridGridResolution
        };

        var gridLayers = addGridLayersWithDateBands(map, tvk, biocacheUrl, datasetFilter, dateBands, gridConfig);

        // Create bounding parameters object
        var boundingParams = {
            zoomArea: zoomArea,
            viceCounty: viceCounty,
            bottomLeft: bottomLeft,
            topRight: topRight,
            bottomLeftCoord: bottomLeftCoord,
            topRightCoord: topRightCoord
        };

        // Fit map to show all data or use specified bounds
        // Pass the first layer if any layers were created, otherwise null
        var firstGridLayer = gridLayers && gridLayers.length > 0 ? gridLayers[0] : null;
        fitMapBounds(map, firstGridLayer, mapConfig, boundingParams);

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
        console.log('Zoom area:', zoomArea || 'none');
        console.log('Biocache URL:', biocacheUrl);

        return map;
    }

    // Public API
    return {
        init: initializeMap
    };

})();

console.log('EasyMap module loaded');
