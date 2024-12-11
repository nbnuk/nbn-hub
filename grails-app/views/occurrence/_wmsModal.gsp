<div id="wmsModal" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                <h3 style="display: flex; justify-content: space-between; align-items: center;">
                    <div class="help-panel-toggle">
                        Current WMS Layer Details
                        <span class="beta-tag">BETA</span>
                    </div>
                    <div class="help-panel-toggle" data-toggle="collapse" data-target="#helpPanel">
                        Help and Feedback Request <i class="fa fa-chevron-down"></i>
                    </div>
                </h3>
                <div id="helpPanel" class="collapse">
                    <div class="help-panel-content">
                        <h4>About this feature</h4>
                        <p>This WMS feature is intended to make it easier for you to use the NBN Atlas map in your GIS application.</p>

                        <h4>We value your feedback</h4>
                        <p>We'd very much like feedback on how useful this is to you and how it can be improved.</p>
                        <div class="feedback-options">
                            <a href="mailto:support@nbnatlas.org" class="btn btn-primary feedback-btn">
                                <i class="fa fa-envelope"></i> Email Support
                            </a>
                            <a href="https://forums.nbn.org.uk/viewforum.php?id=46" class="btn btn-primary feedback-btn" target="_blank" rel="noopener">
                                <i class="fa fa-comments"></i> Support Forum
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-body">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active">
                        <a href="#wmsTab" aria-controls="wmsTab" role="tab" data-toggle="tab">WMS</a>
                    </li>
                    <li role="presentation">
                        <a href="#geoJsonTab" aria-controls="geoJsonTab" role="tab" data-toggle="tab" id="geoJsonTabLink">GeoJSON</a>
                    </li>
                </ul>

                <div class="tab-content">
                    <!-- WMS Tab -->
                    <div role="tabpanel" class="tab-pane active" id="wmsTab">
                        <div class="form-group">
                            <label><g:message code="map.wms.baseurl.label" default="Base WMS URL"/></label>
                            <input class="form-control" id="wmsBaseUrl" readonly/>
                        </div>

                        <div class="form-group">
                            <label><g:message code="map.wms.params.label" default="WMS Parameters"/></label>
                            <textarea class="form-control" id="wmsParams" rows="8" readonly style="font-family: monospace; white-space: pre;"></textarea>
                        </div>

                        <div class="form-group">
                            <label><g:message code="map.wms.fullurl.label" default="Full WMS Request URL"/></label>
                            <textarea class="form-control" id="wmsFullUrl" rows="3" readonly></textarea>
                            <small class="text-muted">
                                <g:message code="map.wms.help" default="This shows the actual WMS request being used by the map. Parameters will update as you change the map display options."/>
                            </small>
                        </div>
                    </div>

                    <!-- GeoJSON Tab -->
                    <div role="tabpanel" class="tab-pane" id="geoJsonTab">
                        <textarea class="form-control" id="geoJsonContent" rows="15" readonly style="font-family: monospace; white-space: pre;">
Loading GeoJSON data...</textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-default" data-dismiss="modal" aria-hidden="true">
                    <g:message code="map.wms.btn.close" default="Close"/>
                </button>
                <button type="button" class="btn btn-primary" id="copyWmsParameters">
                    <g:message code="map.wms.btn.copy" default="Copy WMS Parameters"/>
                </button>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    function occurrencesToGeoJSON(occurrencesData) {
        // Validate input has occurrences array
        if (!occurrencesData.occurrences || !Array.isArray(occurrencesData.occurrences)) {
            throw new Error('Invalid input: missing occurrences array');
        }

        return {
            type: "FeatureCollection",
            features: occurrencesData.occurrences.map(occurrence => {
                // Skip records without coordinates
                if (!occurrence.decimalLatitude || !occurrence.decimalLongitude) {
                    return null;
                }

                return {
                    type: "Feature",
                    geometry: {
                        type: "Point",
                        coordinates: [
                            occurrence.decimalLongitude,
                            occurrence.decimalLatitude
                        ]
                    },
                    properties: {
                        uuid: occurrence.uuid,
                        scientificName: occurrence.scientificName,
                        vernacularName: occurrence.vernacularName,
                        eventDate: occurrence.eventDate,
                        year: occurrence.year,
                        month: occurrence.month,
                        kingdom: occurrence.kingdom,
                        family: occurrence.family,
                        genus: occurrence.genus,
                        species: occurrence.species,
                        basisOfRecord: occurrence.basisOfRecord,
                        dataResourceName: occurrence.dataResourceName,
                        license: occurrence.license,
                        coordinateUncertaintyInMeters: occurrence.coordinateUncertaintyInMeters,
                        sensitive: occurrence.sensitive,
                        publicResolutionInMeters: occurrence.publicResolutionInMeters
                    }
                };
            }).filter(feature => feature !== null) // Remove any null features
        };
    }

    // Function to load GeoJSON data
    function loadGeoJsonData() {
        const apiUrl = 'https://records-ws.legacy.nbnatlas.org/occurrences/search?q=taxa%3A%22Water%20Crowfoot%22&qualityProfile=default&fq=-occurrence_status%3A%22absent%22';

        if (!apiUrl) {
            $('#geoJsonContent').val('Error: API URL not found');
            return;
        }

        $.ajax({
            url: apiUrl,
            method: 'GET',
            success: function(data) {
                try {
                    const geoJson = occurrencesToGeoJSON(data);
                    $('#geoJsonContent').val(JSON.stringify(geoJson, null, 2));
                } catch (error) {
                    $('#geoJsonContent').val('Error converting data to GeoJSON: ' + error.message);
                }
            },
            error: function(xhr, status, error) {
                $('#geoJsonContent').val('Error fetching data: ' + error);
            }
        });
    }

    // Load GeoJSON when tab is shown
    $('a[href="#geoJsonTab"]').on('shown.bs.tab', function (e) {
        loadGeoJsonData();
    });
});
</script>
