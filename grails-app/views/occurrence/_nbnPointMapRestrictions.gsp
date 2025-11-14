<g:set var="maxNumPoints" value="${grailsApplication.config.getProperty('feature.enforceMaxPointsOnMap.maxPoints', Long, 500000L)}"/>
<g:set var="maxPointsExceeded" value="${grailsApplication.config.feature?.enforceMaxPointsOnMap?.enabled = 'true' && sr.totalRecords > maxNumPoints}" />


<script type="text/javascript">
    $(document).ready(function() {
        var requireMapRestrictionIcon = false;
        var $select = $('#colourBySelect');
        if (${maxPointsExceeded}) {

            var $secondGroup = $select.find('optgroup').eq(1);
            $secondGroup
                .attr('label', 'Display as points (DISABLED as > ${maxNumPoints} records)')
                .prop('disabled', true);
            $secondGroup.find('option').prop('disabled', true);
            requireMapRestrictionIcon=true;

        }

        if (requireMapRestrictionIcon){
            var warningIcon = $('#warningIconForMapRestrictions a').clone(true);
            warningIcon.tooltip({ placement:'right', container:'body', title:"Map has restricted options - click for details"});
            $('label[for="colourBySelect"]').append(warningIcon);
            $('a[href="#helpWithMapRestrictions"]').click(function (e) {
                e.preventDefault();
                $('#helpWithMapRestrictions').modal('show');
            });

        }
    });
</script>

<div id="warningIconForMapRestrictions" class="hidden">
    <a href="#helpWithMapRestrictions" data-toggle="modal" class="tooltips" ><i class="fa fa-warning"></i></a>
</div>

<g:if test="${maxPointsExceeded}">


    <div id="helpWithMapRestrictions" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header" style="padding-bottom:20px">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true" ><i class="fa fa-close"></i></button>
                </div>
                <div class="modal-body">
                    <p><i class="fa fa-warning"></i> <strong>Map has restricted options</strong></p>
                    <g:if test="${maxPointsExceeded}">
                        <p>The number of records in this search exceeds the maximum allowed for mapping individual points (${grailsApplication.config.getProperty('feature.enforceMaxPointsOnMap.maxPoints', Long, 500000L)}). </p>
                        <p>Please either:</p>
                        <ul>
                            <li>Refine your search to reduce the number of records</li>
                            <li>Choose to map using grid cells (10km or variable size)</li>
                        </ul>

                    </g:if>
                </div>
            </div>
        </div>
    </div>
</g:if>