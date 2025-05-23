<div id="wmsModal" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                <h3 style="display: flex; justify-content: space-between; align-items: center;">
                    <div class="help-panel-toggle">
                        Current Map GIS Details
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
                    <li role="presentation" style="display: none;">
                        <a href="#geoJsonTab" aria-controls="geoJsonTab" role="tab" data-toggle="tab" id="geoJsonTabLink">GeoJSON</a>
                    </li>
                </ul>

                <div class="tab-content">
                    <!-- WMS Tab -->
                    <div role="tabpanel" class="tab-pane active" id="wmsTab">
                        <div class="form-group">
                            <label>Base WMS URL</label>
                            <input class="form-control" id="wmsBaseUrl"/>
                        </div>

                        <div class="form-group">
                            <label>WMS Parameters</label>
                            <textarea class="form-control" id="wmsParams" rows="8" style="font-family: monospace; white-space: pre;"></textarea>
                        </div>

                        <div class="form-group">
                            <label>Full WMS Request URL</label>
                            <textarea class="form-control" id="wmsFullUrl" rows="3" ></textarea>
                            <small class="text-muted">This shows the actual WMS request being used by the map. Parameters will update as you change the map display options.</small>
                        </div>
                    </div>

                    <!-- GeoJSON Tab -->
                    <div role="tabpanel" class="tab-pane" id="geoJsonTab" style="display: none;">
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
    // Add WMS button after target selector
    $('${targetSelector}').parent().after(
        $('<a>').attr({
            'href': '#wmsModal',
            'role': 'button',
            'data-toggle': 'modal',
            'class': 'btn btn-default btn-sm tooltips',
            'title': '${message(code: "map.wms.btn.title", default: "Generate WMS Query URL")}'
        }).html('<i class="fa fa-map"></i>&nbsp;&nbsp;${message(code: "map.wms.btn.label", default: "WMS")}')
    );

    initWmsButtonFunctionality();
});

/**
 * Converts occurrence records to GeoJSON format for mapping.
 * Takes an object containing an array of occurrence records and converts them to a GeoJSON FeatureCollection.
 * Each occurrence becomes a Point feature with coordinates and properties from the original record.
 * Records without valid coordinates are filtered out.
 *
 * @param {Object} occurrencesData - Object containing array of occurrence records in 'occurrences' property
 * @returns {Object} GeoJSON FeatureCollection containing Point features for each valid occurrence
 * @throws {Error} If input is missing the occurrences array
 */
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



function loadGeoJsonData() {
    // TODO: Replace with actual API URL
    const apiUrl = 'https://records-ws.legacy.nbnatlas.org/occurrences/search?q=*%3A*&qualityProfile=default';

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

$('.help-panel-toggle').on('click', function() {
    $(this).find('.fa').toggleClass('fa-rotate-180');
});

/**
 * Initializes functionality for the WMS modal dialog
 *
 * Sets up event handlers for:
 * - Showing the modal dialog and updating its content
 * - Copying WMS parameters to clipboard when copy button is clicked
 *
 * The copy functionality uses the modern Clipboard API if available,
 * falling back to a legacy approach using execCommand() if needed.
 * Shows a temporary "Copied!" message after successful copy.
 */
function initWmsButtonFunctionality() {
    $('#wmsModal').on('show.bs.modal', function() {
        updateWmsModalContent();
    });

    $('#copyWmsParameters').click(async function() {
        const wmsParams = $('#wmsParams').val();
        const button = $(this);
        const originalText = button.text();

        try {
            if (navigator.clipboard && window.isSecureContext) {
                await navigator.clipboard.writeText(wmsParams);
            } else {
                const textarea = document.createElement('textarea');
                textarea.value = wmsParams;
                textarea.style.position = 'fixed';
                textarea.style.opacity = '0';
                document.body.appendChild(textarea);
                textarea.select();
                document.execCommand('copy');
                document.body.removeChild(textarea);
            }

            button.text('${message(code: "map.wms.btn.copied", default: "Copied!")}');
            setTimeout(() => {
                button.text(originalText);
            }, 2000);
        } catch (err) {
            console.error('Failed to copy text: ', err);
            alert('Failed to copy text. Please try again.');
        }
    });
}

/**
 * Updates the content of the WMS modal dialog
 *
 * Retrieves the current map layer's WMS parameters and constructs a WMS request URL
 * based on the selected map display options.
 *
 * The function updates the WMS parameters and full URL in the modal dialog,
 * and also updates the base URL and formatted parameters in the modal form.
 */
function updateWmsModalContent() {
    var currentLayer = MAP_VAR.currentLayers[0];
    if (currentLayer) {
        var wmsParams = currentLayer.wmsParams;
        // Added /ogc/ows to the mappingUrl to match the WMS GetCapabilities request URL
        var baseUrl = MAP_VAR.mappingUrl + "/ogc/ows" + MAP_VAR.query;

        // Parse existing ENV parameters
        let envParams = {};
        if (wmsParams.ENV) {
            wmsParams.ENV.split(';').forEach(param => {
                if (param) {
                    let parts = param.split(':');
                    if (parts.length === 2) {
                        envParams[parts[0]] = parts[1];
                    }
                }
            });
        }

        // Update/add new ENV parameters
        envParams.size = $('#sizeslider-val').html();
        envParams.opacity = $('#opacityslider-val').html();
        envParams.outline = $('#outlineDots').is(':checked');
        envParams.colour = $('#pcolour').val().replace('#','').toUpperCase();

        // Convert back to ENV string format
        wmsParams.ENV = Object.entries(envParams)
            .map(entry => entry[0] + ':' + entry[1])
            .join(';');

        let formattedParams = Object.keys(wmsParams)
            .map(key => (key.toUpperCase() + ':').padEnd(20, ' ') + wmsParams[key])
            .sort()
            .join('\n');

        var fullUrl = baseUrl + '&' + Object.keys(wmsParams)
            .map(function(key) {
                return key + '=' + encodeURIComponent(wmsParams[key]);
            })
            .join('&');

        $('#wmsBaseUrl').val(baseUrl);
        $('#wmsParams').val(formattedParams);
        $('#wmsFullUrl').val(fullUrl);
    }
}
</script>
