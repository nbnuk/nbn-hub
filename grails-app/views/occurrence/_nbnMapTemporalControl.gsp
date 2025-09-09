<div id="nbnTemporalControlModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="downloadsMapLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">×</button>
                <h3><g:message code="map.temporalcontrol.title" default="Explore changes over time"/></h3>
            </div>
            <div class="modal-body">

                <div class="slider-container">
                    <div data-slider="range"></div>
                    <div class="slider-labels">
                        <span data-display="min">1600</span>
                        <span data-display="max">2024</span>
                    </div>
                    <div class="slider-value" data-display="range"></div>
                </div>

                <!-- Playback controls -->
                <div style="display: flex; align-items: center; gap: 10px;">
                    <button class="btn btn-default btn-small" data-control="play">
                        <i class="fa fa-play"></i>
                    </button>
                    <button class="btn btn-default btn-small" data-control="pause" disabled>
                        <i class="fa fa-pause"></i>
                    </button>
                    <button class="btn btn-default btn-small" data-control="stop" disabled>
                        <i class="fa fa-stop"></i>
                    </button>
                    <button class="btn btn-default btn-small" data-control="rewind" disabled>
                        <i class="fa fa-fast-backward"></i>
                    </button>

                    Year increments: <input type="number" min="1" step="1" max="100" value="1" data-setting="step"/>
                    Seconds per frame: <input type="number" min="0.5" max="10" step="0.5" value="1" data-setting="speed"/>
                    Current year: <span data-display="current"></span>
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

