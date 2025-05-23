<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Species Map - ${species?.scientificName ?: tvk}</title>

    <asset:stylesheet src="leaflet/leaflet.css"/>
    <asset:stylesheet src="speciesMap.css"/>
</head>
<body>
    <div class="container-fluid">

        <div class="row">
            <div class="col-md-12">
                <div class="species-header">
                    <g:if test="${species}">
                        <h1 class="species-scientific-name">
                            <em>${species.scientificName}</em>
                            <g:if test="${species.rank}">
                                <span class="species-rank badge badge-secondary">${species.rank}</span>
                            </g:if>
                        </h1>

                        <g:if test="${species.commonName}">
                            <h2 class="species-common-name">${species.commonName}</h2>
                        </g:if>

                        <div class="species-metadata">
                            <span class="tvk-info">
                                <strong>TVK:</strong> ${tvk}
                            </span>
                            <span class="occurrence-count">
                                <strong>Occurrences:</strong>
                                <span class="badge badge-primary">${occurrences?.size() ?: 0}</span>
                            </span>
                        </div>
                    </g:if>
                    <g:else>
                        <h1>Species Map - ${tvk}</h1>
                    </g:else>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">
                <div class="map-container">
                    <div id="speciesMap" class="species-map"></div>
                    <div id="mapLoading" class="map-loading">
                        <div class="loading-spinner">
                            <i class="fa fa-spinner fa-spin fa-2x"></i>
                            <p>Loading map...</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">
                <div class="occurrence-summary">
                    <g:if test="${occurrences && occurrences.size() > 0}">
                        <h3>Occurrence Summary</h3>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="summary-card">
                                    <h4>Total Records</h4>
                                    <p class="summary-number">${occurrences.size()}</p>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="summary-card">
                                    <h4>Map Center</h4>
                                    <p class="summary-text">
                                        ${String.format("%.4f", mapConfig.defaultLatitude)},
                                        ${String.format("%.4f", mapConfig.defaultLongitude)}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </g:if>
                    <g:else>
                        <div class="no-data-message">
                            <h3>No Occurrence Data</h3>
                            <p>No occurrence records found for ${species?.scientificName ?: tvk}</p>
                        </div>
                    </g:else>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">
                <div class="action-buttons">
                    <g:link controller="speciesMap" action="index" class="btn btn-secondary">
                        <i class="fa fa-arrow-left"></i> Back to Search
                    </g:link>
                </div>
            </div>
        </div>

    </div>

    <asset:javascript src="leaflet/leaflet.js"/>
    <asset:javascript src="speciesMap.js"/>

    <script type="text/javascript">
        window.SPECIES_MAP_DATA = {
            mapConfig: <g:applyCodec encodeAs="none">${mapConfig as grails.converters.JSON}</g:applyCodec>,
            occurrences: <g:applyCodec encodeAs="none">${occurrences as grails.converters.JSON}</g:applyCodec>,
            species: <g:applyCodec encodeAs="none">${species as grails.converters.JSON}</g:applyCodec>
        };

        var SPECIES_MAP_CONFIG = {
            tvk: '${tvk}',
            mapConfig: window.SPECIES_MAP_DATA.mapConfig,
            occurrences: window.SPECIES_MAP_DATA.occurrences,
            species: window.SPECIES_MAP_DATA.species,
            baseLayerUrl: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
            attribution: 'Map tiles by CartoDB'
        };

        console.log('Species map data loaded:', SPECIES_MAP_CONFIG);
        console.log('Number of occurrences:', SPECIES_MAP_CONFIG.occurrences ? SPECIES_MAP_CONFIG.occurrences.length : 0);

        $(document).ready(function() {
            console.log('Document ready, checking for map initialization...');
            console.log('Leaflet available:', typeof L !== 'undefined');
            console.log('initializeSpeciesMap function available:', typeof initializeSpeciesMap !== 'undefined');

            if (typeof initializeSpeciesMap === 'function') {
                console.log('Initializing species map...');
                initializeSpeciesMap(SPECIES_MAP_CONFIG);
            } else {
                console.error('Species map initialization function not found');
                $('#mapLoading').html('<div class="alert alert-danger">Map loading failed - initializeSpeciesMap function not found</div>');

                // Try to load the function and initialize after a delay
                setTimeout(function() {
                    console.log('Retrying map initialization...');
                    if (typeof initializeSpeciesMap === 'function') {
                        console.log('Found function on retry, initializing...');
                        initializeSpeciesMap(SPECIES_MAP_CONFIG);
                    } else {
                        console.error('Still no initializeSpeciesMap function after retry');
                        // Show data for debugging
                        $('#mapLoading').html('<div class="alert alert-info">' +
                            '<h5>Debug Information:</h5>' +
                            '<p>Leaflet available: ' + (typeof L !== 'undefined') + '</p>' +
                            '<p>Number of occurrences: ' + (SPECIES_MAP_CONFIG.occurrences ? SPECIES_MAP_CONFIG.occurrences.length : 0) + '</p>' +
                            '<p>Map config: ' + JSON.stringify(SPECIES_MAP_CONFIG.mapConfig) + '</p>' +
                            '</div>');
                    }
                }, 2000);
            }
        });
    </script>
</body>
</html>
