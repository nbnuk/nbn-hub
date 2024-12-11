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
