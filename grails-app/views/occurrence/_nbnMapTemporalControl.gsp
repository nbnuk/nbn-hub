<script type="application/javascript">
    BC_CONF.groupedFacetsMap= ${(groupedFacetsMap as grails.converters.JSON).toString().encodeAsRaw()}
</script>

<div id="nbnTemporalControlModal" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">
                    <g:message code="map.temporalcontrol.title" default="Explore changes over time"/>
                </h4>
            </div>
            <div class="modal-body" data-temporal-control="main">
                <ul class="nav nav-pills nav-justified" style="margin-bottom: 30px;">
                    <li role="presentation" class="active"><a href="#year-tab" data-toggle="tab">Year</a></li>
                    <li role="presentation"><a href="#month-tab" data-toggle="tab">Month</a></li>
                </ul>
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="year-tab">
<g:if test="${sr.activeFacetObj.year}">
    <div class="alert alert-warning" role="alert">
        Remove the year filter to explore changes over years.
    </div>
</g:if>
<div <g:if test="${sr.activeFacetObj.year}">style="display:none"</g:if>>
                <!-- Year Range Slider -->
                <div class="form-group">
                    <div><input data-slider="range" type="text" style="margin: 10px 0;"/></div>
                </div>

                <!-- Playback Controls -->
                <div class="form-group">

                    <div class="btn-group btn-group-justified" role="group">
                        <div class="btn-group" role="group">
                           <button type="button" class="btn btn-default" data-control="rewind"  title="Rewind to start">
                                <i class="fa fa-fast-backward"></i>
                            </button>
                        </div>
                        <div class="btn-group" role="group">
                           <button type="button" class="btn btn-default" data-control="backward"  title="Backward one step">
                                <i class="fa fa-step-backward"></i>
                            </button>
                        </div>
                        <div class="btn-group" role="group">
                           <button type="button" class="btn btn-success" data-control="play" title="Play">
                                <i class="fa fa-play"></i>
                            </button>
                        </div>
                        <div class="btn-group" role="group">
                           <button type="button" class="btn btn-warning" data-control="pause" title="Pause">
                                <i class="fa fa-pause"></i>
                            </button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default" data-control="forward"  title="Forward one step">
                                <i class="fa fa-step-forward"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Settings Row -->
                <div class="row">
                    <div class="col-xs-6">
                        <div class="form-group">
                            <label class="control-label">Year Step</label>
                            <input type="number" class="form-control input-sm" min="1" max="100" value="1" data-setting="step">
                        </div>
                    </div>
                    <div class="col-xs-6">
                        <div class="form-group">
                            <label class="control-label">Speed (sec)</label>
                            <input type="number" class="form-control input-sm" min="0.1" max="10" step="0.1" value="1" data-setting="speed">
                        </div>
                    </div>
                </div>

</div>
                    </div>
                <div role="tabpanel" class="tab-pane" id="month-tab">
                <g:if test="${sr.activeFacetObj.month}">
                    <div class="alert alert-warning" role="alert">
                        Remove the month filter to explore changes over month.
                    </div>
                </g:if>
                    <div <g:if test="${sr.activeFacetObj.month}">style="display:none"</g:if>>
                    <!-- Month Range Slider -->
                    <div class="form-group">
                        <div><input data-slider="range" type="text" style="margin: 10px 0;"/></div>
                    </div>

                    <!-- Playback Controls -->
                    <div class="form-group">

                        <div class="btn-group btn-group-justified" role="group">
                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-default" data-control="rewind"  title="Rewind to start">
                                    <i class="fa fa-fast-backward"></i>
                                </button>
                            </div>
                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-default" data-control="backward"  title="Backward one step">
                                    <i class="fa fa-step-backward"></i>
                                </button>
                            </div>
                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-success" data-control="play" title="Play">
                                    <i class="fa fa-play"></i>
                                </button>
                            </div>
                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-warning" data-control="pause" title="Pause">
                                    <i class="fa fa-pause"></i>
                                </button>
                            </div>
                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-default" data-control="forward"  title="Forward one step">
                                    <i class="fa fa-step-forward"></i>
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Settings Row -->
                    <div class="row">
                        <div class="col-xs-6">
                            <div class="form-group">
                                <label class="control-label">Month Step</label>
                                <input type="number" class="form-control input-sm" min="1" max="12" value="1" data-setting="step">
                            </div>
                        </div>
                        <div class="col-xs-6">
                            <div class="form-group">
                                <label class="control-label">Speed (sec)</label>
                                <input type="number" class="form-control input-sm" min="0.1" max="10" step="0.1" value="1" data-setting="speed">
                            </div>
                        </div>
                    </div>
                    </div>
                </div>
            </div>
            </div>
        </div>
    </div>
