<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EasyMap - ${mapData.speciesInfo.scientificName ?: mapData.tvk}</title>

    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
          integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>

    <!-- Custom CSS for EasyMap -->
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
        }

        .easymap-container {
            border: none;
            margin: 0;
            padding: 0;
        }



        .leaflet-popup-content {
            font-size: 12px;
        }

        .occurrence-marker {
            background-color: #df4a21;
            border: 2px solid #fff;
            border-radius: 50%;
            box-shadow: 0 1px 3px rgba(0,0,0,0.3);
        }
    </style>
</head>
<body>
    <div id="easymap" class="easymap-container"></div>

    <!-- Leaflet JavaScript -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
            integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

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
            var map = L.map('easymap').setView([defaultLat, defaultLng], defaultZoom);

            // Add tile layer
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors',
                maxZoom: 18
            }).addTo(map);

            // Add occurrence markers if we have data
            if (occurrences && occurrences.length > 0) {
                var markers = [];

                occurrences.forEach(function(occurrence) {
                    if (occurrence.latitude && occurrence.longitude) {
                        var marker = L.circleMarker([occurrence.latitude, occurrence.longitude], {
                            radius: 6,
                            fillColor: '#df4a21',
                            color: '#fff',
                            weight: 2,
                            opacity: 1,
                            fillOpacity: 0.8
                        });

                        // Create popup content
                        var popupContent = '<div>';
                        if (occurrence.scientificName) {
                            popupContent += '<strong>' + occurrence.scientificName + '</strong><br>';
                        }
                        if (occurrence.commonName) {
                            popupContent += '<em>' + occurrence.commonName + '</em><br>';
                        }
                        if (occurrence.eventDate) {
                            popupContent += 'Date: ' + occurrence.eventDate + '<br>';
                        }
                        if (occurrence.locality) {
                            popupContent += 'Location: ' + occurrence.locality + '<br>';
                        }
                        if (occurrence.basisOfRecord) {
                            popupContent += 'Basis: ' + occurrence.basisOfRecord + '<br>';
                        }
                        if (occurrence.dataResourceName) {
                            popupContent += 'Source: ' + occurrence.dataResourceName;
                        }
                        popupContent += '</div>';

                        marker.bindPopup(popupContent);
                        marker.addTo(map);
                        markers.push(marker);
                    }
                });

                // Fit map to show all markers if we have bounds
                if (mapConfig.bounds && markers.length > 0) {
                    var bounds = L.latLngBounds([
                        [mapConfig.bounds.southwest.lat, mapConfig.bounds.southwest.lng],
                        [mapConfig.bounds.northeast.lat, mapConfig.bounds.northeast.lng]
                    ]);
                    map.fitBounds(bounds, { padding: [10, 10] });
                }
            }

            // Add scale control
            L.control.scale().addTo(map);

            // Log configuration for debugging
            console.log('EasyMap initialized for TVK: ${mapData.tvk}');
            console.log('Map config:', mapConfig);
            console.log('Occurrences:', occurrences.length);
        });
    </script>
</body>
</html>
