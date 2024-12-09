<div id="wmsModal" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                <h3><g:message code="map.wms.title" default="Current WMS Layer Details"/></h3>
            </div>
            <div class="modal-body">
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
