

<div id="nbnTemporalControlModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="downloadsMapLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">×</button>
                <h3><g:message code="map.temporalcontrol.title" default="Explore changes over time"/></h3>

            </div>
            <div class="modal-body">

<input type="hidden" name="currentPlaybackYear"/>

                <div class="slider-container">
                    <div id="yearRangeSlider"></div>
                    <div class="slider-labels">
                        <span id="yearRangeMin"></span>
                        <span id="yearRangeMax"></span>
                    </div>
                    <div class="slider-value" id="yearRangeValue"></div>
                </div>




                        <!-- Playback controls -->
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <button id="timelineYearPlayBtn">
                                    <i class="fa fa-play" ></i>
                                </button>
                <button id="timelineYearPauseBtn" disabled>
                    <i class="fa fa-pause" ></i>
                </button>
                                <button id="timelineYearStopBtn" disabled>
                                    <i class="fa fa-stop" ></i>
                                </button>
                <button id="timelineYearRewindBtn" disabled>
                    <i class="fa fa-fast-backward" ></i>
                </button>

Year increments: <input type="number" min="1" max="100" value="1" id="yearStep"/>
               Seconds per frame: <input type="number" min="0.5" max="10" value="1" id="yearSpeed"/>
current year: <span id="playbackCurrentYear"></span>
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
$("#timelineYearPlayBtn").click(function(){
    mapYearPlay();
});
$("#timelineYearPauseBtn").click(function(){
    });
$("#timelineYearStopBtn").click(function(){
    stopPlayback();
});
$("#timelineYearRewindBtn").click(function(){
    stopPlayback();
    var currentYear = $( "#yearRangeSlider" ).slider( "values",0);
    $('#playbackCurrentYear').text(currentYear);
    displayMapForYear(currentYear);
    $('#timelineYearPlayBtn').prop('disabled', false);
    $('#timelineYearPauseBtn').prop('disabled', true);
    $('#timelineYearStopBtn').prop('disabled', true);
    $('#timelineYearRewindBtn').prop('disabled', true);
    });

    function mapYearPlay(){
        var currentYear = $( "#yearRangeSlider" ).slider( "values",0);
        var yearStep = parseInt($('#yearStep').val());
        var yearSpeed = parseFloat($('#yearSpeed').val()) * 1000;
        var endYear = $( "#yearRangeSlider" ).slider( "values",1);
        $('#timelineYearPlayBtn').prop('disabled', true);
        $('#timelineYearPauseBtn').prop('disabled', false);
        $('#timelineYearStopBtn').prop('disabled', false);
        $('#timelineYearRewindBtn').prop('disabled', false);
        console.log("***endYear:"+endYear);
        window.yearPlayInterval = setInterval(function(){
            currentYear += yearStep;
            if(currentYear > endYear){
               stopPlayback();
               return;
            }
            $('#playbackCurrentYear').text(currentYear);
            displayMapForYear(currentYear);

            }, yearSpeed);


    }

    function stopPlayback(){console.log("STOP");
        clearInterval(window.yearPlayInterval);
        $('#timelineYearPlayBtn').prop('disabled', false);
        $('#timelineYearPauseBtn').prop('disabled', true);
        $('#timelineYearStopBtn').prop('disabled', true);
        $('#timelineYearRewindBtn').prop('disabled', true);
    }

    function displayMapForYear(year){
        console.log("show year "+year);
        return;
        var mapUrl="/getMap?"+MAP_VAR.currentMapParams+"&q="+encodeURIComponent(MAP_VAR.currentQuery)+"&year="+year;
        $('#map').css('opacity',0.5);
        $.get(mapUrl, function(data){
            $('#map').html(data);
            $('#map').css('opacity',1);
            MAP_VAR.map.invalidateSize();
        });
    }

    $(document).ready(function () {

       $( "#yearRangeSlider" ).slider({
	range: true,
	min: 1600,
      max: new Date().getFullYear(),
	values: [ 1600, new Date().getFullYear() ],
	slide: function( event, ui ) {
        $( "#yearRangeValue" ).text( ui.values[ 0 ] + " - " + ui.values[ 1 ] );
      }
});

$( "#yearRangeMin" ).text(1600);
$( "#yearRangeMax" ).text(new Date().getFullYear());
       $( "#yearRangeValue" ).text( $( "#yearRangeSlider" ).slider( "values", 0 ) +
      " -" + $( "#yearRangeSlider" ).slider( "values", 1 ) );


       var TemporalSearchControl = L.Control.extend({
        options: {
            position: 'topright',
            collapsed: false
        },
        onAdd: function (map) {

            var container = L.DomUtil.create('div', 'leaflet-control-layers');
            var $container = $(container);
            $container.attr("id", "temporalControl");
            $container.attr('aria-haspopup', true);
            container.innerHTML='<a data-toggle="modal" href="#nbnTemporalControlModal" class="temporalControl"><i class="fa fa-clock-o fa-lg"></i></a>'
            L.DomEvent.disableClickPropagation(container);
            // var stop = L.DomEvent.stopPropagation;
            // L.DomEvent
            //     .on(container, 'click', stop)
            //     .on(container, 'mousedown', stop);
            return container;
        }
    });



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



