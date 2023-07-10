<%--
  Created by IntelliJ IDEA.
  User: dos009@csiro.au
  Date: 11/02/14
  Time: 10:52 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<g:set var="startPageTime" value="${System.currentTimeMillis()}"/>
<g:set var="queryDisplay" value="${sr?.queryTitle ?: searchRequestParams?.displayString ?: ''}"/>
<g:set var="authService" bean="authService"></g:set>
<g:set var="orgNameShort" value="${grailsApplication.config.skin.orgNameShort}"/>
<!DOCTYPE html>
<html>
<head>
    <meta name="svn.revision" content="${meta(name: 'svn.revision')}"/>
    <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    <meta name="section" content="search"/>
    <meta name="breadcrumbParent" content="${request.contextPath ?: '/'},${message(code: "search.heading.list")}"/>
    <meta name="breadcrumb" content="${message(code: "list.search.results")}"/>
    <title><g:message code="list.title"
                      default="Search"/>: ${sr?.queryTitle?.replaceAll("<(.|\n)*?>", '')} | <alatag:message
            code="search.heading.list" default="Search results"/> | ${grailsApplication.config.skin.orgNameLong}</title>

    <g:if test="${grailsApplication.config.google.apikey}">
        <script src="https://maps.googleapis.com/maps/api/js?key=${grailsApplication.config.google.apikey}"
                type="text/javascript"></script>
    </g:if>

    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
        // single global var for app conf settings
        <g:set var="fqParams" value="${(params.fq) ? "&fq=" + params.list('fq')?.join('&fq=') : ''}"/>
        <g:set var="searchString" value="${raw(sr?.urlParameters).encodeAsURL()}"/>
        <g:set var="biocacheServiceUrl" value="${alatag.getBiocacheAjaxUrl()}"/>
        var BC_CONF = {
            contextPath: "${request.contextPath}",
            serverName: "<g:createLink absolute="true" uri="" />",
            searchString: "${searchString}", //  JSTL var can contain double quotes // .encodeAsJavaScript()
            searchRequestParams: "${searchRequestParams.encodeAsURL()}",
            facetQueries: "${fqParams.encodeAsURL()}",
            facetDownloadQuery: "${searchString}",
            maxFacets: "${grailsApplication.config.facets?.max ?: '4'}",
            queryString: "${queryDisplay.encodeAsJavaScript()}",
            bieWebappUrl: "${grailsApplication.config.bie.baseUrl}",
            bieWebServiceUrl: "${grailsApplication.config.bieService.baseUrl}",
            biocacheServiceUrl: "${biocacheServiceUrl}",
            collectoryUrl: "${grailsApplication.config.collectory.baseUrl}",
            alertsUrl: "${grailsApplication.config.alerts.baseUrl}",
            skin: "${grailsApplication.config.skin.layout}",
            defaultListView: "${grailsApplication.config.defaultListView}",
            resourceName: "${grailsApplication.config.skin.orgNameLong}",
            facetLimit: "${grailsApplication.config.facets.limit ?: 50}",
            queryContext: "${grailsApplication.config.biocache.queryContext}",
            selectedDataResource: "${selectedDataResource}",
            autocompleteHints: ${grailsApplication.config.bie?.autocompleteHints?.encodeAsJson() ?: '{}'},
            zoomOutsideScopedRegion: Boolean("${grailsApplication.config.map.zoomOutsideScopedRegion}"),
            hasMultimedia: ${hasImages ?: 'false'}, // will be either true or false
            locale: "${org.springframework.web.servlet.support.RequestContextUtils.getLocale(request)}",
            imageServiceBaseUrl:"${grailsApplication.config.images.baseUrl}",
            likeUrl: "${createLink(controller: 'imageClient', action: 'likeImage')}",
            dislikeUrl: "${createLink(controller: 'imageClient', action: 'dislikeImage')}",
            userRatingUrl: "${createLink(controller: 'imageClient', action: 'userRating')}",
            disableLikeDislikeButton: ${authService.getUserId() ? false : true},
            addLikeDislikeButton: ${(grailsApplication.config.getProperty("addLikeDislikeButton", Boolean, false))},
            addPreferenceButton: <imageClient:checkAllowableEditRole/> ,
            userRatingHelpText: '<div><b>Up vote (<i class="fa fa-thumbs-o-up" aria-hidden="true"></i>) an image:</b>'+
                ' Image supports the identification of the species or is representative of the species.  Subject is clearly visible including identifying features.<br/><br/>'+
                '<b>Down vote (<i class="fa fa-thumbs-o-down" aria-hidden="true"></i>) an image:</b>'+
                ' Image does not support the identification of the species, subject is unclear and identifying features are difficult to see or not visible.<br/></div>',
            savePreferredSpeciesListUrl: "${createLink(controller: 'imageClient', action: 'saveImageToSpeciesList')}",
            getPreferredSpeciesListUrl:  "${createLink(controller: 'imageClient', action: 'getPreferredSpeciesImageList')}",
            excludeCountUrl: "${createLink(controller: 'occurrence', action: 'dataQualityExcludeCounts', params: params.clone()).encodeAsJavaScript()}",
            expandProfileDetails: false,
            userId: "${userId}",
            prefKey: "${(grailsApplication.config.getProperty("dataquality.prefkey", String, "dqUserProfile"))}",
            expandKey: "${(grailsApplication.config.getProperty("dataquality.expandKey", String, "dqDetailExpand"))}",
            autocompleteUrl: "${grailsApplication.config.skin.useAlaBie?.toBoolean() ? (grailsApplication.config.bieService.baseUrl + '/search/auto.json') : biocacheServiceUrl + '/autocomplete/search'}",
            autocompleteUseBie: ${grailsApplication.config.skin.useAlaBie?.toBoolean()}
        };
    </script>

    <asset:javascript src="biocache-hubs.js"/>
    <asset:javascript src="ala/images-client.js"/>
    <asset:javascript src="leafletPlugins.js"/>
    <asset:javascript src="listThirdParty.js"/>
    <asset:javascript src="search.js"/>
    <asset:javascript src="mapCommon.js"/>
    <asset:javascript src="ala/ala-charts.js"/>

    <asset:stylesheet src="print.css" media="print" />
    <asset:stylesheet src="searchMap.css"/>
    <asset:stylesheet src="search.css"/>
    <asset:stylesheet src="print-search.css" media="print" />
    <asset:stylesheet src="ala/images-client.css"/>
    <asset:stylesheet src="leafletPlugins.css"/>
    <asset:stylesheet src="listThirdParty.css"/>
    <asset:stylesheet src="ala/ala-charts.css"/>
    <asset:stylesheet src="nbn/accessControl.css"/>


    <asset:javascript src="autocomplete.js"/>
    <asset:script type="text/javascript">
