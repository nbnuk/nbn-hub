<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EasyMap - ${mapData.speciesInfo.scientificName ?: mapData.tvk}</title>

    <!-- EasyMap CSS includes Leaflet -->
    <asset:stylesheet src="easymap.css"/>
</head>
<body>
    <div id="easymap" class="easymap-container"></div>

    <!-- EasyMap JavaScript includes Leaflet -->
    <asset:javascript src="easymap.js"/>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Set dimensions for the map containers
            var mapWidth = ${width};
            var mapHeight = ${height};

            // Apply dimensions to containers
            document.querySelector('.easymap-container').style.width = mapWidth + 'px';
            document.querySelector('.easymap-container').style.height = mapHeight + 'px';

            // Set body dimensions to match map
            document.body.style.width = mapWidth + 'px';
            document.body.style.height = mapHeight + 'px';
            document.body.style.overflow = 'hidden';

            // Initialize map configuration from server data
            var mapConfig = ${raw(mapConfigJson)};
            var occurrences = ${raw(occurrencesJson)};
            var speciesInfo = ${raw(speciesInfoJson)};

            // Set default coordinates (UK bounds)
            var defaultLat = mapConfig.defaultLatitude || 54.5;
            var defaultLng = mapConfig.defaultLongitude || -3.0;
            var defaultZoom = mapConfig.defaultZoom || 6;

            // Initialize the map
            var map = L.map('easymap', {
                center: [defaultLat, defaultLng],
                zoom: defaultZoom,
                minZoom: 1,
                maxZoom: 18,
                scrollWheelZoom: true,
                worldCopyJump: true
            });

            // Use the same tile layer as the main NBN Atlas occurrence map (CartoDB Light)
            var defaultBaseLayer = L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors, © CartoDB',
                subdomains: 'abcd',
                maxZoom: 18
            });

            // Add the default base layer
            map.addLayer(defaultBaseLayer);

            // Define base layers similar to main occurrence map
            var baseLayers = {
                "Minimal": defaultBaseLayer,
                "OpenStreetMap": L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '© OpenStreetMap contributors',
                    maxZoom: 18
                })
            };

            // Add layer control
            var layerControl = L.control.layers(baseLayers, {}, {
                collapsed: true,
                position: 'topleft'
            });
            layerControl.addTo(map);

            // Function to get marker color based on basis of record
            function getMarkerColor(basisOfRecord) {
                switch(basisOfRecord) {
                    case 'HumanObservation':
                        return '#df4a21'; // NBN Atlas orange
                    case 'PreservedSpecimen':
                        return '#2e8b57'; // Sea green
                    case 'MachineObservation':
                        return '#4169e1'; // Royal blue
                    default:
                        return '#808080'; // Gray for unknown
                }
            }

            // Function to get readable basis of record name
            function getBasisOfRecordName(basisOfRecord) {
                switch(basisOfRecord) {
                    case 'HumanObservation':
                        return 'Human Observation';
                    case 'PreservedSpecimen':
                        return 'Preserved Specimen';
                    case 'MachineObservation':
                        return 'Machine Observation';
                    default:
                        return basisOfRecord || 'Unknown';
                }
            }

            // Add occurrence markers if we have data
            if (occurrences && occurrences.length > 0) {
                var markers = [];
                var markerGroup = L.featureGroup();

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

                        // Create detailed popup content
                        var popupContent = '<div style="min-width: 200px;">';
                        if (occurrence.scientificName) {
                            popupContent += '<strong>' + occurrence.scientificName + '</strong><br>';
                        }
                        if (occurrence.commonName) {
                            popupContent += '<em>' + occurrence.commonName + '</em><br>';
                        }
                        popupContent += '<hr style="margin: 5px 0;">';

                        if (occurrence.eventDate) {
                            popupContent += '<strong>Date:</strong> ' + occurrence.eventDate + '<br>';
                        }
                        if (occurrence.locality) {
                            popupContent += '<strong>Location:</strong> ' + occurrence.locality + '<br>';
                        }
                        if (occurrence.basisOfRecord) {
                            popupContent += '<strong>Basis:</strong> ' + getBasisOfRecordName(occurrence.basisOfRecord) + '<br>';
                        }
                        if (occurrence.dataResourceName) {
                            popupContent += '<strong>Source:</strong> ' + occurrence.dataResourceName + '<br>';
                        }
                        if (occurrence.recordedBy) {
                            popupContent += '<strong>Recorded by:</strong> ' + occurrence.recordedBy + '<br>';
                        }
                        if (occurrence.coordinateUncertaintyInMeters) {
                            popupContent += '<strong>Uncertainty:</strong> ' + occurrence.coordinateUncertaintyInMeters + 'm<br>';
                        }

                        popupContent += '</div>';

                        marker.bindPopup(popupContent, {
                            maxWidth: 300,
                            className: 'occurrence-popup'
                        });

                        markerGroup.addLayer(marker);
                        markers.push(marker);
                    }
                });

                // Add all markers to map
                map.addLayer(markerGroup);

                // Fit map to show all markers if we have bounds
                if (mapConfig.bounds && markers.length > 0) {
                    var bounds = L.latLngBounds([
                        [mapConfig.bounds.southwest.lat, mapConfig.bounds.southwest.lng],
                        [mapConfig.bounds.northeast.lat, mapConfig.bounds.northeast.lng]
                    ]);
                    map.fitBounds(bounds, { padding: [10, 10] });
                } else if (markers.length > 0) {
                    // Fallback: fit to marker bounds
                    map.fitBounds(markerGroup.getBounds(), { padding: [10, 10] });
                }
            }

            // Add scale control
            L.control.scale({
                position: 'bottomright',
                imperial: false,
                metric: true
            }).addTo(map);

            // Add legend control showing marker colors and meanings
            var legend = L.control({position: 'bottomleft'});
            legend.onAdd = function(map) {
                var div = L.DomUtil.create('div', 'legend');
                div.innerHTML = '<h4>Record Types</h4>' +
                    '<div class="legend-item"><i style="background: #df4a21"></i>Human Observation</div>' +
                    '<div class="legend-item"><i style="background: #2e8b57"></i>Preserved Specimen</div>' +
                    '<div class="legend-item"><i style="background: #4169e1"></i>Machine Observation</div>' +
                    '<div class="legend-item"><i style="background: #808080"></i>Unknown/Other</div>';
                return div;
            };
            legend.addTo(map);

            // Add attribution control with NBN Atlas branding
            map.attributionControl.setPrefix('NBN Atlas EasyMap | Powered by <a href="http://leafletjs.com" title="A JS library for interactive maps">Leaflet</a>');

            // Log configuration for debugging
            console.log('EasyMap initialized for TVK: ${mapData.tvk}');
            console.log('Map config:', mapConfig);
            console.log('Occurrences:', occurrences.length);
            console.log('Species info:', speciesInfo);
        });
    </script>
</body>
</html>
