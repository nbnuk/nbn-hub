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
                            <label class="control-label">Speed (sec)</label>
                            <input type="number" class="form-control input-sm" min="0.1" max="10" step="0.1" value="1" data-setting="speed">
                        </div>
                    </div>
                </div>

                <!-- Current Year Display -->
                <div class="alert alert-info text-center" style="margin-bottom: 0;">
                    <strong>Current Year: <span data-display="current">-</span></strong>
                </div>


                </div>
                <div role="tabpanel" class="tab-pane" id="month-tab">
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

                    <!-- Current Month Display -->
                    <div class="alert alert-info text-center" style="margin-bottom: 0;">
                        <strong>Current Month: <span data-display="current">-</span></strong>
                    </div>
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
        constructor(selector) {
            this.container = $(selector);
            this.player = null;
            this.currentValue = "";
            this.isPaused = false;
            this.mode = selector.includes('month') ? 'month' : 'year';
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
            var self = this;
            var minAndMaxYears = self.getMinMaxYears();
            console.log(minAndMaxYears);
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
            var endValue = this.getSlider().slider("values", 1);
            var step = parseInt(this.getSetting('step').val());
            var speed = parseFloat(this.getSetting('speed').val()) * 1000;
            var self = this;

            if (!this.isPaused) {
                this.currentValue = this.getSlider().slider("values", 0);
            }

            this.isPaused = false;
            this.setButtonStates(true, false, false, false);

            this.player = setInterval(function() {
                self.currentValue += step;

                if (self.currentValue > endValue) {
                    self.stop();
                    return;
                }

                if (self.mode === 'month') {
                    var monthName = self.monthNames[self.currentValue - 1] || 'December';
                    self.getDisplay('current').text(monthName);
                } else {
                    self.getDisplay('current').text(self.currentValue);
                }
                
                self.displayMapForValue(self.currentValue);
            }, speed);
        }

        pause() {
            clearInterval(this.player);
            this.isPaused = true;
            this.setButtonStates(false, true, false, false);
        }

        stop() {
            clearInterval(this.player);
            this.isPaused = false;
            this.setButtonStates(false, true, true, false);
        }

        rewind() {
            this.stop();
            this.setButtonStates(false, true, true, true);
            this.currentValue = this.getSlider().slider("values", 0);
            
            if (this.mode === 'month') {
                var monthName = this.monthNames[this.currentValue - 1] || 'January';
                this.getDisplay('current').text(monthName);
            } else {
                this.getDisplay('current').text(this.currentValue);
            }
            
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
                // Uncomment when ready for month functionality:
                /*
                var mapUrl = '/getMap?' + MAP_VAR.currentMapParams + '&q=' + encodeURIComponent(MAP_VAR.currentQuery) + '&month=' + value;
                \$('#map').css('opacity', 0.5);
                \$.get(mapUrl, function(data) {
                    \$('#map').html(data);
                    \$('#map').css('opacity', 1);
                    MAP_VAR.map.invalidateSize();
                });
                */
            } else {
                console.log("show year " + value);
                MAP_VAR.additionalFqs = '&fq=year:' + value;
        // clear this variable every time a new colour by is chosen.
        MAP_VAR.removeFqs = ''
        //e.preventDefault();
        //e.stopPropagation();
        addQueryLayer(true);
                // Uncomment when ready:
                /*
                var mapUrl = '/getMap?' + MAP_VAR.currentMapParams + '&q=' + encodeURIComponent(MAP_VAR.currentQuery) + '&year=' + value;
                \$('#map').css('opacity', 0.5);
                \$.get(mapUrl, function(data) {
                    \$('#map').html(data);
                    \$('#map').css('opacity', 1);
                    MAP_VAR.map.invalidateSize();
                });
                */
            }
        }

        getMinMaxYears(){
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
        new TemporalControl('#year-tab');
        new TemporalControl('#month-tab');
        MAP_VAR.map.addControl(new TemporalSearchControl());
        makeModalDraggable('#nbnTemporalControlModal');
    });

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

    // Set defaults
    var minYear = 1600;
    var maxYear = new Date().getFullYear();

    // Find actual min and max years from data if available
    if (years.length > 0) {
        var dataMinYear = Math.min.apply(Math, years);
        var dataMaxYear = Math.max.apply(Math, years);

        // Use data values if they exist, otherwise keep defaults
        minYear = dataMinYear;
        maxYear = dataMaxYear;
    }

    console.log('Min year:', minYear);
    console.log('Max year:', maxYear);

    // You can now use minYear and maxYear as needed
} else {
    // No year facet data available, use defaults
    var minYear = 1600;
    var maxYear = new Date().getFullYear();

    console.log('No year data available, using defaults - Min year:', minYear, 'Max year:', maxYear);
}
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