<g:set var="unconfirmedIdentificationCount" value="${
    (sr.facetResults?.find{it.fieldName=="identification_verification_status"}?.fieldResult.find{it.label=="Unconfirmed"}?.count ?: 0) +
    (sr.facetResults?.find{it.fieldName=="identification_verification_status"}?.fieldResult.find{it.label=="Unconfirmed - not reviewed"}?.count ?: 0) +
    (sr.facetResults?.find{it.fieldName=="identification_verification_status"}?.fieldResult.find{it.label=="Unconfirmed - plausible"}?.count ?: 0)
}"/>
<g:set var="absenceCount" value="${sr.facetResults?.find{it.fieldName=="occurrence_status"}?.fieldResult?.find{it.label?.equalsIgnoreCase("absent")}?.count}"/>
<g:set var="fossilCount" value="${sr.facetResults?.find{it.fieldName=="basis_of_record"}?.fieldResult?.find{it.label=="Fossil specimen"}?.count}"/>
<g:set var="licenceCount" value="${sr.facetResults?.find{it.fieldName=="license"}?.fieldResult?.find{it.label=="CC-BY-NC"}?.count}"/>
<g:set var="buttonCount" value="${(unconfirmedIdentificationCount > 0 ? 1 : 0) + (absenceCount > 0 ? 1 : 0) + (fossilCount > 0 ? 1 : 0) + (licenceCount > 0 ? 1 : 0)}"/>
<g:set var="absenceFilterPresent" value="${sr.activeFacetMap["-occurrence_status"]?.value?.equalsIgnoreCase('"absent"')}" />
<g:set var="commercialLicenceId" value="${grailsApplication.config.commercialLicenceId ?: 18}"/>

