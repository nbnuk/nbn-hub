package uk.org.nbn.biocache.hubs

import au.org.ala.biocache.hubs.SearchRequestParams
import au.org.ala.biocache.hubs.SpatialSearchRequestParams
import grails.plugin.cache.Cacheable
import grails.transaction.Transactional
import org.apache.commons.lang.StringUtils
import org.springframework.transaction.annotation.Propagation
import groovyx.net.http.ContentType
import groovyx.net.http.HTTPBuilder
import groovyx.net.http.Method
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
//        def url = "${grailsApplication.config.biocache.baseUrl}/occurrences/search?${requestParams.getEncodedParams()}"
        def url = "${grailsApplication.config.biocache.baseUrl}/accessControl/filterEditorOccurrenceSearch?${requestParams.getEncodedParams()}"
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


    //nbn method
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    def logMapDownloadEvent(ip, userAgent, reasonTypeId, sourceTypeId, searchParams, filename ){

        Map postBody = [
                fileType   : "map",
                ip: ip,
                reasonTypeId: reasonTypeId,
                sourceTypeId: sourceTypeId,
                file: filename,
                userAgent: userAgent,
                apiKey: grailsApplication.config.biocache.apiKey
        ]

        if (searchParams) {
            def params = StringUtils.removeStart(searchParams, "?").split("&")
            params.each { p ->
                def kv = p.split("=")
                if (kv.length == 2) {
                    postBody[kv[0]] = kv[1]
                }
            }
        }


        _postFormDataTakenFromALAFutureUpgrade(grailsApplication.config.biocache.baseUrl + "/mapping/logMapDownloadEvent", postBody, false, true)
        //When we upgrade, it looks like we will swap above method call with the following new impl of postFormData (see comment on that method for more details)
        //def Map postFormData(grailsApplication.config.biocache.baseUrl + "/mapping/logMapDownloadEvent", postBody, false, true)

    }


    /**
     * @param uri
     * @param postParams
     * @param wsAuth true to include the service's API Key in the request headers (uses property 'service.apiKey').  If using JWTs, instead sends a JWT Bearer tokens Default = false
     * @param includeUser true to include the userId and email in the request headers and the ALA-Auth cookie.  If using JWTs sends the current user's access token, if false only sends a ClientCredentials grant token for this apps client id Default = false.
     * @return postResponse (Map with keys: statusCode (int) and statusMsg (String)
     * NB: This method is taken from an ALA version of biocache-hubs (WebServicesService.postFormData) that we will
     * at some point be upgrading to. The method signature is the same but the implementation is different because
     * the upgrade version uses a version of ala-ws-plugin that is not in this version of biocache-hubs
     */
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    private def Map _postFormDataTakenFromALAFutureUpgrade(String uri, Map postParams,  Boolean wsAuth = false, Boolean includeUser = false  ) {
        HTTPBuilder http = new HTTPBuilder(uri)
        log.debug "POST (form encoded) to ${http.uri}"
        Map postResponse = [:]

        if (includeUser){
            def userId = authService?.getUserId()
            def email = authService?.getEmail()
            if (userId){
                http.headers.'X-ALA-userId' = userId
            }

        }

        http.headers.'apiKey' = grailsApplication.config.biocache.apiKey

        http.request(Method.POST) { req ->

            send ContentType.URLENC, postParams

            response.success = { resp ->

                log.debug "POST - response status: ${resp.statusLine}"
                postResponse.statusCode = resp.statusLine.statusCode
                postResponse.statusMsg = resp.statusLine.reasonPhrase
            }

            response.failure = { resp ->

                postResponse.statusCode = resp.statusLine.statusCode
                postResponse.statusMsg = resp.statusLine.reasonPhrase
                log.error "POST - Unexpected error: ${postResponse.statusCode} : ${postResponse.statusMsg}"
            }
        }

        return postResponse
    }
}
