<g:set var="maxNumPoints" value="${grailsApplication.config.getProperty('feature.enforceMaxPointsOnMap.maxPoints', Long, 500000L)}"/>
<g:set var="maxPointsExceeded" value="${grailsApplication.config.feature?.enforceMaxPointsOnMap?.enabled = 'true' && sr.totalRecords > maxNumPoints}" />
<g:set var="yearFacetDisabled" value="${false}"/>
<g:set var="decadeFacetDisabled" value="${false}"/>
<g:each var="facetResult" in="${facets}">
    <g:if test="${ facetResult.fieldName.equals("year") && (facetResult.fieldResult.size()>30)}">
        <g:set var="yearFacetDisabled" value="${true}"/>
    </g:if>
    <g:if test="${ facetResult.fieldName.equals("decade") && (facetResult.fieldResult.size()>30)}">
        <g:set var="decadeFacetDisabled" value="${true}"/>
    </g:if>
</g:each>

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

        if (${yearFacetDisabled}){
            var $year = $select.find('option[value="year"]');
            var currentLabel = $year.text();
            $year.text(currentLabel+' (exceeds max distinct years (30), please filter)').prop('disabled', true);
            requireMapRestrictionIcon=true;
        }

        if (${decadeFacetDisabled}){
            var $decade = $select.find('option[value="decade"]');
            var currentLabel = $decade.text();
            $decade.text(currentLabel+' (exceeds max distinct decades (30), please filter)').prop('disabled', true);
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

<g:if test="${maxPointsExceeded || yearFacetDisabled || decadeFacetDisabled}">


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
                    <g:else>
                        <ul>
                            <g:each var="facetResult" in="${facets}">
                                <g:if test="${facetResult.fieldName.equals("year") && yearFacetDisabled}">
                                    <li>The maximum number of distinct years that can be displayed is 30 but the search result contains ${facetResult.fieldResult.size()} distinct years. To display years as points, please narrow your results to at most 30 years by filtering by year (on the left) </li>

                                </g:if>
                                <g:if test="${facetResult.fieldName.equals("decade") &&  decadeFacetDisabled}">
                                    <li>The maximum number of distinct decade spans that can be displayed is 30 but the search result contains ${facetResult.fieldResult.size()} distinct decade spans. To display decade spans as points, please narrow your results to at most 30 decade spans by filtering by decade spans (on the left) </li>
                                </g:if>
                            </g:each>
                        </ul>
                    </g:else>
                </div>
            </div>
        </div>
    </div>
</g:if>