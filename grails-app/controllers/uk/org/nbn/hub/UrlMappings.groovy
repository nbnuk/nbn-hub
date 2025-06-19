package uk.org.nbn.hub

class UrlMappings {

    static mappings = {
        "/$controller/$action?/$id?(.$format)?"{
            constraints {
                // apply constraints here
            }
        }


        "/"(controller: 'home')
        "/advancedSearch/searchByOccurrenceID"(controller: 'occurrenceSearch', action: 'searchByOccurrenceID')
        "/advancedSearch/searchByOther"(controller: 'occurrenceSearch', action: 'searchByOther')
        "/savedSearch/list"(controller: 'savedSearch', action: 'list')
        "/savedSearch/save"(controller: 'savedSearch', action: 'save', method: 'POST')
        "/accessControl/filterEditor/$dpuid/$filterUserId/$filterId?"(controller: 'accessControl', action: 'filterEditor')

        // Timeline endpoints
        "/occurrence/timelineBounds"(controller: 'occurrence', action: 'timelineBounds')
        "/occurrence/timelineDistribution"(controller: 'occurrence', action: 'timelineDistribution')
        "/occurrence/timelineCount"(controller: 'occurrence', action: 'timelineCount')
        "/occurrence/timelineConfig"(controller: 'occurrence', action: 'timelineConfig')

        // Month-based timeline endpoints
        "/occurrence/monthlyCount"(controller: 'occurrence', action: 'monthlyCount')

        // EasyMap URLs - NBN Atlas compatible
        "/EasyMap"(controller: 'easyMap', action: 'easyMap')
        "/EasyMap.json"(controller: 'easyMap', action: 'easyMapJson')
        "/easymap/health"(controller: 'easyMap', action: 'health')

        "500"(view:'/error')
        "404"(view:'/notFound')
    }
}
