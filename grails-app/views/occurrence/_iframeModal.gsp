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
                <textarea id="embedIframeTextarea" class="form-control" rows="6"
                          style="font-family:monospace;"></textarea>

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
                    <i class="fa fa-clipboard"></i> Copy
                </button>
            </div>
        </div>
    </div>
</div>
