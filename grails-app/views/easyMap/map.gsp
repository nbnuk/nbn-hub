<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EasyMap - ${mapData.speciesInfo.scientificName ?: mapData.tvk}</title>

    <!-- EasyMap CSS includes Leaflet -->
    <asset:stylesheet src="easymap.css"/>
    <g:if test="${mapData.css}">
        <link type="text/css" rel="stylesheet" href="${mapData.css}">
    </g:if>
</head>
<body>
    <g:if test="${mapData.maponly != '1'}">
        <!-- Non-map-only layout with optional surrounding content -->
        <div><span id="lblDistribution">
            <g:if test="${mapData.title && mapData.title != '0'}">
                <h3>
                    <g:if test="${mapData.title == 'com' && mapData.speciesInfo.commonName}">
                        ${mapData.speciesInfo.commonName}
                    </g:if>
                    <g:else>
                        ${mapData.speciesInfo.scientificName ?: mapData.tvk}
                    </g:else>
                </h3>
            </g:if>

            <g:if test="${mapData.terms != '0'}">
                <p>The National Biodiversity Network records are shown on the map below. (See <a href="https://nbnatlas.org/help/nbn-atlas-terms-use/" target="_blank">terms and conditions</a>)</p>
            </g:if>

            <div id="easymap" class="easymap-container"></div>

            <g:if test="${mapData.link != '0'}">
                <br>
                <a href="${mapData.interactiveMapUrl}" target="_blank">Open interactive map in new window</a>
            </g:if>

            <g:if test="${mapData.ref != '0' && mapData.datasetFilter}">
                <p>The following datasets are included:</p>
                <ul>
                    <g:each in="${mapData.datasetFilter.split(',')}" var="dataset">
                        <li>${dataset.trim()}</li>
                    </g:each>
                </ul>
            </g:if>

            <g:if test="${mapData.logo != '0'}">
                <br>
                <a href="https://nbnatlas.org/" target="_blank">
                    <asset:image src="NBNPower.gif" alt="NBN Atlas"/>
                </a>
            </g:if>
        </span></div>
    </g:if>
    <g:else>
        <!-- Map-only layout -->
        <div id="easymap" class="easymap-container"></div>
    </g:else>

    <!-- EasyMap JavaScript includes Leaflet -->
    <asset:javascript src="easymap.js"/>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Set dimensions for the map containers
            var mapWidth = ${width};
            var mapHeight = ${height};
            var isMapOnly = ${mapData.maponly == '1' ? 'true' : 'false'};

            // Apply dimensions to containers
            document.querySelector('.easymap-container').style.width = mapWidth + 'px';
            document.querySelector('.easymap-container').style.height = mapHeight + 'px';

            // Map-only mode styling
            if (isMapOnly) {
                document.body.style.width = mapWidth + 'px';
                document.body.style.height = mapHeight + 'px';
                document.body.style.overflow = 'hidden';
                document.body.style.margin = '0';
                document.body.style.padding = '0';
            }

            // Initialize map configuration from server data
            var mapConfig = ${raw(mapConfigJson)};
            var occurrences = ${raw(occurrencesJson)};
            var speciesInfo = ${raw(speciesInfoJson)};
            var dateBands = ${raw(dateBandsJson)};

            // Use acceptedTvk if available, otherwise fall back to original tvk
            var tvkForQuery = speciesInfo.acceptedTvk || '${mapData.tvk}';

            var map = EasyMap.init({
                containerId: 'easymap',
                mapConfig: mapConfig,
                occurrences: occurrences,
                dateBands: dateBands,
                speciesInfo: speciesInfo,
                tvk: tvkForQuery,
                datasetFilter: '${raw(mapData.datasetFilter ?: "")}',
                color: '${raw(mapData.b0fill ?: "df4a21")}',
                background: '${raw(mapData.bg ?: "")}',
                gridResolution: '${raw(mapData.gridResolution ?: "10km")}',
                zoomArea: '${raw(mapData.zoomArea ?: "")}'
            });
        });
    </script>
</body>
</html>
