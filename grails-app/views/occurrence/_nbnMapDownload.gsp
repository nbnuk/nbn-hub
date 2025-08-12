

<div id="nbnDownloadMap" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="downloadsMapLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">×</button>
                <h3>
                    Download Map
                </h3>
            </div>
            <div class="modal-body">
                <!-- Download options form -->
                <div class="form-group">
                    <label for="downloadFilename">Filename:</label>
                    <input type="text" id="downloadFilename" class="form-control" value="map_export" placeholder="Enter filename">
                </div>

                <div class="form-group">
                    <label for="downloadFormat">Image Format:</label>
                    <select id="downloadFormat" class="form-control">
                        <option value="png">PNG</option>
                        <option value="jpeg">JPEG</option>
%{--                        <option value="webp">WebP</option>--}%
                    </select>
                </div>

                <hr>

                <div class="list-group">
                    <a id="downloadMapImage" href="#" class="list-group-item list-group-item-info">
                        <i  class="fa fa-download"></i> Download map image
                    </a>

                        <a id="downloadCitationsAndReadme" href="#" class="list-group-item list-group-item-info">
                        <i class="fa fa-download"></i> Download citations and README
                        </a>

                </div>


            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<!-- Add a hidden div for the export map -->
<div id="leafletMapExport" style="position: absolute; top: -9999px; left: -9999px; width: 800px; height: 600px; z-index: -1000;"></div>

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

        document.querySelectorAll('a[href="#downloadMap"]').forEach(link => {
           link.href = '#nbnDownloadMap';
        });

        $('#downloadCitationsAndReadme').on('click', function (e) {
            e.preventDefault();

            var icon = $(this).find('i');
            var filename = $('#downloadFilename').val().trim()+'.citations_and_readme' || 'map_export.citations_and_readme';
            var url = MAP_VAR.mappingUrl + "/mapping/wms/image/downloadCitations" + MAP_VAR.query + MAP_VAR.additionalFqs+ '&filename=' + encodeURIComponent(filename);

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

            // Get filename and format from inputs
            var filename = $('#downloadFilename').val().trim() || 'map_export';
            var format = $('#downloadFormat').val();

            // Disable all links and inputs in the download modal and show loading indicator
            $('#nbnDownloadMap a, #nbnDownloadMap input, #nbnDownloadMap select').addClass('disabled').prop('disabled', true).css('pointer-events', 'none').css('opacity', '0.6');
            var icon = $(this).find('i');
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
                        var exportDataLayer = L.tileLayer.wms(layer._url, layer.options);
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