%{--        <g:if test="${!grailsApplication.config.google.apikey}">--}%
%{--            google.load('maps','3.5',{ other_params: "sensor=false" });--}%
%{--        </g:if>--}%
        $("a.occurrenceLink").hide()
    </asset:script>

</head>

<body class="occurrence-search-">


<div id="listHeader" class="heading-bar row">
    %{--        <div class="col-sm-5 col-md-5">--}%
    <h1><alatag:message code="acFilter.heading.list" default="Access Control Filter"></alatag:message><a
            name="resultsTop">&nbsp;</a> - ${dataProvider.name} ${filterUser.email} </h1>
    %{--        </div>--}%
    <p>Data provider <b>${dataProvider.name}</b> granting supplied resolution access to <b>${filterUser.email}</b></p>

    <div style="display: flex; justify-content: flex-end; margin-top:1rem; margin-bottom:1rem;">
%{--        <input type="text" style="width: 50%;" class="form-control" placeholder="Description of this access control filter"/>--}%
        %{--                hmj <i class="fas fa-pencil-alt"></i>--}%
        <a href="${grailsApplication.config.collectory.baseUrl}/dataProvider/updateSpecifiedAccess/${dataProvider.uid}?userId=${filterUser.userId}${filterId ? "&filterId=${filterId}":""}${fq.collect { '&fq=' + it.encodeAsURL() }.join()}" role="button" class="btn btn-primary" style="margin-left:1rem;" title="${g.message(code:"list.copylinks.dlg.copybutton.title")}">Save</a>
        <a href="${grailsApplication.config.collectory.baseUrl}/dataProvider/specifyAccess/${params.dpuid}?userId=${params.filterUserId}"  role="button" class="btn btn-danger"  title="cancel" style="margin-left:1rem;">Cancel</a>
        %{--                <input style="width:100%; background-color:#e8e8e8; padding:0.8rem 2rem 0.9rem 2rem;margin-right:1rem;" placeholder="Description of this collection" /> <i style="margin-left:1rem;" class="fa fa-pencil" aria-hidden="true"></i> <a href="#AccessControlSaveLink" data-toggle="modal" role="button" class="tooltips btn copyLink" style="border-color:orange" title="${g.message(code:"list.copylinks.dlg.copybutton.title")}"><i class="fa fa-floppy-o" aria-hidden="true"></i>&nbsp;&nbsp;Save</a> <a href="#"  role="button" class="tooltips btn copyLink"  title="cancel">Cancel</a>--}%
    </div>



    <g:if test="${flash.message}">
        <div id="errorAlert" class="alert alert-danger alert-dismissible alert-dismissable" role="alert">
            <button type="button" class="close" onclick="$(this).parent().hide()" aria-label="Close"><span
                    aria-hidden="true">&times;</span></button>
            <h4><alatag:stripApiKey message="${flash.message}"/></h4>

            <p>Please contact <a
                    href="mailto:${grailsApplication.config.supportEmail ?: 'support@ala.org.au'}?subject=biocache error"
                    style="text-decoration: underline;">support</a> if this error continues</p>
        </div>
    </g:if>
    <g:if test="${errors || sr?.status == "ERROR"}">
        <g:set var="errorMessage" value="${errors ?: sr?.errorMessage}"/>
        <div class="searchInfo searchError">
            <h2 style="padding-left: 10px;"><g:message code="list.01.error" default="Error"/></h2>
            <div class="alert alert-info" role="alert">
                <b>${alatag.stripApiKey(message: errorMessage)}</b>
            </div>
            Please contact <a
                href="mailto:${grailsApplication.config.supportEmail ?: 'support@ala.org.au'}?subject=biocache error">support</a> if this error continues
        </div>
    </g:if>
    <g:elseif test="${!sr || (sr.totalRecords == 0)}">
        <div class="searchInfo searchError">
       <p><g:message code="list.03.p03" default="No records found for"/>
                    <span class="queryDisplay"> ${queryDisplay ?: params.q ?: params.taxa}</span>
                 </p>
        </div>

    </g:elseif>
    <g:else>
        <!--  first row  number of results for query, selected facets etc.  -->
        <div class="clearfix row" id="searchInfoRow">
            <!-- facet column -->
            <div class="col-md-3 col-sm-3">

                &nbsp;

            </div><!-- /.col-md-3 -->


            <!-- Results column -->
            <div class="col-sm-9 col-md-9">


                <div id="resultsReturned">

                    <!-- the number of results  -->
                    <alatag:simpleResultCount totalRecords="${sr.totalRecords}" />
                    <span class="queryDisplay"><strong>
                        <g:set var="queryToShow"><alatag:sanitizeContent>${raw(queryDisplay)}</alatag:sanitizeContent></g:set>
                        ${raw(queryToShow) ?: params.taxa ?: params.q}
                    </strong></span>&nbsp;&nbsp;
                    <g:if test="${params.taxa && queryDisplay.startsWith("text:")}">
                    %{--Fallback taxa search to "text:", so provide feedback to user about this--}%
                        (<g:message code="list.taxa.notfound" args="${[params.taxa]}" default="(Note: no matched taxon name found for {0})"/>)
                    </g:if>
                    <!-- end the number of results  -->

                    <!-- the active filter bar  -->
                    <g:if test="${sr.activeFacetObj?.values()?.any() || params.wkt || params.radius}">
                        <div class="activeFilters col-sm-12">
                            <b><alatag:message code="search.filters.heading" default="User selected filters"/></b>:&nbsp;
                            <g:each var="items" in="${sr.activeFacetObj}">
                                <g:if test="${items.key}">
                                    <g:each var="item" in="${items.value}">
                                        <g:set var="hasFq" value="${true}"/>
                                        <alatag:currentFilterItem key="${items.key}" value="${item}" facetValue="${item.value}" cssClass="btn btn-default btn-xs" cssColor="${UserFQColors != null ? UserFQColors[item.value] : null}" title="${fqInteract != null ? fqInteract[item.value] : null}" addCloseBtn="${true}"/>
                                    </g:each>
                                </g:if>
                            </g:each>

                            <g:if test="${sr.activeFacetObj?.collect { it.value.size() }.sum() > 1 }">
                                <a href="${alatag.createFilterItemLink(facet: 'all')}" class="btn btn-primary activeFilter btn-xs"
                                   title="<g:message code="list.resultsreturned.button01.title"/>"><span
                                        class="closeX">&gt;&nbsp;</span><g:message code="list.resultsreturned.button01"
                                                                                   default="Clear all"/></a>
                            </g:if>
                        </div>
                    </g:if>
                    <!-- end the active filter bar  -->



                </div>
            </div><!-- /.col-md-9 -->
        </div><!-- /#searchInfoRow -->



        <!--  Second row - facet column and results column -->
        <div class="row" id="content">
            <div class="col-sm-3 col-md-3">
                <g:render template="facets"></g:render>
            </div>
            <g:set var="postFacets" value="${System.currentTimeMillis()}"/>
            <div id="content2" class="col-sm-9 col-md-9">