</div>


<asset:javascript src="nbn/draggable-modal.js" />
<asset:stylesheet src="nbn/ion.rangeSlider.min.css" />
<asset:javascript src="nbn/ion.rangeSlider.min.js" />


<asset:script type="text/javascript">
    class TemporalControl {
        constructor(selector, mode) {
            this.container = $(selector);


            this.mode = mode;

            this.monthNames = [
                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Novr', 'Dec'
            ];

            this.init();

        }
        init(){
            this.isPlaying = false;
            this.setupSlider();
            this.bindEvents();
            // this.currentValue = this.sliderApi.result.from;
            this.step = 1;
            this.speed = 1000;
            this._refreshState()
        }

        getControl(type) {
            return this.container.find('[data-control="' + type + '"]');
        }

        getSetting(type) {
            return this.container.find('[data-setting="' + type + '"]');
        }

        getDisplay(type) {
            return this.container.find('[data-display="' + type + '"]');
        }

        displayCurrentValue(value) {
            $('#temporal-progress').show();
            if (this.mode === 'month') {
                var monthName = this.monthNames[value];
                $('[data-temporal-control="current"]').text(monthName);
            } else {
                $('[data-temporal-control="current"]').text(value);
            }
            const totalSteps = ((this.sliderApi.result.to - this.sliderApi.result.from) / this.step) + 1;
            const stepsDone = ((value - this.sliderApi.result.from) / this.step) + 1;
            $('[data-temporal-progress="current"].progress-bar').css('width', (stepsDone / totalSteps) * 100+"%");
        }

        getSlider() {
            return this.container.find('[data-slider="range"]');
        }



        setupSlider() {
            if (this.mode === 'month') {
                this.setupMonthSlider();
            } else {
                this.setupYearSlider();
            }
        }

        setupMonthSlider() {
            var self = this;

             this.sliderApi = this.getSlider().ionRangeSlider({
                  type: 'double',
                  skin: 'round',
                  values: this.monthNames,
                  min: 'Jan',
                  max: 'Dec',
                  from: 'Jan',
                  to: 'Dec',
                  step: 1,
                  onChange: (data) => {
                    this.currentValue = undefined;
                  }

                }).data('ionRangeSlider');


        }

        setupYearSlider() {
            var currentYear = new Date().getFullYear();
            var minAndMaxYears = this._getMinMaxYears();
            var self = this;

            this.sliderApi = this.getSlider().ionRangeSlider({
              type: 'double',
              skin: 'round',
              min:  minAndMaxYears.min,
              max:  minAndMaxYears.max,
              from: minAndMaxYears.min,
              to:   minAndMaxYears.max,
              step: 1,
              prettify_enabled: false,
              onChange: (data) => {
                this.currentValue = undefined;
              }
            }).data('ionRangeSlider');

        }

        bindEvents() {
            var self = this;
            this.getControl('play').click(function() { return self.play(); });
            this.getControl('pause').click(function() { return self.pause(); });
            this.getControl('rewind').click(function() { return self.rewind(); });
            this.getControl('forward').click(function() { return self.forward(); });
            this.getControl('backward').click(function() { return self.backward(); });
        }

        play() {
            if (this.isPlaying) {
                return;
            }

            this.step = parseInt(this.getSetting('step').val());
            this.speed = parseFloat(this.getSetting('speed').val()) * 1000;
            this._debug("play "+this.sliderApi.result.from+" "+this.sliderApi.result.to);
            if (this.currentValue == undefined || this.currentValue ==  this.sliderApi.result.to){
                this.currentValue = this.sliderApi.result.from;
            }

            this.isPlaying = true;
            this._refreshState();
            $('#resetMap').show();

            this._loadMap();

        }

        forward(){
            this._debug("forward currentValue:"+this.currentValue);
            if (this.isPlaying || this.currentValue >= this.sliderApi.result.to) {
                return true;
            }
            $('#resetMap').show();
            this.step = parseInt(this.getSetting('step').val());
            this.speed = parseFloat(this.getSetting('speed').val()) * 1000;

            this._next();
            return true;
        }



        backward(){

            if (this.isPlaying || this.currentValue <= this.sliderApi.result.from) {
                return true;
            }

            this.step = parseInt(this.getSetting('step').val());
            this.speed = parseFloat(this.getSetting('speed').val()) * 1000;


            this._back();
            return true;
        }

        pause() {
            this.isPlaying = false;
            this._refreshState();
        }

         rewind() {

            this.currentValue = this.sliderApi.result.from;
            this._refreshState()

            this.displayCurrentValue(this.currentValue);
            this.displayMapForValue(this.currentValue);
        }

        _refreshState() {
            this._debug("_refreshState");

            const maxValue = this.sliderApi.result.to;
            const minValue = this.sliderApi.result.from;


            if (this.isPlaying) this.getControl("play").parent().hide(); else this.getControl("play").parent().show();
            if (this.isPlaying)  this.getControl("pause").parent().show(); else this.getControl("pause").parent().hide();

            this.getControl('backward').prop('disabled', this.currentValue == undefined || this.currentValue <= minValue?true:false);

            this.getControl('rewind').prop('disabled', this.currentValue == undefined || this.currentValue <= minValue?true:false);
            this.getControl('forward').prop('disabled', this.currentValue >= maxValue?true:false);
            if (this.isPlaying)
                this.sliderApi.update({ disable: true });
            else
                this.sliderApi.update({ disable: false });

        }



        _playNext(){

            if (!this.isPlaying) {
                return;
            }
           this._next();
        }

        _next(){

            const maxValue = this.sliderApi.result.to;
            if (this.currentValue && this.currentValue >= maxValue){
                return;
            }

            if (this.currentValue == undefined){
                this.currentValue = this.sliderApi.result.from;
            }
            else{
                this.currentValue += this.step;
            }

            if (this.currentValue >= maxValue) {
                this.currentValue = maxValue;
            }
            if (this.currentValue >= maxValue){
                this.isPlaying = false;

            }

            this._refreshState();
            this._loadMap();
        }

        _back(){
            const minValue = this.sliderApi.result.from;
            if (this.currentValue <= minValue){
                return;
            }

            this.currentValue -= this.step;

            if (this.currentValue < minValue) {
                this.currentValue = minValue;
            }


            this._refreshState();
            this._loadMap();
        }



        _loadMap(){
            this.displayCurrentValue(this.currentValue);
            this.displayMapForValue(this.currentValue);
        }



        displayMapForValue(value) {
            if (this.mode === 'month') {
                this._debug("show month " + value + " (" + this.monthNames[value] + ")");
                MAP_VAR.additionalFqs = '&fq=month:' + value;
                MAP_VAR.removeFqs = ''
                addQueryLayer(true);
            } else {
                MAP_VAR.additionalFqs = '&fq=year:' + value;
                MAP_VAR.removeFqs = ''
                addQueryLayer(true);
            }

            const layer = MAP_VAR.currentLayers[MAP_VAR.currentLayers.length-1];
            var self = this;
            layer.on('load', function () {
                setTimeout(function() {
                    self._playNext();
                }, self.speed);
            });
        }

        _getMinMaxYears(){
            var minYear = 1600;
            var maxYear = new Date().getFullYear();

            if (BC_CONF.groupedFacetsMap && BC_CONF.groupedFacetsMap.year) {
                var yearFacet = BC_CONF.groupedFacetsMap.year;
                var years = [];


                if (yearFacet.fieldResult && yearFacet.fieldResult.length > 0) {
                    years = yearFacet.fieldResult.map(function(item) {
                        return parseInt(item.label, 10);
                    }).filter(function(year) {
                        return !isNaN(year);
                    });
                }



                if (years.length > 0) {
                    var dataMinYear = Math.min.apply(Math, years);
                    var dataMaxYear = Math.max.apply(Math, years);

                    minYear = dataMinYear;
                    maxYear = dataMaxYear;
                }

            }
            this._debug('Min year:'+minYear+' ,axYear:'+maxYear);
            return {
                min:minYear,
                max:maxYear
            }

        }

        _debug(msg) {
            if (true) {
                if (msg != undefined){
                    console.log(msg);
                }
                else {
                    console.log(this);
                }
            }
        }


    }

    // Leaflet Control
    const LaunchTemporalLeafletControl = L.Control.extend({
        options: { position: 'topright' },
        onAdd: function(map) {
            const container = L.DomUtil.create('div', 'leaflet-control-layers');
            container.id = 'launchTemporalLeafletControl';
            container.innerHTML = '<a data-toggle="modal" href="#nbnTemporalControlModal" class="launchTemporalLeafletControl tooltips" title="Explore changes over time"><i class="fa fa-clock-o fa-lg"></i></a>';
            L.DomEvent.disableClickPropagation(container);
            return container;
        }
    });

    // Initialize
    $(document).ready(function() {

        window.nbnYearTemporalControl = new TemporalControl('#year-tab','year');
        window.nbnMonthTemporalControl = new TemporalControl('#month-tab','month');
        // MAP_VAR.map.addControl(new LaunchTemporalLeafletControl());
        // $('a.launchTemporalLeafletControl').tooltip({ container: 'body', placement: 'left' });
        makeModalDraggable('#nbnTemporalControlModal');

       const progressBarHtml = `

    <div id="temporal-progress" class="progress-container" style="display:flex; align-items:center; margin-bottom:0;">
        <div class="progress" style="flex:1; margin:0;">
            <div data-temporal-progress="current" class="progress-bar" role="progressbar"
                 aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
                <span data-temporal-control="current">-</span>
            </div>
        </div>
        <div style="margin-left:10px; white-space:nowrap; display:none" id="resetMap">
            <a href="#" ><i class="fa fa-refresh" aria-hidden="true"></i> reset map</a>
        </div>
    </div>
    `;

    $('#leafletMap').before(progressBarHtml);

    function resetMap() {
            $('[data-temporal-progress="current"].progress-bar').css('width', "0%");
                MAP_VAR.additionalFqs = '';
                MAP_VAR.removeFqs = ''
                addQueryLayer(true);
                $('#resetMap').hide();
        }

    $('#resetMap a').click(function() {
            resetMap();
            return false;
            });

    $('#nbnTemporalControlModal').on('hidden.bs.modal', function () {
        // Your code here, runs after the modal fully closes
        window.nbnYearTemporalControl.pause();
        window.nbnMonthTemporalControl.pause();
    });


    function addTemporalControlToMap() {
       // console.log("boom");
      MAP_VAR.map.addControl(new LaunchTemporalLeafletControl());
      $('a.launchTemporalLeafletControl').tooltip({ container: 'body', placement: 'left' });
      MAP_VAR.nbnTemporalControl = true;
    }

    // helper: wait until MAP_VAR.map exists, then run callback
    function waitForMap(callback) {
      var check = setInterval(function () {console.log("waiting for map...");
        if (MAP_VAR && MAP_VAR.map) {
          clearInterval(check);
          callback();
        }
      }, 100);
    }

    // 1. If map already exists, add immediately
    if (MAP_VAR && MAP_VAR.map && !MAP_VAR.nbnTemporalControl) {
      addTemporalControlToMap();
    }
    // 2. Else if user is already on Map tab, wait for map
    else if ($('.nav-tabs li.active a').attr('id') === "t2") {
      waitForMap(function () {
        if (!MAP_VAR.nbnTemporalControl) addTemporalControlToMap();
      });
    }
    // 3. Else listen to tab change event for Map tab
    else {
      $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        if ($(this).attr('id') === "t2") {
          waitForMap(function () {
            if (!MAP_VAR.nbnTemporalControl) addTemporalControlToMap();
          });
        }
      });
    }



   });
</asset:script>

<style>

#nbnTemporalControlModal .tab-content {border:none !important; padding: 0px !important; margin: 0px !important;}

#launchTemporalLeafletControl{
    padding: 6px 10px;
    background-color: #fff;
}
#main-content .leaflet-container a.launchTemporalLeafletControl, #main-content .leaflet-container a.launchTemporalLeafletControl:visited, #main-content .leaflet-container a.launchTemporalLeafletControl:hover {
    color: #000;
    text-decoration: none;
}

.irs--round .irs-handle{
    border-color: #3e8f3e;
}
.irs--round .irs-from, .irs--round .irs-to, .irs--round .irs-single, .irs--round .irs-bar {
    background-color: #3e8f3e; /* green: #3e8f3e*/ /* body text color: #595d5f */
}


</style>