<div id="nbnDownloadMap" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="downloadsMapLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">×</button>
                <h3>
                    <g:message code="map.downloadmap.title" default="Download map"/>
                </h3>
            </div>

            <g:if test="${!userId}">
                <div class="modal-body">
                    <div id="saveSearchListPleaseLoginMessage" style="margin: 20px 20px;">Please login:
                        <a href="${grailsApplication.config.security.cas.casServerLoginUrl}?service=${(grailsApplication.config.serverName + request.contextPath + request.forwardURI + (request.queryString ? '?' + request.queryString : '')).encodeAsURL()}">
                            <g:message code="show.loginorflag.div01.navigator" default="Click here"/>
                        </a>
                    </div>
                </div>
            </g:if>
            <g:else>
                <div class="modal-body">
                    <div class="tab-content">
                        <div class="tab-pane active" id="nbnDownloadMap-step1">
                            <form class="margin-top-1" id="mapDownloadForm" action="/initMapDownload" method="post">
                                <input type="hidden" name="sourceTypeId" value="${alatag.getSourceId()}"/>
                                <input type="hidden" name="searchParams"
                                       value="${sr?.urlParameters ? URLDecoder.decode(sr.urlParameters, 'UTF-8') : ''}"/>
                                <input type="hidden" name="targetUri" value="${request.forwardURI}"/>
                                <input type="hidden" name="filename" value=""/>
                                <div class="form-group">
                                    <p>Select any records you wish to <b>remove</b> from the map:</p>

                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="excludeUnconfirmed" value="true"
                                                ${sr.totalRecords == unconfirmedIdentificationCount ? 'disabled' : ''}>
                                            unconfirmed identifications
                                                (<g:formatNumber number="${unconfirmedIdentificationCount ?: 0}" format="###,###,###,##0"/>)

                                            <g:if test="${sr.totalRecords == unconfirmedIdentificationCount}">
                                                <span class="text-muted"><i class="fa fa-warning"></i> this will exclude all records</span>
                                            </g:if>

                                        </label>
                                    </div>

                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="excludeAbsence" value="true"
                                                ${sr.totalRecords == absenceCount ? 'disabled' : ''}>
                                            absence records ${absenceFilterPresent ? "(excluded by default)" : ""}

                                                (<g:formatNumber number="${absenceCount ?: 0}" format="###,###,###,##0"/>)

                                            <g:if test="${sr.totalRecords == absenceCount}">
                                                <span class="text-muted"><i class="fa fa-warning"></i> this will exclude all records</span>
                                            </g:if>
                                        </label>
                                    </div>

                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" name="excludeFossil" value="true"
                                                ${sr.totalRecords == fossilCount ? 'disabled' : ''}>
                                            fossil records

                                                (<g:formatNumber number="${fossilCount ?: 0}" format="###,###,###,##0"/>)

                                            <g:if test="${sr.totalRecords == fossilCount}">
                                                <span class="text-muted"><i class="fa fa-warning"></i> this will exclude all records</span>
                                            </g:if>
                                        </label>
                                    </div>

                                    <div class="checkbox">
                                        <label for="excludeCCBYNC">
                                            <input type="checkbox" id="excludeCCBYNC" name="excludeCCBYNC" value="true"
                                                ${sr.totalRecords == licenceCount ? 'disabled' : ''}>
                                            records with a CC-BY-NC licence

                                                (<g:formatNumber number="${licenceCount ?: 0}" format="###,###,###,##0"/>)**

                                            <g:if test="${sr.totalRecords == licenceCount}">
                                                <span class="text-muted"><i class="fa fa-warning"></i> this will exclude all records</span>
                                            </g:if>
                                        </label>
                                    </div>
                                </div>


                                <div class="form-group">
                                    <label for="reasonTypeId">*<g:message
                                            code="download.reason.label" default="Reason for download"/></label>
                                    <select class="form-control" id="reasonTypeId" name="reasonTypeId">
                                        <option value="" disabled selected><g:message
                                                code="download.reason.placeholder"/></option>
                                        <g:each var="it" in="${downloads.getLoggerReasons()}">
                                            <option value="${it.id}"><g:message code="download.reason.type${it.id}"
                                                                                default="${it.name}"/></option>
                                        </g:each>
                                    </select>

                                    <p class="help-block"><g:message code="download.choose.best.use.type"/>
                                    </p>
                                </div>

                                <div class="form-group">
                                    <input type="checkbox" id="nbnMapDownloadConfirmLicense"
                                           name="nbnMapDownloadConfirmLicense"/>
                                    <label for="nbnMapDownloadConfirmLicense">
                                        *Accept licencing
                                    </label>

                                    <p class="help-block">**<g:message code="download.license.accept"/>
                                    </p>

                                </div>
                            </form>

                            <div class="text-right">
                                <button type="button" class="btn btn-default" data-dismiss="modal"><g:message
                                        code="download.button.close" default="Close"/></button>
                                <button class="btn btn-primary next-btn" data-next="step2">Next</button>
                            </div>
                        </div>

                        <div class="tab-pane" id="nbnDownloadMap-step2">
                            <!-- Download options form -->
                            <div class="form-group">
                                <label for="downloadFilename"><g:message code="map.downloadmap.field10.label"
                                                                         default="File name (without extension)"/></label>
                                <input type="text" id="downloadFilename" class="form-control"
                                       value="<g:message code="map.downloadmap.default.filename" default="MyMap"/>">
                            </div>

                            <div class="form-group">
                                <label for="downloadFormat"><g:message code="map.downloadmap.field01.label"
                                                                       default="Format"/></label>
                                <select id="downloadFormat" class="form-control">
                                    <option value="jpg"><g:message code="map.downloadmap.field01.option01"
                                                                   default="JPEG"/></option>
                                    <option value="png"><g:message code="map.downloadmap.field01.option02"
                                                                   default="PNG"/></option>
                                </select>
                            </div>

                            <hr>
                            <div class="btn-group-vertical" role="group" aria-label="...">
                                <button id="downloadMapImage" class="btn btn-link" style="text-align:left">
                                    <i class="fa fa-download"></i> <g:message
                                        code="map.downloadmap.nbn.downloadimage.label"
                                        default="Download map image"/>
                                </button>
                                <button id="downloadCitationsAndReadme" class="btn btn-link" style="text-align:left">
                                    <i class="fa fa-download"></i> <g:message
                                        code="map.downloadmap.nbn.downloadcitation.label"
                                        default="Download citations and README"/>
                                </button>
                            </div>

                            <div class="form-group">
                                <div class="text-right">
                                    <button class="btn btn-primary next-btn" data-prev="step1">Prev</button>
                                    <button type="button" class="btn btn-default" data-dismiss="modal"><g:message
                                            code="download.button.close" default="Close"/></button>

                                </div>
                            </div>

                            <div id="mapDownloadLoginAgainMessage" class="alert alert-danger text-right hidden">
                                Sorry, you need to
                                <a href="${grailsApplication.config.security.cas.casServerLoginUrl}?service=${(grailsApplication.config.serverName + request.contextPath + request.forwardURI + (request.queryString ? '?' + request.queryString : '')).encodeAsURL()}">
                                    login
                                </a>
                                again.
                            </div>
                        </div>

                    </div>
                </div>
            </g:else>

        </div>
    </div>

    <!-- Add a hidden div for the export map -->
    <div id="leafletMapExport"
         style="position: absolute; top: -9999px; left: -9999px; width: 800px; height: 600px; z-index: -1000;"></div>

