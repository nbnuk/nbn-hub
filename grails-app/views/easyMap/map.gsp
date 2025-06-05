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
