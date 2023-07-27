package uk.org.nbn.biocache.hubs

import au.org.ala.biocache.hubs.SpatialSearchRequestParams
import grails.transaction.Transactional
import org.grails.web.json.JSONObject

@Transactional
class WebServicesService extends au.org.ala.biocache.hubs.WebServicesService{

    @Override
    def JSONObject fullTextSearch(SpatialSearchRequestParams requestParams) {
        populateProfile(requestParams)
        if (requestParams.nbnRequiredFacets){
            def facetsAsList = requestParams.facets as List
            def requiredFacetsAsList = requestParams.nbnRequiredFacets as List
            requestParams.facets = (facetsAsList << requiredFacetsAsList).flatten()
        }
        def url = "${grailsApplication.config.biocache.baseUrl}/occurrences/search?${requestParams.getEncodedParams()}"
        getJsonElements(url)
    }

    def JSONObject getTaxon(String guid) {
        def url = "${grailsApplication.config.bieService.baseUrl}/species/${guid}"
        getJsonElements(url)
    }
}
