package au.org.ala.hub

class UrlMappings {

    static mappings = {
        "/$controller/$action?/$id?(.$format)?"{
            constraints {
                // apply constraints here
            }
        }

//        "/occurrenceSearch"(controller: 'occurrenceSearch')

        "/"(controller: 'home')
        "/occurrences/searchByOccurrenceID"(controller: 'occurrenceSearch', action: 'searchByOccurrenceID')
        "/occurrences/searchByEventID"(controller: 'occurrenceSearch', action: 'searchByEventID')
        "/occurrences/searchByCollectionCode"(controller: 'occurrenceSearch', action: 'searchByCollectionCode')
        "/occurrences/searchByOther"(controller: 'occurrenceSearch', action: 'searchByOther')
        "/occurrences/search"(controller: 'occurrence', action: 'list', destination:'occurrence')
        "/occurrence/search"(controller: 'occurrence', action: 'list', destination:'occurrence')
        "500"(view:'/error')
        "404"(view:'/notFound')
    }
}