%{--            <div class="tabbable">--}%
%{--                <ul class="nav nav-tabs" data-tabs="tabs">--}%
%{--                    <li class="active"><a ><g:message code="list.link.t1"--}%
%{--                                                                                                   default="Records"/></a>--}%
%{--                    </li>--}%

%{--                </ul>--}%
%{--            </div>--}%

                <div class="tab-content clearfix">
                    <div class="tab-pane solrResults active" id="recordsView">
                        <div id="searchControls" class="row">
                            <div class="col-sm-4 col-md-4">

                            </div>

                            <div id="sortWidgets" class="col-sm-8 col-md-8">
                                <span class="hidden-sm"><g:message code="list.sortwidgets.span01"
                                                                   default="per"/></span>&nbsp;<g:message
                                    code="list.sortwidgets.span02" default="page"/>:
                                <select id="per-page" name="per-page" class="input-small">
                                    <g:set var="pageSizeVar" value="${params.pageSize ?: params.max ?: "20"}"/>
                                    <option value="10" <g:if test="${pageSizeVar == "10"}">selected</g:if>>10</option>
                                    <option value="20" <g:if test="${pageSizeVar == "20"}">selected</g:if>>20</option>
                                    <option value="50" <g:if test="${pageSizeVar == "50"}">selected</g:if>>50</option>
                                    <option value="100" <g:if test="${pageSizeVar == "100"}">selected</g:if>>100</option>
                                </select>&nbsp;
                            <g:message code="list.sortwidgets.sort.label" default="sort"/>:
                                <select id="sort" name="sort" class="input-small">
                                    <option value="score" <g:if test="${params.sort == 'score'}">selected</g:if>><g:message
                                            code="list.sortwidgets.sort.option01" default="Best match"/></option>
                                    <option value="taxon_name"
                                            <g:if test="${params.sort == 'taxon_name'}">selected</g:if>><g:message
                                            code="list.sortwidgets.sort.option02" default="Taxon name"/></option>
                                    <option value="common_name"
                                            <g:if test="${params.sort == 'common_name'}">selected</g:if>><g:message
                                            code="list.sortwidgets.sort.option03" default="Common name"/></option>
                                    <option value="occurrence_date"
                                            <g:if test="${params.sort == 'occurrence_date'}">selected</g:if>>${skin == 'avh' ? g.message(code: "list.sortwidgets.sort.option0401", default: "Collecting date") : g.message(code: "list.sortwidgets.sort.option0402", default: "Record date")}</option>
                                    <g:if test="${skin != 'avh'}">
                                        <option value="record_type"
                                                <g:if test="${params.sort == 'record_type'}">selected</g:if>><g:message
                                                code="list.sortwidgets.sort.option05" default="Record type"/></option>
                                    </g:if>
                                    <option value="first_loaded_date"
                                            <g:if test="${(!params.sort) || params.sort == 'first_loaded_date'}">selected</g:if>><g:message
                                            code="list.sortwidgets.sort.option06" default="Date added"/></option>
                                    <option value="last_assertion_date"
                                            <g:if test="${params.sort == 'last_assertion_date'}">selected</g:if>><g:message
                                            code="list.sortwidgets.sort.option07" default="Last annotated"/></option>
                                </select>&nbsp;
                            <g:message code="list.sortwidgets.dir.label" default="order"/>:
                                <select id="dir" name="dir" class="input-small">
                                    <g:set var="sortOrder" value="${params.dir ?: params.order}"/>
                                    <option value="asc" <g:if test="${sortOrder == 'asc'}">selected</g:if>><g:message
                                            code="list.sortwidgets.dir.option01" default="Ascending"/></option>
                                    <option value="desc"
                                            <g:if test="${!sortOrder || sortOrder == 'desc'}">selected</g:if>><g:message
                                            code="list.sortwidgets.dir.option02" default="Descending"/></option>
                                </select>
                            </div><!-- sortWidget -->
                        </div><!-- searchControls -->
                        <div id="results">
                            <g:set var="startList" value="${System.currentTimeMillis()}"/>
                            <g:each var="occurrence" in="${sr.occurrences}">
                                <alatag:formatListRecordRow occurrence="${occurrence}"/>
                            </g:each>
                        </div><!--close results-->

                        <div id="searchNavBar" class="pagination">
                            <g:paginate total="${sr.totalRecords}" max="${sr.pageSize}" offset="${sr.startIndex}"
                                        next="${message(code: "show.nextbtn.navigator", default:"Next")}"
                                        prev="${message(code: "show.previousbtn.navigator", default:"Previous")}"
                                        omitLast="true"
                                        params="${params.clone().with { it.remove('max'); it.remove('offset'); it } }"
                            />
                        </div>
                    </div><!--end solrResults-->


                </div><!-- end .css-panes -->

            </div>
        </div>
    </g:else>




</body>
</html>
