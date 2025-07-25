package uk.org.nbn.biocache.hubs

import au.org.ala.biocache.hubs.SearchRequestParams
import au.org.ala.biocache.hubs.SpatialSearchRequestParams
import grails.plugin.cache.Cacheable
import grails.transaction.Transactional
import org.grails.web.json.JSONArray
import org.grails.web.json.JSONObject

@Transactional
class WebServicesService extends au.org.ala.biocache.hubs.WebServicesService{

    @Override
    def JSONObject fullTextSearch(SpatialSearchRequestParams requestParams) {
        populateProfile(requestParams)
        if (requestParams.nbnRequiredFacets){
            def facetsAsList = requestParams.facets as List
            def requiredFacetsAsList = requestParams.nbnRequiredFacets as List
            requestParams.facets = (facetsAsList + requiredFacetsAsList).unique()
        }
        def url = "${grailsApplication.config.biocache.baseUrl}/occurrences/search?${requestParams.getEncodedParams()}"
        getJsonElements(url)
    }

    def JSONObject getTaxon(String guid) {
        def url = "${grailsApplication.config.bieService.baseUrl}/species/${guid}"
        getJsonElements(url)
    }

    def JSONObject apiTextSearch(SearchRequestParams requestParams) {
        def url = "${grailsApplication.config.biocache.baseUrl}/occurrences/search?${requestParams.getEncodedParams()}"
        getJsonElements(url)
    }

//    @Cacheable('collectoryCache')
    def JSONObject getDataProvider(String uid) {
        def url = "${grailsApplication.config.collections.baseUrl}/ws/dataProvider/${uid}"
        getJsonElements(url)
    }

    def JSONObject getAccessControlFilter(String filterId) {
        def url = "${grailsApplication.config.collections.baseUrl}/ws/accessControl/accessFilter/${filterId}"
        getJsonElements(url)
    }

    def createSaveSearch(userId, name, description, searchRequestQueryUI){

        Map postBody = [
                userId   : userId,
                name: name,
                description: description,
                searchRequestQueryUI : searchRequestQueryUI,
                apiKey: grailsApplication.config.biocache.apiKey
        ]
        postFormData(grailsApplication.config.alerts.baseUrl + "/api/savedSearch/save", postBody, grailsApplication.config.alerts.apiKey as String)
    }

    def getSaveSearches(String userId) {
        def url = "${grailsApplication.config.alerts.baseUrl}" + "/api/savedSearch/list/" + userId
        getJsonElements(url, "${grailsApplication.config.alerts.apiKey}")
    }

     // @Cacheable('collectoryCache')
    def JSONObject getDataresource(String id) {
        def url = "${grailsApplication.config.collections.baseUrl}/ws/dataResource/" + id
        getJsonElements(url)
    }
}
