<%@ page import="au.org.ala.biocache.hubs.FacetsName; org.apache.commons.lang.StringUtils" contentType="text/html;charset=UTF-8" %>
<g:render template="/layouts/global"/>

%{--TODO: get the layers url with the layerid (below) into a config file--}%
<asset:script type="text/javascript">
    var DATA_PROVIDER_WS_URL = "${grailsApplication.config.collectory.baseUrl}/ws/dataProvider";
    var VICE_COUNTY_WS_URL = "https://layers.nbnatlas.org/ws/objects/cl254";
</asset:script>
<asset:javascript src="nbn/advancedSearch.js" />
<asset:stylesheet src="nbn/rSlider.min.css" />
<asset:javascript src="nbn/rSlider.min.js" />
<asset:stylesheet src="nbn/nbn.css" />


<div class="nbn">


    <form class="form-horizontal" action="${request.contextPath}/occurrences/searchByOccurrenceID" method="POST" >


        <fieldset>
        <legend>Search by Occurrence ID</legend>
        <div class="form-group">
                <label class="col-md-2 control-label" for="occurrenceID">Occurrence ID</label>
                <div class="col-md-6 input-group" style="padding:0px 15px">
                        <input type="text" class="form-control" name="occurrenceID" id="occurrenceID"/>
                        <span class="input-group-btn">
                            <input class="form-control btn btn-primary" type="submit"
                                   value="${g.message(code:"home.index.simsplesearch.button", default:"Search")}"/>
                        </span>
                </div>
        </div>
    </fieldset>
    </form>


        <form class="form-horizontal" action="${request.contextPath}/occurrences/searchByEventID" method="POST">
            <fieldset>
                <legend>Search by Event ID</legend>
                <div class="form-group">
                    <label class="col-md-2 control-label" for="collectionCode">Event ID</label>
                    <div class="col-md-6 input-group" style="padding:0px 15px">
                        <input type="text" class="form-control" name="eventID" id="eventID"/>
                        <span class="input-group-btn">
                            <input class="form-control btn btn-primary" type="submit"
                                   value="${g.message(code:"home.index.simsplesearch.button", default:"Search")}"/>
                        </span>
                    </div>
                </div>
            </fieldset>
        </form>



        <form class="form-horizontal" action="${request.contextPath}/occurrences/searchByCollectionCode" method="POST">
            <fieldset>
                <legend>Search by Collection Code</legend>
                <div class="form-group">
                    <label class="col-md-2 control-label" for="collectionCode">Collection Code</label>
                    <div class="col-md-6 input-group" style="padding:0px 15px">
                        <input type="text" class="form-control" name="collectionCode" id="collectionCode"/>
                        <span class="input-group-btn">
                            <input class="form-control btn btn-primary" type="submit"
                                   value="${g.message(code:"home.index.simsplesearch.button", default:"Search")}"/>
                        </span>
                    </div>
                </div>
            </fieldset>
        </form>



        <form class="form-horizontal" name="advancedSearchForm" id="advancedSearchForm"
              action="${request.contextPath}/occurrences/searchByOther" method="POST" id="advancedSearchForm">
            <input type="hidden" name="nameType" value="${grailsApplication.config.advancedTaxaField?:'matched_name_children'}"/>

    <fieldset>
        <legend>Search by Other</legend>


    <div class="form-group" id="taxa">
        <label class="col-md-2 control-label" for="taxonText">Taxon name</label>
        <div class="col-md-6" >
            <input type="text" value="" id="taxonText" name="taxonText" class="name_autocomplete form-control" size="60" >
        </div>
    </div>



    <div class="form-group" >
        <label class="col-md-2 control-label" for="taxonID">Taxon ID (UKSI TVK)</label>
        <div class="col-md-6">
            <input type="text" value="" id="taxonID" name="taxonID" class="form-control" size="60">
        </div>
    </div>

    <div class="form-group">
        <label class="col-md-2 control-label">Basis of record</label>
        <div class="col-md-2">
            <div class="checkbox">
                <label>
                    <input name="basisOfRecord" type="checkbox" value="HumanObservation" checked>
                    Human observation
                </label>
            </div>
            <div class="checkbox">
                <label>
                    <input name="basisOfRecord" type="checkbox" value="PreservedSpecimen" checked>
                    Preserved specimen
                </label>
            </div>

        </div>
        <div class="col-md-2">
            <div class="checkbox">
                <label>
                    <input name="basisOfRecord" type="checkbox" value="FossilSpecimen" checked>
                    Fossil specimen
                </label>
            </div>
            <div class="checkbox">
                <label>
                    <input name="basisOfRecord" type="checkbox" value="LivingSpecimen" checked>
                    Living specimen
                </label>
            </div>
        </div>
        <div class="col-md-2">
            <div class="checkbox">
                <label>
                    <input name="basisOfRecord" type="checkbox" value="MaterialSample" checked>
                    Material sample
                </label>
            </div>
        </div>
    </div>

    <div class="form-group">
        <label class="col-md-2 control-label" >Identification verification status</label>
        <div class="col-md-6">
            <div class="radio">
                <label>
                    <input type="radio" name="identificationVerificationStatus" value="ANY" checked>
                    Any
                </label>
            </div>
            <div class="radio">
                <label>
                    <input type="radio" name="identificationVerificationStatus" value="ACCEPTED">
                    Accepted
                </label>
            </div>
            <div class="radio">
                <label>
                    <input type="radio" name="identificationVerificationStatus" value="UNCONFIRMED" >
                    Unconfirmed
                </label>
            </div>
        </div>


    </div>



    <div class="form-group">
        <label class="col-md-2 control-label" for="identifiedBy">Identified by</label>
        <div class="col-md-6">
            <input type="text" value="" id="identifiedBy" name="identifiedBy" class="form-control" size="60">
        </div>
    </div>

    <div class="form-group">
        <label class="col-md-2 control-label" for="recordedBy">Recorded by</label>
        <div class="col-md-6">
            <input  type="text" value="" id="recordedBy" name="recordedBy" class="form-control" size="60">
        </div>
    </div>

    <div class="form-group not_done_yet" >
        <label class="col-md-2 control-label" for="data-provider">Data partners</label>
        <div class="col-md-6">
            <select class="form-control" name="dataProviderUID" id="data-provider" >
                <option value="">-- select one --</option>
            </select>
        </div>
    </div>





            <div class="form-group">
                <label class="col-md-2 control-label">Licence type</label>
                <div class="col-md-6">
                    <div class="radio">
                        <label>
                            <input name="licenceType" type="radio"  value="ALL" checked/>
                            All
                        </label>
                    </div>
                    <div class="radio">
                        <label>
                            <input name="licenceType" type="radio" value="OPEN" >
                            Open
                        </label>
                    </div>
                    <div class="radio">
                        <label>
                            <input name="licenceType" type="radio" value="SELECTED" >
                            Choose from list
                        </label>
                    </div>
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
                                <input name="selectedLicence" type="checkbox" value="OGL" />
                                OGL
                            </label>
                        </div>

                    </div>
                    <div class="col-md-4">
                        <div class="checkbox">
                            <label>
                                <input name="selectedLicence" type="checkbox" value="CC-BY" >
                                CC-BY
                            </label>
                        </div>
                        <div class="checkbox">
                            <label>
                                <input name="selectedLicence" type="checkbox" value="CC-BY-NC" >
                                CC-BY-NC
                            </label>
                        </div>
                    </div>

                    </div>
                </div>

    <div class="form-group">
        <label class="col-md-2 control-label" for="gridReference">Grid reference</label>
        <div class="col-md-6">
            <label class="radio-inline"><input name="gridReferenceType" type="radio" value="GB" checked> GB</label> <label class="radio-inline"><input name="gridReferenceType" type="radio" value="IRISH" > Irish</label>
            <input type="text" value="" id="gridReference" name="gridReference" class="form-control" size="8" maxlength="8" placeholder="">
        </div>
    </div>

        <div class="form-group" >
            <label class="col-md-2 control-label" for="vice-county">Vice county</label>
            <div class="col-md-6">
                <select class="form-control" name="viceCountyName" id="vice-county" >
                    <option value="">-- select one --</option>
                </select>
            </div>
        </div>

        <div class="form-group">
            <label class="col-md-2 control-label" >Date</label>
            <div class="col-md-6 radio">
                <label>
                    <input type="radio" name="dateType" value="ANY" checked> Any
                </label>
            </div>
        </div>


        <div class="form-group specific_date_input">
        <label class="col-md-2 control-label" ></label>
        <div class="col-md-6 radio">
        <label>
            <input type="radio" name="dateType" value="SPECIFIC_DATE"> Year OR month OR year/month/day
        </label>
            <span id="specific_date_input_error" class="help-block hidden">Cannot search by day only. It must be a month and/or a year or a full date</span>
        </div>
    </div>

    <div class="form-group specific_date_input">
        <label class="col-md-2 control-label"></label>
        <div class="col-md-2">
            <input type="text" value="" placeholder="YYYY" id="year" name="year" class="form-control" size="4" maxlength="4">
        </div>
        <div class="col-md-2">
            <input type="text" value="" placeholder="MM" id="month" name="month" class="form-control" size="2" maxlength="2">
        </div>
        <div class="col-md-2">
            <input type="text" value="" placeholder="DD" id="day" name="day" class="form-control" size="2" maxlength="2">
        </div>
    </div>


    <div class="form-group"  >
        <label class="col-md-2 control-label"></label>
        <div class="col-md-6 radio">
            <label>
                <input type="radio" name="dateType" value="YEAR_RANGE" > Year range
            </label>
        </div>
    </div>

    <div style="height:10px">&nbsp;</div>
    <div class="form-group">
        <label class="col-md-2 control-label">  </label>
        <div id="yearRangeSlider" class="col-md-6">
            <input type="text" id="slider" class="slider" name="yearRange">
        </div>
    </div>


    <div class="form-group">
        <label class="col-md-2 control-label" for="annotations">Annotations</label>
        <div class="col-md-6">
            <label class="checkbox-inline">
                <input type="checkbox" id="annotations" name="annotations" value="EXCLUDE_ANNOTATIONS"> Remove records with queries
            </label>

        </div>
    </div>

    <div class="form-group">
        <div class="col-md-2"></div>
        <div class="col-md-6" >
            <div style="float:right">
            <input type="reset" value="Clear all" id="clearAll" class="btn btn-default" />
            <input type="submit" value=<g:message code="advancedsearch.button.submit" default="Search"/> class="btn btn-primary" />
    </div>

        </div>

        </div>
    </fieldset>
</form>
</div>






