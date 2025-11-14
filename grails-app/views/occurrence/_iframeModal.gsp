<script>

    $('#embedModal').on('show.bs.modal', function (event) {
        const button = $(event.relatedTarget);
        const iframeCode = button.data('iframe-code');
        $(this).find('.iframe-output').val(iframeCode);
    });

</script>

<div id="embedModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="embedModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>

                <h3 id="embedModalLabel">Embed this map</h3>
            </div>

            <div class="modal-body">
                <p>Copy and paste this iframe into your website:</p>
                <label for="embedIframeTextarea"></label>
                <textarea id="embedIframeTextarea" class="form-control iframe-output" rows="6"
                          style="font-family:monospace;"></textarea>

                <!-- Optional domain override -->
                <div class="form-group" style="margin-top:10px;">
                    <label for="embedDomainOverride">Embed domain (optional)</label>
                    <input id="embedDomainOverride"
                           type="text"
                           class="form-control"
                           placeholder="e.g. https://localhost:8080 or https://my.test.domain">
                    <p class="help-block">
                        Leave blank to use the current map domain.
                    </p>
                </div>

                <!-- Optional bounding box override -->
                <div class="form-group">
                    <label>Override map bounding box (optional)</label>

                    <div class="row" style="margin-bottom:5px;">
                        <div class="col-xs-6" style="margin-bottom:5px;">
                            <input id="embedBboxWest"
                                   type="text"
                                   class="form-control"
                                   placeholder="West (min lon)">
                        </div>
                        <div class="col-xs-6" style="margin-bottom:5px;">
                            <input id="embedBboxEast"
                                   type="text"
                                   class="form-control"
                                   placeholder="East (max lon)">
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-xs-6" style="margin-bottom:5px;">
                            <input id="embedBboxSouth"
                                   type="text"
                                   class="form-control"
                                   placeholder="South (min lat)">
                        </div>
                        <div class="col-xs-6" style="margin-bottom:5px;">
                            <input id="embedBboxNorth"
                                   type="text"
                                   class="form-control"
                                   placeholder="North (max lat)">
                        </div>
                    </div>

                    <p class="help-block">
                        Leave all four empty to use the current map view.
                    </p>
                </div>

                <div class="checkbox" style="margin-top:10px;">
                    <label>
                        <input id="embedAutoUpdate" type="checkbox" checked>
                        Update to reflect current map styling (size, opacity, outline) when opened
                    </label>
                </div>

                <small class="text-muted">
                    Tip: you can adjust width/height before copying. The map tiles use your current “Occurrences” layer.
                </small>
            </div>


            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                <button id="copyEmbedIframe" type="button" class="btn btn-primary">
                    <i class="glyphicon glyphicon-copy" aria-hidden="true"></i> Copy
                </button>
            </div>
        </div>
    </div>
</div>
