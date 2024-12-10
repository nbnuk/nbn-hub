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
        "/occurrences/searchByEventID"(controller: 'occurrenceSearch', action: 'searchByEventID')
        "/occurrences/searchByCollectionCode"(controller: 'occurrenceSearch', action: 'searchByCollectionCode')
        "/advancedSearch/searchByOther"(controller: 'occurrenceSearch', action: 'searchByOther')
        "/accessControl/filterEditor/$dpuid/$filterUserId/$filterId?"(controller: 'accessControl', action: 'filterEditor')
        "500"(view:'/error')
        "404"(view:'/notFound')
    }
}
