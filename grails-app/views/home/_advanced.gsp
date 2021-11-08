<%@ page import="au.org.ala.biocache.hubs.FacetsName; org.apache.commons.lang.StringUtils" contentType="text/html;charset=UTF-8" %>
<g:render template="/layouts/global"/>

<asset:script type="text/javascript">
    var DATA_PROVIDER_WS_URL = "${grailsApplication.config.collectory.baseUrl}/ws/dataProvider";
</asset:script>
<asset:javascript src="nbn/advancedSearch.js" />
<asset:stylesheet src="nbn/rSlider.min.css" />
<asset:javascript src="nbn/rSlider.min.js" />
<asset:stylesheet src="nbn/nbn.css" />


%{--<asset:stylesheet src="nbn/nbn.css" />--}%

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
%{--            <input type="text" id="solrQuery" name="q" style="position:absolute;left:-9999px;" value="${params.q}"/>--}%
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
<!--https://registry.nbnatlas.org/ws/dataProvider-->
    <div class="form-group not_done_yet" >
        <label class="col-md-2 control-label" for="data-provider">Data partners</label>
        <div class="col-md-6">
            <select class="form-control" name="dataProviderUID" id="data-provider" >
                <option value="">-- select one --</option>

%{--                <option>Aggregate Industries</option>--}%
%{--                <option>Amphibian and Reptile Conservation</option>--}%
%{--                <option>Amphibian and Reptile Groups of the UK</option>--}%
%{--                <option>Anthomyiid Recording Scheme</option>--}%
%{--                <option>Aquatic Coleoptera Conservation Trust</option>--}%
%{--                <option>Aquatic Heteroptera Recording Scheme</option>--}%
%{--                <option>Arcadis</option>--}%
%{--                <option>Argyll Biological Records Centre</option>--}%
%{--                <option>Argyll Bird Club</option>--}%
%{--                <option>Astell Associates</option>--}%
%{--                <option>Balfour-Browne Club</option>--}%
%{--                <option>Bat Conservation Trust</option>--}%
%{--                <option>Bats and the Millennium Link</option>--}%
%{--                <option>Bedfordshire and Luton Biodiversity Recording and Monitoring Centre</option>--}%
%{--                <option>Berkshire Moth Group</option>--}%
%{--                <option>Berkshire Reptile and Amphibian Group</option>--}%
%{--                <option>Biological Records Centre</option>--}%
%{--                <option>BIS for Powys & Brecon Beacons National Park</option>--}%
%{--                <option>Botanical Society of Britain & Ireland</option>--}%
%{--                <option>Bristol Regional Environmental Records Centre</option>--}%
%{--                <option>British Bryological Society</option>--}%
%{--                <option>British Dragonfly Society Recording Scheme</option>--}%
%{--                <option>British Lichen Society</option>--}%
%{--                <option>British Mycological Society</option>--}%
%{--                <option>British Myriapod and Isopod Group</option>--}%
%{--                <option>British Trust for Ornithology</option>--}%
%{--                <option>Broadland Environmental Services Limited</option>--}%
%{--                <option>Buglife</option>--}%
%{--                <option>Bumblebee Conservation Trust</option>--}%
%{--                <option>Butterfly Conservation</option>--}%
%{--                <option>Caledonian Conservation</option>--}%
%{--                <option>Cambridgeshire & Peterborough Environmental Records Centre</option>--}%
%{--                <option>Capturing our Coast</option>--}%
%{--                <option>Caring for God’s Acre</option>--}%
%{--                <option>Central Scotland Green Network Trust</option>--}%
%{--                <option>Centre for Environmental Data and Recording</option>--}%
%{--                <option>Chrysomelidae Recording Scheme</option>--}%
%{--                <option>Cladocera Interest Group</option>--}%
%{--                <option>Cofnod – North Wales Environmental Information Service</option>--}%
%{--                <option>Conchological Society of Great Britain & Ireland</option>--}%
%{--                <option>Cumbria Biodiversity Data Centre</option>--}%
%{--                <option>Derbyshire Biological Records Centre</option>--}%
%{--                <option>Derbyshire Wildlife Trust</option>--}%
%{--                <option>Dipterists Forum</option>--}%
%{--                <option>Dorset Bird Club</option>--}%
%{--                <option>Dorset Environmental Records Centre</option>--}%
%{--                <option>Dr Thomas and Mrs Rizwana Shelley</option>--}%
%{--                <option>Earthworm Society of Britain</option>--}%
%{--                <option>East Ayrshire Countryside Ranger Service</option>--}%
%{--                <option>Environment Agency</option>--}%
%{--                <option>Environmental Records Information Centre North East</option>--}%
%{--                <option>Essex Wildlife Trust Biological Records Centre</option>--}%
%{--                <option>European Micropezids & Tanypezids</option>--}%
%{--                <option>Fife Nature Records Centre</option>--}%
%{--                <option>Forth Rivers Trust</option>--}%
%{--                <option>Freshwater Fish Recording Scheme</option>--}%
%{--                <option>Freshwater Habitats Trust</option>--}%
%{--                <option>Friends of Combe Valley</option>--}%
%{--                <option>Friends of the Earth</option>--}%
%{--                <option>Froglife</option>--}%
%{--                <option>Game & Wildlife Conservation Trust</option>--}%
%{--                <option>Glasgow Museums Biological Records Centre</option>--}%
%{--                <option>Gloucestershire Centre for Environmental Records</option>--}%
%{--                <option>Grasshopper Recording Scheme</option>--}%
%{--                <option>Greater Manchester Ecology Unit</option>--}%
%{--                <option>Greenspace Information for Greater London CIC</option>--}%
%{--                <option>Groundwork North, East & West Yorkshire</option>--}%
%{--                <option>Hall Ecology</option>--}%
%{--                <option>Harwes Farm Community Interest Company</option>--}%
%{--                <option>Hebridean Whale and Dolphin Trust</option>--}%
%{--                <option>Herefordshire Wildlife Trust</option>--}%
%{--                <option>Hertfordshire Natural History Society Flora Group</option>--}%
%{--                <option>Highland Biological Recording Group</option>--}%
%{--                <option>Hutchinson Ecological Associates</option>--}%
%{--                <option>Hypogean Crustacea Recording Scheme</option>--}%
%{--                <option>Islay Natural History Trust</option>--}%
%{--                <option>Isle of Wight Local Records Centre</option>--}%
%{--                <option>JBA Consulting</option>--}%
%{--                <option>John Muir Trust</option>--}%
%{--                <option>Joint Nature Conservation Committee</option>--}%
%{--                <option>Kent & Medway Biological Records Centre</option>--}%
%{--                <option>Kent Wildlife Trust</option>--}%
%{--                <option>Knotweed Control Swansea Limited</option>--}%
%{--                <option>Lancashire Environment Record Network</option>--}%
%{--                <option>Leeds Museums and Galleries</option>--}%
%{--                <option>Leicestershire and Rutland Environmental Records Centre</option>--}%
%{--                <option>Lochaber Fisheries Trust</option>--}%
%{--                <option>Longstrip Wildlife</option>--}%
%{--                <option>Malcolm Storey</option>--}%
%{--                <option>Manx Biological Recording Partnership</option>--}%
%{--                <option>Manx National Heritage</option>--}%
%{--                <option>Manx Wildlife Trust</option>--}%
%{--                <option>Marine Biological Association</option>--}%
%{--                <option>Marine Conservation Society</option>--}%
%{--                <option>Marine Environmental Monitoring</option>--}%
%{--                <option>Marine Life Angus</option>--}%
%{--                <option>Merseyside BioBank</option>--}%
%{--                <option>Michiel Vos</option>--}%
%{--                <option>Ministry of Justice</option>--}%
%{--                <option>National Museums Scotland</option>--}%
%{--                <option>National Plant Monitoring Scheme</option>--}%
%{--                <option>National Trust</option>--}%
%{--                <option>National Trust for Scotland</option>--}%
%{--                <option>Natural Apptitude</option>--}%
%{--                <option>Natural England</option>--}%
%{--                <option>Natural Resources Wales</option>--}%
%{--                <option>NatureScot</option>--}%
%{--                <option>NatureSpot</option>--}%
%{--                <option>NBN Atlas test data provider</option>--}%
%{--                <option>Newcastle University</option>--}%
%{--                <option>Nocturne Environmental Surveyors Ltd</option>--}%
%{--                <option>Norfolk Biodiversity Information Service</option>--}%
%{--                <option>North Ayrshire Countryside Ranger Service</option>--}%
%{--                <option>North East Scotland Biological Records Centre</option>--}%
%{--                <option>North West Fungus Group</option>--}%
%{--                <option>Northumberland Wildlife Trust</option>--}%
%{--                <option>Norwich Reptile Study Group</option>--}%
%{--                <option>Nottingham Urban Wildlife Scheme</option>--}%
%{--                <option>Nottinghamshire Biological and Geological Records Centre</option>--}%
%{--                <option>Nottinghamshire Wildlife Trust</option>--}%
%{--                <option>Oil Beetle Recording Scheme</option>--}%
%{--                <option>OPAL</option>--}%
%{--                <option>Outer Hebrides Biological Recording</option>--}%
%{--                <option>People's Trust for Endangered Species</option>--}%
%{--                <option>Plantlife</option>--}%
%{--                <option>Porcupine Marine Natural History Society</option>--}%
%{--                <option>Project Splatter</option>--}%
%{--                <option>Pseudoscorpion Recording Scheme</option>--}%
%{--                <option>Record</option>--}%
%{--                <option>Riverfly Recording Schemes</option>--}%
%{--                <option>Rossendale Ornithologists' Club</option>--}%
%{--                <option>Rotherham Biological Records Centre</option>--}%
%{--                <option>Royal Botanic Garden Edinburgh</option>--}%
%{--                <option>Royal Botanic Gardens, Kew</option>--}%
%{--                <option>Royal Horticultural Society</option>--}%
%{--                <option>Royal Society for the Protection of Birds</option>--}%
%{--                <option>Salmon & Trout Conservation</option>--}%
%{--                <option>Scotland's Environment Web</option>--}%
%{--                <option>Scottish Beavers</option>--}%
%{--                <option>Scottish Environment Protection Agency</option>--}%
%{--                <option>Scottish Ornithologists' Club, The</option>--}%
%{--                <option>Scottish Raptor Monitoring Scheme</option>--}%
%{--                <option>Scottish Shark Tagging Programme, The</option>--}%
%{--                <option>Scottish Wildlife Trust</option>--}%
%{--                <option>Seasearch</option>--}%
%{--                <option>Seed & Leaf Beetle Recording Scheme (Chrysomelidae, Orsodacnidae & Megalopodidae)</option>--}%
%{--                <option>Sheffield and Rotherham Wildlife Trust</option>--}%
%{--                <option>Sheffield Bird Study Group</option>--}%
%{--                <option>Shire Group of Internal Drainage Boards</option>--}%
%{--                <option>Shropshire Ecological Data Network</option>--}%
%{--                <option>Silphidae Recording Scheme</option>--}%
%{--                <option>Siphonaptera and Phthiraptera Recording Scheme</option>--}%
%{--                <option>Soldier Beetles and Allies Recording Scheme</option>--}%
%{--                <option>Soldierflies and Allies Recording Scheme</option>--}%
%{--                <option>South East Wales Biodiversity Records Centre</option>--}%
%{--                <option>South West Scotland Environmental Information Centre (formerly DGERC)</option>--}%
%{--                <option>Staffordshire Ecological Record</option>--}%
%{--                <option>Steve Lane</option>--}%
%{--                <option>Stichtig Duik de Noordzee Schoon</option>--}%
%{--                <option>Suffolk Biodiversity Information Service</option>--}%
%{--                <option>Sussex Biodiversity Record Centre</option>--}%
%{--                <option>Tachinid Recording Scheme</option>--}%
%{--                <option>Terrestrial Heteroptera Recording Scheme (Shieldbugs & allied species)</option>--}%
%{--                <option>Thames Valley Environmental Records Centre</option>--}%
%{--                <option>The British Association for Shooting and Conservation</option>--}%
%{--                <option>The Conservation Volunteers Scotland</option>--}%
%{--                <option>The Department of Environment, Food and Agriculture (DEFA), Isle of Man Government</option>--}%
%{--                <option>The Groves Nature Watch Group</option>--}%
%{--                <option>The James Hutton Institute</option>--}%
%{--                <option>The Mammal Society</option>--}%
%{--                <option>The National Longhorn Beetle Recording Scheme</option>--}%
%{--                <option>The Rock Pool Project</option>--}%
%{--                <option>The Wildlife Information Centre</option>--}%
%{--                <option>The Wildlife Trusts</option>--}%
%{--                <option>The Woodland Trust</option>--}%
%{--                <option>UK Butterfly Monitoring Scheme</option>--}%
%{--                <option>UK Cranefly Recording Scheme</option>--}%
%{--                <option>University of Barcelona (Spain)</option>--}%
%{--                <option>University of Reading</option>--}%
%{--                <option>Weevil and Bark Beetle Recording Scheme</option>--}%
%{--                <option>Welsh Government</option>--}%
%{--                <option>West Wales Biodiversity Information Centre</option>--}%
%{--                <option>Whale and Dolphin Conservation</option>--}%
%{--                <option>Wild Surveys</option>--}%
%{--                <option>Woodmeadow Trust</option>--}%
%{--                <option>Worcestershire Flora Project</option>--}%
%{--                <option>World Museum, National Museums Liverpool</option>--}%
%{--                <option>Wye Valley Area of Outstanding Natural Beauty (AONB)</option>--}%
%{--                <option>Yorkshire Naturalists' Union</option>--}%
%{--                <option>Yorkshire Wildlife Trust</option>--}%
            </select>
        </div>
    </div>





            <div class="form-group">
                <label class="col-md-2 control-label">Licence Type</label>
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
%{--                        <div><button type="button" class="btn btn-primary btn-xs">Select All</button> <button type="button" class="btn btn-primary btn-xs">Select Open</button></div>--}%
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
%{--                        <div class="col-md-4">111111</div>--}%

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
        <label class="col-md-2 control-label not_done_yet" for="viceCounty">Vice county</label>
        <div class="col-md-6">
            <input type="text" value="" id="viceCounty" name="viceCounty" class="form-control" size="12">
        </div>
    </div>



%{--    <div class="form-group">--}%
%{--        <label class="col-md-2 control-label" for="species_group">Date</label>--}%
%{--        <div class="col-md-2">--}%
%{--            <div class="radio">--}%
%{--                <label>--}%
%{--                    <input type="radio" name="hmj" value="">--}%
%{--                    Exact Date e.g. 1978/03/26--}%
%{--                </label>--}%
%{--            </div>--}%
%{--        </div>--}%
%{--        <div class="col-md-4">--}%
%{--            <div class="radio">--}%
%{--                <label>--}%
%{--                    <input type="radio" name="hmj" value="" >--}%
%{--                    Year Range e.g 1700-2020--}%
%{--                </label>--}%
%{--            </div>--}%

%{--        </div>--}%

%{--    </div>--}%

    <div class="form-group">
        <label class="col-md-2 control-label" >Date</label>
        <div class="col-md-6 radio">
        <label>
            <input type="radio" name="dateType" value="SPECIFIC_DATE" checked> Year OR month OR year/month/day
        </label>
        </div>
    </div>

    <div class="form-group">
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


    <div class="form-group"  style="margin-top:30px">
        <label class="col-md-2 control-label"></label>
        <div class="col-md-6 radio">
            <label>
                <input type="radio" name="dateType" value="YEAR_RANGE" > Year range
            </label>
        </div>
    </div>

    <div style="height:10px"></div>
    <div class="form-group">
        <label class="col-md-2 control-label">  </label>
        <div class="col-md-6" style="padding-left:30px;padding-right:30px">
            <input type="text" id="slider" class="slider" name="yearRange">
        </div>
    </div>


%{--    <div class="form-group">--}%
%{--        <label class="col-md-2 control-label" for="taxa_${i}">Date</label>--}%
%{--        <div class="col-md-6">--}%
%{--        <div class="input-group date" data-provide="datepicker">--}%
%{--            <input type="text" class="form-control" placeholder="YYYY/MM/DD">--}%
%{--            <div class="input-group-addon">--}%
%{--                <span class="glyphicon glyphicon-calendar"></span>--}%
%{--            </div>--}%
%{--        </div>--}%
%{--        </div>--}%
%{--    </div>--}%

%{--    <div style="height:30px"></div>--}%






    <div class="form-group">
        <label class="col-md-2 control-label" for="annotations">Annotations</label>
        <div class="col-md-6">
            <label class="checkbox-inline">
                <input type="checkbox" id="annotations" name="annotations" value="EXCLUDE_ANNOTATIONS"> Remove records with queries
            </label>

        </div>
    </div>

    <div class="form-group" id="taxon_row_${i}">
        <div class="col-md-2"></div>
        <div class="col-md-6" >
            <div style="float:right">
            <input type="reset" value="Clear all" id="clearAll" class="btn btn-default" onclick="$('input#solrQuery').val(''); $('input.clear_taxon').click(); return true;"/>
            <input type="submit" value=<g:message code="advancedsearch.button.submit" default="Search"/> class="btn btn-primary" />
    </div>

        </div>

        </div>
    </fieldset>
</form>
</div>






