<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="uk.org.nbn.biocache.hub.HubType" %>
<g:render template="/layouts/global"/>

%{--TODO: get the layers url with the layerid (below) into a config file--}%
<asset:script type="text/javascript">
    var DATA_PROVIDER_WS_URL = "${grailsApplication.config.collectory.baseUrl}/ws/dataProvider";
    var VICE_COUNTY_WS_URL = "https://layers.nbnatlas.org/ws/objects/${grailsApplication.config.layer.vice_county}";
    var VICE_COUNTY_IRELAND_WS_URL = "https://layers.nbnatlas.org/ws/objects/${grailsApplication.config.layer.vice_county_ireland}";
    var LERC_WS_URL = "https://layers.nbnatlas.org/ws/objects/${grailsApplication.config.layer.lerc}";
</asset:script>
<asset:javascript src="nbn/advancedSearch.js"/>
<asset:stylesheet src="nbn/rSlider.min.css"/>
<asset:javascript src="nbn/rSlider.min.js"/>
<asset:stylesheet src="nbn/nbn.css"/>


<div class="nbn">

    <form class="form-horizontal" action="${request.contextPath}/occurrences/searchByOccurrenceID" method="POST">

        <fieldset>
            <legend>Search by Occurrence ID</legend>

            <div class="form-group">
                <label class="col-md-2 control-label" for="occurrenceID">Occurrence ID</label>

                <div class="col-md-6 input-group" style="padding:0px 15px">
                    <input type="text" class="form-control" name="occurrenceID" id="occurrenceID"
                           placeholder="e.g. a record id"/>
                    <span class="input-group-btn">
                        <input class="form-control btn btn-primary" type="submit"
                               value="${g.message(code: "home.index.simsplesearch.button", default: "Search")}"/>
                    </span>
                </div>
            </div>
        </fieldset>
    </form>

    <form class="form-horizontal" name="advancedSearchForm" id="advancedSearchForm"
          action="${request.contextPath}/occurrences/searchByOther" method="POST" id="advancedSearchForm">
        <input type="hidden" name="nameType"
               value="${grailsApplication.config.advancedTaxaField ?: 'matched_name_children'}"/>

        <fieldset>
            <legend>Search by Other</legend>

            <div class="form-group">
                <label class="col-md-2 control-label" for="collectionCode">Event ID</label>

                <div class="col-md-6">
                    <input type="text" class="form-control" name="eventID" id="eventID"
                           placeholder="e.g. A survey id"/>
                </div>
            </div>

            <div class="form-group">
                <label class="col-md-2 control-label" for="collectionCode">Collection Code</label>

                <div class="col-md-6">
                    <input type="text" class="form-control" name="collectionCode" id="collectionCode"
                           placeholder="e.g. A sample id"/>
                </div>
            </div>

            <div class="form-group" id="taxa">
                <label class="col-md-2 control-label" for="taxonText">Taxon name</label>

                <div class="col-md-6">
                    <input type="text" value="" id="taxonText" name="taxonText" class="name_autocomplete form-control"
                           placeholder="Enter a common name or a scientific name" size="60">
                </div>
            </div>


            <div class="form-group">
                <label class="col-md-2 control-label" for="taxonID">Taxon ID (UKSI TVK)</label>

                <div class="col-md-6">
                    <input type="text" value="" id="taxonID" name="taxonID" class="form-control" size="60"
                           placeholder="e.g. NHMSYS0000376154">
                </div>
            </div>

            <div class="form-group">
                <label class="col-md-2 control-label">Native/non-native</label>

                <div class="col-md-6 radio">
                    <label class="radio">
                        <input type="radio" name="nativeStatus" value="ALL" checked>
                        All
                    </label>

                    <label class="radio">
                        <input type="radio" name="nativeStatus" value="NATIVE">
                        Native
                    </label>
                    <label class="radio">
                        <input type="radio" name="nativeStatus" value="NONE-NATIVE">
                        None native
                    </label>
                </div>
            </div>

            <div class="form-group">
                <label class="col-md-2 control-label">Habitat</label>

                <div class="col-md-6 radio">
                    <label class="radio">
                        <input type="radio" name="habitatTaxon" value="ALL" checked>
                        All
                    </label>
                    <label class="radio">
                        <input type="radio" name="habitatTaxon" value="TERRESTRIAL">
                        Terrestrial
                    </label>

                    <label class="radio">
                        <input type="radio" name="habitatTaxon" value="FRESHWATER">
                        Freshwater
                    </label>
                    <label class="radio">
                        <input type="radio" name="habitatTaxon" value="MARINE">
                        Marine
                    </label>
                </div>
            </div>

            <div class="form-group">
                <label class="col-md-2 control-label">Basis of record</label>

                <div class="col-md-6 radio">
                    <label class="checkbox">
                        <input name="basisOfRecord" type="checkbox" value="HumanObservation" checked>
                        Human observation
                    </label>
                    <label class="checkbox">
                        <input name="basisOfRecord" type="checkbox" value="PreservedSpecimen" checked>
                        Preserved specimen
                    </label>
                    <label class="checkbox">
                        <input name="basisOfRecord" type="checkbox" value="FossilSpecimen" checked>
                        Fossil specimen
                    </label>
                    <label class="checkbox">
                        <input name="basisOfRecord" type="checkbox" value="LivingSpecimen" checked>
                        Living specimen
                    </label>
                    <label class="checkbox">
                        <input name="basisOfRecord" type="checkbox" value="MaterialSample" checked>
                        Material sample
                    </label>
                </div>
            </div>

            <div class="form-group">
                <label class="col-md-2 control-label">Identification verification status</label>

                <div class="col-md-6 radio">
                    <label class="radio">
                        <input type="radio" name="identificationVerificationStatus" value="ANY" checked>
                        Any
                    </label>
                    <label class="radio">
                        <input type="radio" name="identificationVerificationStatus" value="ACCEPTED">
                        Accepted
                    </label>
                    <label class="radio">
                        <input type="radio" name="identificationVerificationStatus" value="UNCONFIRMED">
                        Unconfirmed
                    </label>
                </div>
            </div>

            <div class="form-group">
                <label class="col-md-2 control-label" for="identifiedBy">Identified by</label>

                <div class="col-md-6">
                    <input type="text" value="" id="identifiedBy" name="identifiedBy" class="form-control" size="60"
                           placeholder="Enter all or part of the name">
                </div>
            </div>

            <div class="form-group">
                <label class="col-md-2 control-label" for="recordedBy">Recorded by</label>

                <div class="col-md-6">
                    <input type="text" value="" id="recordedBy" name="recordedBy" class="form-control" size="60"
                           placeholder="Enter all or part of the name">
                </div>
            </div>

            <div class="form-group not_done_yet">
                <label class="col-md-2 control-label" for="data-provider">Data partner</label>

                <div class="col-md-6">
                    <select class="form-control" name="dataProviderUID" id="data-provider">
                        <option value="">-- Select one --</option>
                    </select>
                </div>
            </div>


            <div class="form-group">
                <label class="col-md-2 control-label">Licence type</label>

                <div class="col-md-6 radio">
                    <label class="radio">
                        <input name="licenceType" type="radio" value="ALL" checked/>
                        All
                    </label>
                    <label class="radio">
                        <input name="licenceType" type="radio" value="OPEN">
                        Open
                    </label>
                    <label class="radio">
                        <input name="licenceType" type="radio" value="SELECTED">
                        Choose from list
                    </label>
                </div>

            </div>

            <div class="form-group" id="select_licence">
                <label class="col-md-2 control-label"></label>

                <div class="col-md-6">
                    <div class="col-md-4">
                        <div class="checkbox">
                            <label>
                                <input name="selectedLicence" type="checkbox" value="CC0"/>
                                CC0
                            </label>
                        </div>

                        <div class="checkbox">
                            <label>
                                <input name="selectedLicence" type="checkbox" value="OGL"/>
                                OGL
                            </label>
                        </div>

                    </div>

                    <div class="col-md-4">
                        <div class="checkbox">
                            <label>
                                <input name="selectedLicence" type="checkbox" value="CC-BY">
                                CC-BY
                            </label>
                        </div>

                        <div class="checkbox">
                            <label>
                                <input name="selectedLicence" type="checkbox" value="CC-BY-NC">
                                CC-BY-NC
                            </label>
                        </div>
                    </div>

                </div>
            </div>

            <div class="form-group">
                <label class="col-md-2 control-label" for="gridReference">Grid reference</label>

                <div class="col-md-6">
                    <g:if test="${request.HUB == HubType.MAIN || request.HUB == HubType.NI}">
                        <label class="radio-inline"><input name="gridReferenceType" type="radio" value="GB" checked> GB
                        </label> <label class="radio-inline"><input name="gridReferenceType" type="radio"
                                                                    value="IRISH"> Irish</label>
                    </g:if>
                    <input type="text" value="" id="gridReference" name="gridReference" class="form-control" size="8"
                           placeholder="Enter any grid reference e.g.SK5740" maxlength="8" placeholder="">
                </div>
            </div>

            <div class="form-group">
                <label class="col-md-2 control-label" for="lerc">LERC</label>

                <div class="col-md-6">
                    <select class="form-control" name="lercName" id="lerc">
                        <option value="">-- Select one --</option>
                    </select>
                </div>
            </div>

            <g:if test="${request.HUB != HubType.NI}">
                <div class="form-group">
                    <label class="col-md-2 control-label" for="vice-county">Vice county</label>

                    <div class="col-md-6">
                        <select class="form-control" name="viceCountyName" id="vice-county">
                            <option value="">-- Select one --</option>
                        </select>
                    </div>
                </div>
            </g:if>
            <g:if test="${request.HUB == HubType.MAIN || request.HUB == HubType.NI}">
                <div class="form-group">
                    <label class="col-md-2 control-label" for="vice-county-ireland">Vice county Ireland</label>

                    <div class="col-md-6">
                        <select class="form-control" name="viceCountyIrelandName" id="vice-county-ireland">
                            <option value="">-- Select one --</option>
                        </select>
                    </div>
                </div>
            </g:if>

            <div class="form-group">
                <label class="col-md-2 control-label">Occurrence Date</label>

                <div class="col-md-6 radio">
                    <label>
                        <input type="radio" name="dateType" value="ANY" checked> Any
                    </label>
                </div>
            </div>


            <div class="form-group specific_date_input">
                <label class="col-md-2 control-label"></label>

                <div class="col-md-6 radio">
                    <label>
                        <input type="radio" name="dateType" value="SPECIFIC_DATE"> Year and/or month and/or day
                    </label>
                    %{--            <span id="specific_date_input_error" class="help-block hidden">Cannot search by day only. It must be a month and/or a year or a full date</span>--}%
                </div>
            </div>

            <div class="form-group specific_date_input">
                <label class="col-md-2 control-label"></label>

                <div class="col-md-2">
                    <input type="text" value="" placeholder="YYYY" id="year" name="year" class="form-control" size="4"
                           maxlength="4">
                </div>

                <div class="col-md-2">
                    <input type="text" value="" placeholder="MM" id="month" name="month" class="form-control" size="2"
                           maxlength="2">
                </div>

                <div class="col-md-2">
                    <input type="text" value="" placeholder="DD" id="day" name="day" class="form-control" size="2"
                           maxlength="2">
                </div>
            </div>


            <div class="form-group">
                <label class="col-md-2 control-label"></label>

                <div class="col-md-6 radio">
                    <label>
                        <input type="radio" name="dateType" value="YEAR_RANGE"> Year range
                    </label>
                </div>
            </div>

            <div style="height:10px">&nbsp;</div>

            <div class="form-group">
                <label class="col-md-2 control-label"></label>

                <div id="yearRangeSlider" class="col-md-6">
                    <input type="text" id="slider" class="slider" name="yearRange">
                </div>
            </div>


            <div class="form-group">
                <label class="col-md-2 control-label" for="annotations">Annotations</label>

                <div class="col-md-6">
                    <label class="checkbox-inline">
                        <input type="checkbox" id="annotations" name="annotations"
                               value="EXCLUDE_ANNOTATIONS"> Remove records with queries
                    </label>

                </div>
            </div>

            <div class="form-group">
                <div class="col-md-2"></div>

                <div class="col-md-6">
                    <div style="float:right">
                        <input type="reset" value="Clear all" id="clearAll" class="btn btn-default"/>
                        <input type="submit"
                               value=<g:message code="advancedsearch.button.submit" default="Search"/> class="btn
                               btn-primary" />
                    </div>

                </div>

            </div>
        </fieldset>
    </form>
</div>