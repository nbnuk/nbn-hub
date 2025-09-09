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
                <!-- Year Range Slider -->
                <div class="form-group">
                    <label class="control-label">Year Range</label>
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
                    <strong>Current Year: <span data-display="current">1600</span></strong>
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
            this.mode = 'year';
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
            var currentYear = new Date().getFullYear();
            var self = this;

            this.getSlider().slider({
                range: true,
                min: 1600,
                max: currentYear,
                values: [1600, currentYear],
                slide: function(event, ui) {
                    if (ui && ui.values) {
                        self.getDisplay('range').text(ui.values[0] + ' - ' + ui.values[1]);
                    }
                }
            });

            this.getDisplay('min').text('1600');
            this.getDisplay('max').text(currentYear);
            this.getDisplay('range').text('1600 - ' + currentYear);
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

                self.getDisplay('current').text(self.currentValue);
                self.displayMapForYear(self.currentValue);
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
            this.getDisplay('current').text(this.currentValue);
            this.displayMapForYear(this.currentValue);
        }

        setButtonStates(play, pause, stop, rewind) {
            this.getControl('play').prop('disabled', play);
            this.getControl('pause').prop('disabled', pause);
            this.getControl('stop').prop('disabled', stop);
            this.getControl('rewind').prop('disabled', rewind);
        }

        displayMapForYear(year) {
            console.log("show year " + year);
            // Uncomment when ready:
            /*
            var mapUrl = '/getMap?' + MAP_VAR.currentMapParams + '&q=' + encodeURIComponent(MAP_VAR.currentQuery) + '&year=' + year;
            \$('#map').css('opacity', 0.5);
            \$.get(mapUrl, function(data) {
                \$('#map').html(data);
                \$('#map').css('opacity', 1);
                MAP_VAR.map.invalidateSize();
            });
            */
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
        new TemporalControl('#nbnTemporalControlModal');
        MAP_VAR.map.addControl(new TemporalSearchControl());
        makeModalDraggable('#nbnTemporalControlModal');
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


#temporalControl{
    padding: 6px 10px;
    background-color: #fff;
}
#main-content .leaflet-container a.temporalControl, #main-content .leaflet-container a.temporalControl:visited, #main-content .leaflet-container a.temporalControl:hover {
    color: #000;
    text-decoration: none;
}

</style>

