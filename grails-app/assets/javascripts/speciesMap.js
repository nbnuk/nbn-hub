/**
 * Species Map JavaScript
 * Handles the interactive map display for species distribution
 */

var speciesMap;
var markersLayer;

/**
 * Initialize the species map
 * @param config Configuration object containing map settings and data
 */
function initializeSpeciesMap(config) {
    console.log('Initializing species map with config:', config);

    try {
        // Hide loading indicator
        $('#mapLoading').fadeOut();

        // Initialize the map
        speciesMap = L.map('speciesMap').setView(
            [config.mapConfig.defaultLatitude, config.mapConfig.defaultLongitude],
            config.mapConfig.defaultZoom
        );

        // Add the base tile layer
        L.tileLayer(config.baseLayerUrl, {
            attribution: config.attribution,
            maxZoom: 18
        }).addTo(speciesMap);

        // Create markers layer group
        markersLayer = L.layerGroup().addTo(speciesMap);

        // Add occurrence markers if available
        if (config.occurrences && config.occurrences.length > 0) {
            addOccurrenceMarkers(config.occurrences);

            // Fit map to show all markers if we have bounds
            if (config.mapConfig.bounds) {
                var bounds = L.latLngBounds(
                    [config.mapConfig.bounds.southwest.lat, config.mapConfig.bounds.southwest.lng],
                    [config.mapConfig.bounds.northeast.lat, config.mapConfig.bounds.northeast.lng]
                );
                speciesMap.fitBounds(bounds, {padding: [10, 10]});
            }
        }

        console.log('Species map initialized successfully');

    } catch (error) {
        console.error('Error initializing species map:', error);
        $('#mapLoading').html('<div class="alert alert-danger">Error loading map: ' + error.message + '</div>');
    }
}

/**
 * Add occurrence markers to the map
 * @param occurrences Array of occurrence records
 */
function addOccurrenceMarkers(occurrences) {
    console.log('Adding ' + occurrences.length + ' occurrence markers');

    occurrences.forEach(function(occurrence, index) {
        if (occurrence.decimalLatitude && occurrence.decimalLongitude) {
            var lat = parseFloat(occurrence.decimalLatitude);
            var lng = parseFloat(occurrence.decimalLongitude);

            // Create marker
            var marker = L.marker([lat, lng])
                .bindPopup(createOccurrencePopup(occurrence))
                .addTo(markersLayer);
        }
    });
}

/**
 * Create popup content for an occurrence record
 * @param occurrence The occurrence record
 * @returns {string} HTML content for the popup
 */
function createOccurrencePopup(occurrence) {
    var popup = '<div class="occurrence-popup">';
    popup += '<h5>Occurrence Record</h5>';

    if (occurrence.id) {
        popup += '<p><strong>ID:</strong> ' + occurrence.id + '</p>';
    }

    if (occurrence.eventDate) {
        popup += '<p><strong>Date:</strong> ' + occurrence.eventDate + '</p>';
    }

    if (occurrence.dataResourceName) {
        popup += '<p><strong>Dataset:</strong> ' + occurrence.dataResourceName + '</p>';
    }

    if (occurrence.locality) {
        popup += '<p><strong>Locality:</strong> ' + occurrence.locality + '</p>';
    }

    popup += '<p><strong>Coordinates:</strong> ' +
             parseFloat(occurrence.decimalLatitude).toFixed(6) + ', ' +
             parseFloat(occurrence.decimalLongitude).toFixed(6) + '</p>';

    if (occurrence.coordinateUncertaintyInMeters) {
        popup += '<p><strong>Uncertainty:</strong> ' + occurrence.coordinateUncertaintyInMeters + 'm</p>';
    }

    popup += '</div>';
    return popup;
}

/**
 * Clear all markers from the map
 */
function clearMarkers() {
    if (markersLayer) {
        markersLayer.clearLayers();
    }
}

/**
 * Resize the map (useful when container size changes)
 */
function resizeMap() {
    if (speciesMap) {
        speciesMap.invalidateSize();
    }
}
