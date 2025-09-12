<script type="application/javascript">
    BC_CONF.groupedFacetsMap= ${(groupedFacetsMap as grails.converters.JSON).toString().encodeAsRaw()}
</script>

<div id="nbnTemporalControlModal" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">
                    <i class="fa fa-clock-o"></i>
                    <g:message code="map.temporalcontrol.title" default="Timeline Control"/>
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
<g:else>
                <!-- Year Range Slider -->
                <div class="form-group">
                    <div data-slider="range" style="margin: 10px 0;"></div>
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

                <!-- Playback Controls -->
                <div class="form-group">
                    <label class="control-label">Playback Controls</label>
                    <div class="btn-group btn-group-justified" role="group">
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default" data-control="rewind" disabled title="Rewind to start">
                                <i class="fa fa-fast-backward"></i>
                            </button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-success" data-control="play" title="Play animation">
                                <i class="fa fa-play"></i>
                            </button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-warning" data-control="pause" disabled title="Pause animation">
                                <i class="fa fa-pause"></i>
                            </button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-danger" data-control="stop" disabled title="Stop animation">
                                <i class="fa fa-stop"></i>
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
                            <label class="control-label">Interval (sec)</label>
                            <input type="number" class="form-control input-sm" min="0.1" max="10" step="0.1" value="1" data-setting="speed">
                        </div>
                    </div>
                </div>

    <div class="text-center"><strong>Current year: <span data-temporal-control="current">-</span></strong></div>

</g:else>

                </div>
                <div role="tabpanel" class="tab-pane" id="month-tab">
<g:if test="${sr.activeFacetObj.month}">
    <div class="alert alert-warning" role="alert">
        Remove the month filter to explore changes over month.
    </div>
</g:if>
<g:else>
                    <!-- Month Range Slider -->
                    <div class="form-group">
                        <div data-slider="range" style="margin: 10px 0;"></div>
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

                    <!-- Playback Controls -->
                    <div class="form-group">
                        <label class="control-label">Playback Controls</label>
                        <div class="btn-group btn-group-justified" role="group">
                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-default" data-control="rewind" disabled title="Rewind to start">
                                    <i class="fa fa-fast-backward"></i>
                                </button>
                            </div>
                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-success" data-control="play" title="Play animation">
                                    <i class="fa fa-play"></i>
                                </button>
                            </div>
                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-warning" data-control="pause" disabled title="Pause animation">
                                    <i class="fa fa-pause"></i>
                                </button>
                            </div>
                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-danger" data-control="stop" disabled title="Stop animation">
                                    <i class="fa fa-stop"></i>
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

    <div class="text-center"><strong>Current month: <span data-temporal-control="current">-</span></strong></div>
