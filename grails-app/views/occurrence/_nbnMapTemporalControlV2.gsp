<script type="application/javascript">
    BC_CONF.groupedFacetsMap= ${(groupedFacetsMap as grails.converters.JSON).toString().encodeAsRaw()}
</script>

<!-- One-line responsive Temporal Toolbar -->
<div id="nbnTemporalToolbar" class="well well-sm" style="margin-bottom:0px; padding-bottom:0px;" aria-label="Timeline Control" data-temporal-control="main">
    <div id="year-tab">
    <div class="nbn-inline" >

        <!-- Tabs -->
        <ul class="nav nav-pills nbn-nowrap" role="tablist" style="margin:0;">
            <li role="presentation" class="active">
                <a href="#year-tab-inline" data-toggle="tab">Year</a>
            </li>
            <li role="presentation">
                <a href="#month-tab-inline" data-toggle="tab">Month</a>
            </li>
        </ul>


        <!-- Min -->
        <small class="text-muted nbn-nowrap" data-display="min" style="margin-right:8px;">1600</small>

        <!-- Slider -->
        <div class="nbn-grow" style="margin:0 6px;">
            <div data-slider="range" data-scope="year" class="nbn-slider"></div>
        </div>

        <!-- Max -->
        <small class="text-muted nbn-nowrap" data-display="max" style="margin-left:8px;">2024</small>

        <!-- Settings -->
        <form class="form-inline nbn-nowrap" role="form" style="margin-left:8px;">
            <div class="form-group form-group-sm">
                <label class="control-label" for="nbn-year-step" style="margin-right:4px;">Step</label>
                <input id="nbn-year-step" type="number" class="form-control input-sm" min="1" max="100" value="1" data-setting="step" style="width:64px;">
            </div>
            <div class="form-group form-group-sm" style="margin-left:6px;">
                <label class="control-label" for="nbn-year-speed" style="margin-right:4px;">Interval</label>
                <input id="nbn-year-speed" type="number" class="form-control input-sm" min="0.1" max="10" step="0.1" value="1" data-setting="speed" style="width:64px;">
                <span class="text-muted">sec</span>
            </div>
        </form>
    </div>
        <div class="nbn-inline" style="display:flex; justify-content: center; margin-top:15px; margin-bottom:15px;">

        <!-- Controls -->
        <div class="btn-group btn-group-justified" role="group" aria-label="Playback controls" style="margin-left:8px; width: 250px">
        <div class="btn-group" role="group"><button type="button" class="btn btn-default btn-sm" data-control="rewind"  title="Rewind"><i class="fa fa-fast-backward"></i></button></div>
                <div class="btn-group" role="group"><button type="button" class="btn btn-default btn-sm" data-control="backward" title="Back"><i class="fa fa-step-backward"></i></button></div>
                    <div class="btn-group" role="group"><button type="button" class="btn btn-success btn-sm" data-control="play"     title="Play"><i class="fa fa-play"></i></button></div>
                        <div class="btn-group" role="group"><button type="button" class="btn btn-warning btn-sm" data-control="pause"   title="Pause"><i class="fa fa-pause"></i></button></div>
                            <div class="btn-group" role="group"><button type="button" class="btn btn-default btn-sm" data-control="forward" title="Forward"><i class="fa fa-step-forward"></i></button></div>
        </div>



        <!-- Current range -->
        <p class="nbn-nowrap" style="margin:0 0 0 8px;"><strong data-display="range">1600 – 2024</strong></p>

    </div>

    <!-- Month tab content (hidden but reuses the same row/slots) -->
    <div class="tab-content" style="display:none;">
        <div role="tabpanel" class="tab-pane active" id="year-tab-inline"></div>
        <div role="tabpanel" class="tab-pane" id="month-tab-inline">
            <!-- When switching to Month, your JS can swap slider to data-scope="month"
           and update min/max/range labels to Jan/Dec as you already do. -->
        </div>
    </div>
    </div>
    <div class="progress-container" style="display:flex; align-items:center;">
        <div class="progress" style="flex:1; margin:0;">
            <div data-temporal-progress="current" class="progress-bar" role="progressbar"
                 aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
                <span data-temporal-control="current">-</span>
            </div>
        </div>

    </div>
</div>

<style>
/* Tiny helpers (Bootstrap 3 + a dash of flex) */
.nbn-stick { position: sticky; top:0; z-index:1030; }
.nbn-inline { display:flex; align-items:center; flex-wrap:wrap; }
.nbn-grow { flex:1 1 240px; min-width:160px; } /* slider gets the flexible space */
.nbn-nowrap { white-space:nowrap; }
.nbn-slider { width:100%; } /* your slider lib will style the track/handle */
</style>

<script>
    // Optional: tooltips
    $(function(){ $('[title]').tooltip({container:'body'}); });

    // Example: swap slider scope when changing tabs (keep your own logic if you have it)
    $('.nav-pills [data-toggle="tab"]').on('shown.bs.tab', function (e) {
        var isMonth = $(e.target).attr('href') === '#month-tab-inline';
        var $toolbar = $('#nbnTemporalToolbar');
        var $slider  = $toolbar.find('[data-slider="range"]');
        $slider.attr('data-scope', isMonth ? 'month' : 'year');
        $toolbar.find('[data-display="min"]').text(isMonth ? 'January' : '1600');
        $toolbar.find('[data-display="max"]').text(isMonth ? 'December' : '2024');
        $toolbar.find('[data-display="range"]').text(isMonth ? 'January – December' : '1600 – 2024');
    });
</script>

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

</style>