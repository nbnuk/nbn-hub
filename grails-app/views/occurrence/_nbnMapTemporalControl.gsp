


<div id="nbnTemporalControlModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="downloadsMapLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">×</button>
                <h3>
                    <g:message code="map.temporalcontrol.title" default="Explore changes over time"/>
                </h3>
            </div>
            <div class="modal-body">
<p>Form goes here</p>

            </div>

        </div>
    </div>
</div>



<script>
    var bsTooltip = $.fn.tooltip;
</script>
<asset:javascript src="nbn/draggable-modal.js" />

<asset:script type="text/javascript">

    $(document).ready(function () {

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


    // $('#nbnTemporalControlModal').on('shown.bs.modal', function () {
    //     $(this).find('.modal-dialog').draggable({
    //         handle: ".modal-header"  // Drag only by header
    //     });
    //   });

    makeModalDraggable('#nbnTemporalControlModal');

   });

</asset:script>


<style>
#temporalControl{
    padding: 6px 10px;
    background-color: #fff;
}
#main-content .leaflet-container a.temporalControl, #main-content .leaflet-container a.temporalControl:visited, #main-content .leaflet-container a.temporalControl:hover {
    color: #000;
    text-decoration: none;
}

</style>



