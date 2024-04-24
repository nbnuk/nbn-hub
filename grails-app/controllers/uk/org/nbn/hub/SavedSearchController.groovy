package uk.org.nbn.hub

import grails.converters.JSON
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
            response.status = 404
            render([error: 'userId must be supplied to create Saved Searches'] as JSON)
        } else {
            def name = params.name
            def description = params.description
            def searchRequestQueryUI = params.searchRequestQueryUI
            render webServicesService.createSaveSearch(userId, name, description, searchRequestQueryUI) as JSON
        }
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
            response.status = 404
            render([error: 'userId must be supplied to get Saved Searches'] as JSON)
        } else {
            def savedSearches = webServicesService.getSaveSearches(userId)
            render savedSearches as JSON
        }
    }

}