</div>
<script>
    // Leaflet 0.7.x → 1.x shims for leaflet-image
    (function (L) {
        if (!L) return;

        // Add Point#scaleBy / #unscaleBy expected by Leaflet 1.x plugins
        if (!L.Point.prototype.scaleBy) {
            L.Point.prototype.scaleBy = function (pt) {
                return new L.Point(this.x * pt.x, this.y * pt.y);
            };
        }
        if (!L.Point.prototype.unscaleBy) {
            L.Point.prototype.unscaleBy = function (pt) {
                return new L.Point(this.x / pt.x, this.y / pt.y);
            };
        }

        // Leaflet 1.x added _getTileSize(); mimic it for 0.7.x
        if (!L.TileLayer.prototype._getTileSize) {
            L.TileLayer.prototype._getTileSize = function () {
                var s = this.options.tileSize;
                return (s instanceof L.Point) ? s : L.point(s, s);
            };
        }

        // Some plugins call DomUtil.setTransform; safe no-op polyfill
        if (!L.DomUtil.setTransform) {
            L.DomUtil.setTransform = function (el, offset, scale) {
                var pos = offset || new L.Point(0, 0);
                el.style[L.DomUtil.TRANSFORM] =
                    'translate(' + pos.x + 'px,' + pos.y + 'px)' +
                    (scale ? ' scale(' + scale + ')' : '');
            };
        }
    })(window.L);
</script>

<script src="https://unpkg.com/leaflet-image/leaflet-image.js"></script>


