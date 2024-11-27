package uk.org.nbn.hub

import grails.converters.JSON
import org.apache.http.HttpStatus
import uk.org.nbn.biocache.hubs.WebServicesService

/**
 * Controller for managing saved searches.
 */
class SavedSearchController {

    def authService
    def webServicesService

    def save(){
        String userId = authService?.getUserId()

        if (userId == null) {
            log.debug("userId is null")
            return response.sendError(HttpStatus.SC_UNAUTHORIZED)
        } else {
            def name = params.name
            def description = params.description
            def searchRequestQueryUI = cleanUpURL(params.searchRequestQueryUI)
            render webServicesService.createSaveSearch(userId, name, description, searchRequestQueryUI) as JSON
        }
    }

    private cleanUpURL(url){
        if (!url) {
            return url
        }

        def resultUrl = url;

        resultUrl = resultUrl.replace('?nbn_loading=true&', '?')
        resultUrl = resultUrl.replace('?nbn_loading=true', '')
        resultUrl = resultUrl.replace('&nbn_loading=true', '')

        //add fq if missing
        if (resultUrl && !resultUrl.contains('?fq=') && !resultUrl.contains('&fq=')) {
            // Determine whether to add `?` or `&` based on the URL
            if (url.contains('?')) {
                resultUrl = resultUrl += '&fq='
            } else {
                resultUrl = resultUrl += '?fq='
            }
        }
        return resultUrl;
    }

    /**
     * List all saved searches for the current user
     * /savedSearch/list
     * The method requires that the user is logged on, so that must be enforced
     * eg by using annotation or however else the application enforces authentication
     */
    def list() {

        String userId = authService?.getUserId()
        if (userId == null) {
            log.debug("userId is null")
            return response.sendError(HttpStatus.SC_UNAUTHORIZED)
        } else {
            def savedSearches = webServicesService.getSaveSearches(userId)
            render savedSearches as JSON
        }
    }

}
