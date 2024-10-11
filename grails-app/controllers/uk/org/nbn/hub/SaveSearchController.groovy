package uk.org.nbn.hub

import grails.converters.JSON

class SaveSearchController {

    def webServicesService

    def create(){
        String userId = authService?.getUserId()
        if (userId == null) {
            response.status = 404
            render([error: 'userId must be supplied to get alerts'] as JSON)
        } else {
            def description = params.description
            def searchRequestQueryUI = params.searchRequestQueryUI
            render webServicesService.createSaveSearch(userId, description, searchRequestQueryUI) as JSON
        }
    }
}