</g:else>
                </div>
            </div>
            </div>
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
            this.player = null;
            this.currentValue = "";
            this.isPaused = false;
            this.mode = mode;
            this.monthNames = [
                'January', 'February', 'March', 'April', 'May', 'June',
                'July', 'August', 'September', 'October', 'November', 'December'
            ];
            this.init();
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

        init() {
            this.setupSlider();
            this.bindEvents();
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
                    }
                }
            });

            this.getDisplay('min').text(minAndMaxYears.min);
            this.getDisplay('max').text(minAndMaxYears.max);
            this.getDisplay('range').text(minAndMaxYears.min +' - ' + minAndMaxYears.max);
        }

        bindEvents() {
            var self = this;
            this.getControl('play').click(function() { self.play(); });
            this.getControl('pause').click(function() { self.pause(); });
            this.getControl('stop').click(function() { self.stop(); });
            this.getControl('rewind').click(function() { self.rewind(); });
        }

        play() {
            this.step = parseInt(this.getSetting('step').val());
            this.speed = parseFloat(this.getSetting('speed').val()) * 1000;

            if (!this.isPaused) {
                this.currentValue = this.getSlider().slider("values", 0);
            }

            this.isPaused = false;
            this.isPlaying = true;
            this.setButtonStates(true, false, false, false);

            this.loadMap();

        }
        next(){
            if (this.Playing){
                return;
            }
            this.currentValue += this.step;
            this.loadMap();
        }

        loadMap(){
                this.currentValue += this.step;
                console.log("load map for " + this.currentValue);
                if (this.currentValue > this.getSlider().slider("values", 1)) {
                    this.stop();
                    return;
                }

                if (!this.isPlaying) {
                    return;
                }

                this.displayCurrentValue(this.currentValue);
                this.displayMapForValue(this.currentValue);


        }

        pause() {
            // clearInterval(this.player);
            this.isPaused = true;
            this.setButtonStates(false, true, false, false);
            this.isPlaying = false;
        }

        stop() {
            // clearInterval(this.player);
            this.isPaused = false;
            this.isPlaying = false;
            this.setButtonStates(false, true, true, false);
        }

        rewind() {
            this.stop();
            this.setButtonStates(false, true, true, true);
            this.currentValue = this.getSlider().slider("values", 0);

            this.displayCurrentValue(this.currentValue);
            this.displayMapForValue(this.currentValue);
        }

        setButtonStates(play, pause, stop, rewind) {
            this.getControl('play').prop('disabled', play);
            this.getControl('pause').prop('disabled', pause);
            this.getControl('stop').prop('disabled', stop);
            this.getControl('rewind').prop('disabled', rewind);
        }

        displayMapForValue(value) {
            if (this.mode === 'month') {
                console.log("show month " + value + " (" + this.monthNames[value - 1] + ")");
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
                    self.loadMap();
                }, self.speed);
            });
        }

        _getMinMaxYears(){
            var minYear = 1600;
            var maxYear = new Date().getFullYear();

            if (BC_CONF.groupedFacetsMap && BC_CONF.groupedFacetsMap.year) {
                var yearFacet = BC_CONF.groupedFacetsMap.year;
                var years = [];

                // Extract years from the facet results
                if (yearFacet.fieldResult && yearFacet.fieldResult.length > 0) {
                    years = yearFacet.fieldResult.map(function(item) {
                        return parseInt(item.label, 10);
                    }).filter(function(year) {
                        return !isNaN(year); // Filter out any non-numeric values
                    });
                }


                // Find actual min and max years from data if available
                if (years.length > 0) {
                    var dataMinYear = Math.min.apply(Math, years);
                    var dataMaxYear = Math.max.apply(Math, years);

                    // Use data values if they exist, otherwise keep defaults
                    minYear = dataMinYear;
                    maxYear = dataMaxYear;
                }

            }
            console.log('Min year:', minYear);
            console.log('Max year:', maxYear);
            return {
                min:minYear,
                max:maxYear
            }

        }
    }

    // Leaflet Control
const TemporalSearchControl = L.Control.extend({
    options: { position: 'topright' },
    onAdd: function(map) {
        const container = L.DomUtil.create('div', 'leaflet-control-layers');
        container.id = 'temporalControl';
        container.innerHTML = '<a data-toggle="modal" href="#nbnTemporalControlModal" class="temporalControl"><i class="fa fa-clock-o fa-lg"></i></a>';
        L.DomEvent.disableClickPropagation(container);
        return container;
    }
});

    // Initialize
    $(document).ready(function() {
        // console.log(MAP_VAR);
        new TemporalControl('#year-tab','year');
        new TemporalControl('#month-tab','month');
        MAP_VAR.map.addControl(new TemporalSearchControl());
        makeModalDraggable('#nbnTemporalControlModal');

       const progressBarHtml = `
    <div class="progress" style="margin-bottom: 0px">
        <div data-temporal-progress="current" class="progress-bar" role="progressbar"
             aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
            <span data-temporal-control="current">-</span>
        </div>
    </div>
    `;

    $('#leafletMap').before(progressBarHtml);
        });
</asset:script>

<style>
.slider-container {
    position: relative;
    width: 400px;
    margin: 20px 0;
}

#yearRangeSlider {
    width: 100%;
}

.slider-labels {
    display: flex;
    justify-content: space-between;
    margin-top: 5px; /* spacing between slider and labels */
}

#nbnTemporalControlModal .tab-content {border:none !important; padding: 0px !important; margin: 0px !important;}

#temporalControl{
    padding: 6px 10px;
    background-color: #fff;
}
#main-content .leaflet-container a.temporalControl, #main-content .leaflet-container a.temporalControl a.temporalControl:visited, #main-content .leaflet-container a.temporalControl:hover {
    color: #000;
    text-decoration: none;
}

</style>