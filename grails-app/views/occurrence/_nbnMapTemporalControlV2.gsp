<script type="application/javascript">
    BC_CONF.groupedFacetsMap= ${(groupedFacetsMap as grails.converters.JSON).toString().encodeAsRaw()}
</script>

<div id="nbnTemporalToolbar" class="well well-sm" aria-label="Timeline Control" style="margin-bottom: 0px; padding-bottom: 0px;" data-temporal-control="main">
    <!-- Tabs -->
    <ul class="nav nav-pills" role="tablist">
        <li role="presentation" class="active">
            <a href="#year-tab" data-toggle="tab" style="padding:2px 10px 2px 10px;">Year</a>
        </li>
        <li role="presentation">
            <a href="#month-tab" data-toggle="tab" style="padding:2px 10px 2px 10px;">Month</a>
        </li>
    </ul>
    <div class="tab-content" style="border: none !important; padding-bottom:0px">
        <div id="year-tab" role="tabpanel" class="tab-pane active" >
            <div class="row">
                <!-- Slider + labels -->
                <div class="col-sm-12 col-md-6"  style="margin-bottom: 10px; ">
                    <div data-slider="range"></div>
                    <div class="row">
                        <div class="col-xs-6">
                            <small class="text-muted" data-display="min">1600</small>
                        </div>
                        <div class="col-xs-6 text-right">
                            <small class="text-muted" data-display="max">2024</small>
                        </div>
                    </div>
                    <div class="text-center">
                        <strong data-display="range">1600 - 2024</strong>
                    </div>
                </div>


                <div class="col-sm-12 col-md-3" style="margin-bottom: 10px; ">
                    <div class="row">
                        <div class="col-xs-6">
                            <div class="input-group input-group-sm">
                                <span class="input-group-addon">Step</span>
                                <input id="nbn-year-step" type="number" class="form-control"
                                       min="1" max="100" value="1" data-setting="step">
                            </div>
                        </div>
                        <div class="col-xs-6">
                            <div class="input-group input-group-sm">
                                <span class="input-group-addon">Interval (s)</span>
                                <input id="nbn-year-speed" type="number" class="form-control"
                                       min="0.5" max="10" step="0.1" value="1" data-setting="speed">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Playback buttons -->
                <div class="col-sm-12 col-md-3"  style="margin-bottom: 10px; ">
                    <div class="btn-group btn-group-justified" role="group" aria-label="Playback controls" style="white-space: nowrap;">
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default btn-sm" data-control="rewind" title="Rewind"><i class="fa fa-fast-backward"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default btn-sm" data-control="backward" title="Back"><i class="fa fa-step-backward"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-success btn-sm" data-control="play" title="Play"><i class="fa fa-play"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-warning btn-sm" data-control="pause" title="Pause"><i class="fa fa-pause"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default btn-sm" data-control="forward" title="Forward"><i class="fa fa-step-forward"></i></button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div id="month-tab" role="tabpanel" class="tab-pane" >
            <div class="row">
                <!-- Slider + labels -->
                <div class="col-sm-12 col-md-6"  style="margin-bottom: 10px; ">
                    <div data-slider="range"></div>
                    <div class="row">
                        <div class="col-xs-6">
                            <small class="text-muted" data-display="min">January</small>
                        </div>
                        <div class="col-xs-6 text-right">
                            <small class="text-muted" data-display="max">December</small>
                        </div>
                    </div>
                    <div class="text-center">
                        <strong data-display="range">January - December</strong>
                    </div>
                </div>


                <div class="col-sm-12 col-md-3" style="margin-bottom: 10px; ">
                    <div class="row">
                        <div class="col-xs-6">
                            <div class="input-group input-group-sm">
                                <span class="input-group-addon">Step</span>
                                <input id="nbn-year-step" type="number" class="form-control"
                                       min="1" max="12" value="1" data-setting="step">
                            </div>
                        </div>
                        <div class="col-xs-6">
                            <div class="input-group input-group-sm">
                                <span class="input-group-addon">Interval (s)</span>
                                <input id="nbn-year-speed" type="number" class="form-control"
                                       min="0.5" max="10" step="0.1" value="1" data-setting="speed">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Playback buttons -->
                <div class="col-sm-12 col-md-3"  style="margin-bottom: 10px; ">
                    <div class="btn-group btn-group-justified" role="group" aria-label="Playback controls" style="white-space: nowrap;">
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default btn-sm" data-control="rewind" title="Rewind"><i class="fa fa-fast-backward"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default btn-sm" data-control="backward" title="Back"><i class="fa fa-step-backward"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-success btn-sm" data-control="play" title="Play"><i class="fa fa-play"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-warning btn-sm" data-control="pause" title="Pause"><i class="fa fa-pause"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default btn-sm" data-control="forward" title="Forward"><i class="fa fa-step-forward"></i></button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- Progress bar -->
    <div class="progress" style="margin-bottom:0px">
        <div data-temporal-progress="current" class="progress-bar" role="progressbar"
             aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
            <span data-temporal-control="current">-</span>
        </div>
    </div>
</div>



<asset:javascript src="nbn/draggable-modal.js" />
<asset:javascript src="nbn/jquery-ui.min.js" />
<asset:stylesheet src="nbn/jquery-ui.min.css" />

