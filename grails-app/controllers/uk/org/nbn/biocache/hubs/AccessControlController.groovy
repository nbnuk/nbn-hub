package uk.org.nbn.biocache.hubs

import au.org.ala.biocache.hubs.SearchRequestParams
import org.grails.web.json.JSONObject
import uk.org.nbn.hub.FilterEditorCommand

import static au.org.ala.biocache.hubs.TimingUtils.time

class AccessControlController {
    def webServicesService, postProcessingService, authService, userService


    def filterEditor(FilterEditorCommand command) {
        SearchRequestParams requestParams = new SearchRequestParams();

        requestParams.qc="data_provider_uid:"+params.dpuid

        Map facetMap = ["Taxon": ["taxon_name"], "Attribution": ["data_resource_uid"], "Occurrence": ["year"], "Location": ["cl256","cl28"], "Sensitive": ["sensitive"]]
        requestParams.facets = ["data_resource_uid", "taxon_name", "year", "cl256", "cl28", "sensitive"]


        command.fq ? requestParams.fq = command.fq : null
        requestParams.q = "*:*"
        command.offset ? requestParams.offset = command.offset : null
        command.max ? requestParams.max = command.max : null
        command.sort ? requestParams.sort = command.sort : null

        JSONObject searchResults = time("full text search") { webServicesService.apiTextSearch(requestParams) }

        // If there's an error, treat it as an exception so error page can be shown
        if (searchResults.errorType) {
            throw new Exception(searchResults.message)
        }

        //create a facet lookup map
        Map groupedFacetsMap = postProcessingService.getMapOfFacetResults(searchResults.facetResults)

        //grouped facets
        Map groupedFacets = postProcessingService.getAllGroupedFacets(facetMap, searchResults.facetResults, [])


        //remove qc from active facet map
        if (requestParams?.qc) {
            if (searchResults?.activeFacetMap) {
                def remove = null
                searchResults?.activeFacetMap.each { k, v ->
                    if (k + ':' + v?.value == requestParams.qc) {
                        remove = k
                    }
                }
                if (remove) searchResults?.activeFacetMap?.remove(remove)
            }

            if (searchResults?.activeFacetObj) {
                def removeKey = null
                def removeIdx = null
                searchResults?.activeFacetObj.each { k, v ->
                    def idx = v.findIndexOf { it.value == requestParams.qc }
                    if (idx > -1) {
                        removeKey = k
                        removeIdx = idx
                    }
                }
                if (removeKey && removeIdx != null) {
                    searchResults.activeFacetObj[removeKey].remove(removeIdx)
                }
            }

        }

        def dataProvider =  webServicesService.getDataProvider(params.dpuid)
        def filterUser = userService.detailsForUserId(params.filterUserId)

        def resultData =
                [
                        sr                 : searchResults,
                        searchRequestParams: requestParams,
//                            defaultFacets       : defaultFacets, //NO
                        groupedFacets      : groupedFacets, //YES
                        groupedFacetsMap   : groupedFacetsMap, ///YES
//                            dynamicFacets       : dynamicFacets,//NO
                        //  selectedDataResource: getSelectedResource(requestParams.q), //DECLARED BUT NOT USED

                        sort               : requestParams.sort,
                        dir                : requestParams.dir,
                        userId             : authService?.getUserId(),
                        userEmail          : authService?.getEmail(),
                        dataProvider :  webServicesService.getDataProvider(params.dpuid),
                        filterUser : (userService.detailsForUserId(params.filterUserId)<<["userId":params.filterUserId]),
                        filterId : params.filterId,
                        fq : command.fq,

                ]
    }



}
