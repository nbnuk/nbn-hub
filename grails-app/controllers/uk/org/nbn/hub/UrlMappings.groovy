package uk.org.nbn.hub

class UrlMappings {

    static mappings = {
        "/$controller/$action?/$id?(.$format)?"{
            constraints {
                // apply constraints here
            }
        }

        "/demo"(view:"/demo")
        "/"(controller: 'home')
        "/advancedSearch/searchByOccurrenceID"(controller: 'occurrenceSearch', action: 'searchByOccurrenceID')
        "/advancedSearch/searchByOther"(controller: 'occurrenceSearch', action: 'searchByOther')
        "/savedSearch/list"(controller: 'savedSearch', action: 'list')
        "/savedSearch/save"(controller: 'savedSearch', action: 'save', method: 'POST')
        "/accessControl/filterEditor/$dpuid/$filterUserId/$filterId?"(controller: 'accessControl', action: 'filterEditor')
        "500"(view:'/error')
        "404"(view:'/notFound')
    }
}