<asset:script type="text/javascript">
    class TemporalControl {
        constructor(selector, mode) {
            this.container = $(selector);

            this.isPlaying = false;
            this.mode = mode;
            this.monthNames = [
                'January', 'February', 'March', 'April', 'May', 'June',
                'July', 'August', 'September', 'October', 'November', 'December'
            ];

            this.setupSlider();
            this.bindEvents();
            this.currentValue = this.getSlider().slider("values", 0);
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
            if (this.mode === 'month') {
                var monthName = this.monthNames[value - 1];
                $('[data-temporal-control="current"]').text(monthName);
            } else {
                $('[data-temporal-control="current"]').text(value);
            }
            const totalSteps = ((this.getSlider().slider("values", 1) - this.getSlider().slider("values", 0)) / this.step) + 1;
            const stepsDone = ((value - this.getSlider().slider("values", 0)) / this.step) + 1;
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

            this.getSlider().slider({
                range: true,
                min: 1,
                max: 12,
                values: [1, 12],
                slide: function(event, ui) {
                    if (ui && ui.values) {
                        var startMonth = self.monthNames[ui.values[0] - 1];
                        var endMonth = self.monthNames[ui.values[1] - 1];
                        self.getDisplay('range').text(startMonth + ' - ' + endMonth);
                        self.currentValue=ui.values[0];
                    }
                }
            });

            this.getDisplay('min').text('January');
            this.getDisplay('max').text('December');
            this.getDisplay('range').text('January - December');
        }

        setupYearSlider() {
            var currentYear = new Date().getFullYear();
            var minAndMaxYears = this._getMinMaxYears();
            var self = this;

            this.getSlider().slider({
                range: true,
                min: minAndMaxYears.min,
                max: minAndMaxYears.max,
                values: [minAndMaxYears.min, minAndMaxYears.max],
                slide: function(event, ui) {
                    if (ui && ui.values) {
                        self.getDisplay('range').text(ui.values[0] + ' - ' + ui.values[1]);
                        self.currentValue=ui.values[0];
                    }
                }
            });

            this.getDisplay('min').text(minAndMaxYears.min);
            this.getDisplay('max').text(minAndMaxYears.max);
            this.getDisplay('range').text(minAndMaxYears.min +' - ' + minAndMaxYears.max);
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
            if (this.currentValue ==  this.getSlider().slider("values", 1)){
                this.currentValue = this.getSlider().slider("values", 0);
            }

            this.isPlaying = true;
            this._refreshState();
            $('#resetMap').show();

            this._loadMap();

        }

        forward(){
            this._debug("forward currentValue:"+this.currentValue);
            if (this.isPlaying || this.currentValue >= this.getSlider().slider("values", 1)) {
                return true;
            }
            $('#resetMap').show();
            this.step = parseInt(this.getSetting('step').val());
            this.speed = parseFloat(this.getSetting('speed').val()) * 1000;

            this._next();
            return true;
        }



        backward(){

            if (this.isPlaying || this.currentValue <= this.getSlider().slider("values", 0)) {
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

            this.currentValue = this.getSlider().slider("values", 0);
            this._refreshState()

            this.displayCurrentValue(this.currentValue);
            this.displayMapForValue(this.currentValue);
        }

        _refreshState() {
            this._debug("_refreshState");
            this._debug()
            const maxValue = this.getSlider().slider("values", 1);
            const minValue = this.getSlider().slider("values", 0);


            if (this.isPlaying) this.getControl("play").parent().hide(); else this.getControl("play").parent().show();
            if (this.isPlaying)  this.getControl("pause").parent().show(); else this.getControl("pause").parent().hide();

            this.getControl('backward').prop('disabled', this.currentValue <= minValue?true:false);

            this.getControl('rewind').prop('disabled', this.currentValue <= minValue?true:false);
            this.getControl('forward').prop('disabled', this.currentValue >= maxValue?true:false);
            if (this.isPlaying)
                this.getSlider().slider( "option", "disabled", true );
            else
                this.getSlider().slider( "option", "disabled", false );

        }



        _playNext(){

            if (!this.isPlaying) {
                return;
            }
           this._next();
        }

        _next(){
            const maxValue = this.getSlider().slider("values", 1);
            if (this.currentValue >= maxValue){
                return;
            }

            this.currentValue += this.step;

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
            const minValue = this.getSlider().slider("values", 0);
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
                this._debug("show month " + value + " (" + this.monthNames[value - 1] + ")");
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
                console.log(msg);
            }
        }
        _debug() {
            if (true) {
                console.log(this);
            }
        }
    }

    // Leaflet Control
    const LaunchTemporalLeafletControl = L.Control.extend({
        options: { position: 'topright' },
        onAdd: function(map) {
            const container = L.DomUtil.create('div', 'leaflet-control-layers');
            container.id = 'launchTemporalLeafletControl';
            container.innerHTML = '<a data-toggle="modal" href="#nbnTemporalControlModal" class="launchTemporalLeafletControl"><i class="fa fa-clock-o fa-lg"></i></a>';
            L.DomEvent.disableClickPropagation(container);
            return container;
        }
    });

    // Initialize
    $(document).ready(function() {

        new TemporalControl('#year-tab','year');
        new TemporalControl('#month-tab','month');
        MAP_VAR.map.addControl(new LaunchTemporalLeafletControl());
        makeModalDraggable('#nbnTemporalControlModal');

       const progressBarHtml = `

    <div class="progress-container" style="display:flex; align-items:center; margin-bottom:0;">
        <div class="progress" style="flex:1; margin:0;">
            <div data-temporal-progress="current" class="progress-bar" role="progressbar"
                 aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
                <span data-temporal-control="current">-</span>
            </div>
        </div>
        <div style="margin-left:10px; white-space:nowrap; display:none;" id="resetMap">
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
                $('#refreshMap').hide();
        }

    $('#resetMap a').click(function() {
            resetMap();
            $('#resetMap').hide();
            });

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
/*#nbnTemporalControlModal .nav>li>a{*/
/*    padding:2px 10px 2px 10px;*/
/*}*/

</style>