<asset:script type="text/javascript">

    $(document).ready(function () {

        $('.next-btn').on('click', function () {
            var valid = true;

            // Reset labels first
            $('label[for="reasonTypeId"], label[for="nbnMapDownloadConfirmLicense"], label[for="excludeCCBYNC"]')
                .removeClass('text-required').css('font-weight', 'normal');


            // Check select box
            if ($('#reasonTypeId').val() === null || $('#reasonTypeId').val() === '') {
                $('label[for="reasonTypeId"]').addClass('text-required').css('font-weight', 'bold');
                valid = false;
            }

            // Check checkbox
            if (!$('#nbnMapDownloadConfirmLicense').is(':checked')) {
                $('label[for="nbnMapDownloadConfirmLicense"]').addClass('text-required').css('font-weight', 'bold');
                valid = false;
            }

    <g:if test="${licenceCount}">
        if (!$('#excludeCCBYNC').is(':checked') && $('#reasonTypeId').val() =='${commercialLicenceId}') {
                $('label[for="excludeCCBYNC"]').addClass('text-required').css('font-weight', 'bold');
                valid = false;
            }
        </g:if>

            // Only proceed if all fields are valid
            if (valid) {
                var nextTab = $("#nbnDownloadMap-step2");
            $('#nbnDownloadMap-step1').removeClass('active');
            $(nextTab).addClass('active');
            }
        });



        $('#nbnDownloadMap [data-prev=step1]').on('click', function () {
            var nextTab = $("#nbnDownloadMap-step1");
            $('#nbnDownloadMap-step2').removeClass('active');
            $(nextTab).addClass('active');
        });

        $('#nbnDownloadMap').on('hide.bs.modal', function (e) {
          // e.preventDefault(); // uncomment to block closing
          $('#nbnDownloadMap-step1').removeClass('active');
          $('#nbnDownloadMap-step2').removeClass('active');
          $('#nbnDownloadMap-step1').addClass('active');
        });

        function removeExcludedRecords(url){
            var excludeUnconfirmed = $('#mapDownloadForm input[name="excludeUnconfirmed"]').is(':checked');
            var excludeAbsence = $('#mapDownloadForm input[name="excludeAbsence"]').is(':checked');
            var excludeFossil = $('#mapDownloadForm input[name="excludeFossil"]').is(':checked');
            var excludeCCBYNC = $('#mapDownloadForm input[name="excludeCCBYNC"]').is(':checked');

            if(excludeUnconfirmed){
                url += '&fq=-(identification_verification_status%3A"Unconfirmed" OR identification_verification_status%3A"Unconfirmed - not reviewed" OR identification_verification_status%3A"Unconfirmed - plausible")';
            }
            if(excludeAbsence){
                url += '&fq=-occurrence_status:absent';
            }
            if(excludeFossil){
                url += '&fq=-basis_of_record:FossilSpecimen';
            }
            if(excludeCCBYNC){
                url += '&fq=-license:CC-BY-NC';
            }
            return url;
        }

        function executeMapDownload(){
            // Get filename and format from inputs
            var filename = $('#downloadFilename').val().trim() || 'map_export';
            var format = $('#downloadFormat').val();

            // Disable all links and inputs in the download modal and show loading indicator
            $('#nbnDownloadMap a, #nbnDownloadMap input, #nbnDownloadMap select').addClass('disabled').prop('disabled', true).css('pointer-events', 'none').css('opacity', '0.6');
            var icon = $('#downloadMapImage').find('i');
            icon.addClass('fa-spinner fa-spin').removeClass('fa-download');

            createExportMap(function(exportMap) {
                // Use leaflet-image on the hidden export map
                leafletImage(exportMap, function(err, canvas) {
                    // Clean up the export map
                    exportMap.remove();
                    $('#leafletMapExport').empty();

                    // Reset the download button and re-enable links and inputs
                    icon.addClass('fa-download').removeClass('fa-spinner fa-spin');
                    $('#nbnDownloadMap a, #nbnDownloadMap input, #nbnDownloadMap select').removeClass('disabled').prop('disabled', false).css('pointer-events', 'auto').css('opacity', '1');

                    if (err) {
                        console.error('Error generating map image:', err);
                        alert('Error generating map image. Please try again.');
                        return;
                    }

                    // Convert canvas to blob and download with selected format
                    var mimeType = 'image/' + format;
                    var quality = format === 'jpeg' ? 0.9 : undefined; // JPEG quality

                    canvas.toBlob(function(blob) {
                        var link = document.createElement('a');
                        link.download = filename + '.' + format;
                        link.href = URL.createObjectURL(blob);
                        link.click();
                        URL.revokeObjectURL(link.href);
                    }, mimeType, quality);
                });
            });
        }

        document.querySelectorAll('a[href="#downloadMap"]').forEach(link => {
           link.href = '#nbnDownloadMap';
        });

        $('#downloadCitationsAndReadme').on('click', function (e) {
            e.preventDefault();

            var icon = $(this).find('i');
            var filename = $('#downloadFilename').val().trim()+'.citations_and_readme' || 'map_export.citations_and_readme';
            var url = MAP_VAR.mappingUrl + "/mapping/downloadCitationsAndReadme" + MAP_VAR.query + MAP_VAR.additionalFqs+ '&filename=' + encodeURIComponent(filename);
            url = removeExcludedRecords(url);
            icon.removeClass('fa-download').addClass('fa-spinner fa-spin');
            $('#nbnDownloadMap a, #nbnDownloadMap input, #nbnDownloadMap select').addClass('disabled').prop('disabled', true).css('pointer-events', 'none').css('opacity', '0.6');

            // Create a temporary link to trigger the download
            var link = document.createElement('a');
            link.href = url;
            link.download = filename;
            link.style.display = 'none';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            setTimeout(() => {
                icon.removeClass('fa-spinner fa-spin').addClass('fa-download');
                $('#nbnDownloadMap a, #nbnDownloadMap input, #nbnDownloadMap select').removeClass('disabled').prop('disabled', false).css('pointer-events', 'auto').css('opacity', '1');
            }, 2000);

        });

        $('#downloadMapImage').on('click', function (e) {
            e.preventDefault();

            var filename = $('#downloadFilename').val().trim() || 'map_export';
            $('#mapDownloadForm input[name="filename"]').val(filename);

            var form = $('#mapDownloadForm');

            if (form.length) {
                $.ajax({
                    url: form.attr('action'),
                    type: form.attr('method'),
                    data: form.serialize(),
                    success: function (response) {
                        executeMapDownload();
                    },
                    error: function (xhr, status, error) {

                        if (xhr.status === 401) {
                            $('#mapDownloadLoginAgainMessage').removeClass('hidden');
                            return;

                        }
                        //if not 401, then ignore error (like download serverside does). It's only logging the download
                        // and error has been logged on the backend
                        executeMapDownload();
                        return;

                    }
                })
            }
        });




        //create a hidden map for export
        function createExportMap(callback) {
            var mainMapContainer = MAP_VAR.map.getContainer();
            var mapWidth = mainMapContainer.offsetWidth;
            var mapHeight = mainMapContainer.offsetHeight;

            // Ensure the export div is properly sized and positioned
            var exportDiv = document.getElementById('leafletMapExport');
            exportDiv.style.position = 'absolute';
            exportDiv.style.top = '-9999px';
            exportDiv.style.left = '-9999px';
            exportDiv.style.width = mapWidth + 'px';
            exportDiv.style.height = mapHeight + 'px';
            exportDiv.style.zIndex = '-1000';
            exportDiv.style.visibility = 'hidden'; // Hidden but still rendered

            // Create a temporary map in the hidden div
            var exportMap = L.map('leafletMapExport', {
                center: MAP_VAR.map.getCenter(),
                zoom: MAP_VAR.map.getZoom(),
                minZoom: MAP_VAR.map.getMinZoom(),
                maxZoom: MAP_VAR.map.getMaxZoom(),
                zoomControl: false,
                attributionControl: false,
                preferCanvas: false // Ensure DOM rendering for leaflet-image
            });

            // Force the map to recognize its container size
            setTimeout(function() {
                exportMap.invalidateSize();

                // Get the current base layer from the main map
                var currentBaseLayer = null;
                MAP_VAR.map.eachLayer(function(layer) {
                    if (layer instanceof L.TileLayer && MAP_VAR.map.hasLayer(layer)) {
                        // Check if this is one of our base layers
                        Object.keys(MAP_VAR.baseLayers).forEach(function(key) {
                            if (MAP_VAR.baseLayers[key] === layer) {
                                currentBaseLayer = layer;
                            }
                        });
                    }
                });

                // Add the same base layer to export map
                var exportBaseLayer;
                if (currentBaseLayer) {
                    exportBaseLayer = L.tileLayer(currentBaseLayer._url, currentBaseLayer.options);
                    exportMap.addLayer(exportBaseLayer);
                } else {
                    // Fallback to default base layer
                    exportMap.addLayer(defaultBaseLayer);
                }

                // Copy the current data layers
                MAP_VAR.currentLayers.forEach(function(layer) {
                    if (layer instanceof L.TileLayer.WMS) {
                        var url = removeExcludedRecords(layer._url);
                        var exportDataLayer = L.tileLayer.wms(url, layer.options);
                        exportMap.addLayer(exportDataLayer);
                    }
                });

                // Wait for tiles to load before calling callback
                var tilesLoaded = 0;
                var totalLayers = 1 + MAP_VAR.currentLayers.length; // base layer + data layers

                function checkTilesLoaded() {
                    tilesLoaded++;
                    if (tilesLoaded >= totalLayers) {
                        // Give a small delay to ensure rendering is complete
                        setTimeout(function() {
                            callback(exportMap);
                        }, 500);
                    }
                }

                // Listen for tile load events
                exportMap.eachLayer(function(layer) {
                    if (layer instanceof L.TileLayer || layer instanceof L.TileLayer.WMS) {
                        layer.on('load', checkTilesLoaded);
                        layer.on('tileerror', checkTilesLoaded); // Count errors too to avoid hanging
                    }
                });

                // Fallback timeout in case tiles don't load
                setTimeout(function() {
                    if (tilesLoaded < totalLayers) {
                        console.warn('Not all tiles loaded, proceeding with export anyway');
                        callback(exportMap);
                    }
                }, 5000);

            }, 100); // Added missing timeout delay and closing bracket
        }


    });

</asset:script>

<style>
.text-required {
    color: #3e8f3e;
}
</style>



