package uk.org.nbn.biocache.hub

class OccurrenceSearchController {

    def searchByOccurrenceID(String occurrenceID) {
        // forward to plugin
        return redirect(controller: 'occurrences', action: 'search', params: [q:"occurrence_id:"+occurrenceID])
    }

    def searchByEventID(String eventID) {System.out.println("---------------eventID"+eventID)
        // forward to plugin
        return redirect(controller: 'occurrences', action: 'search', params: [q:"event_id:"+eventID])
    }

    def searchByCollectionCode(String collectionCode) {
        // forward to plugin
        return redirect(controller: 'occurrences', action: 'search', params: [q:"collection_code:"+collectionCode])
    }

    def searchByOther(AdvancedSearchParams requestParams) {
        // forward to plugin
        redirect(controller: "occurrences", action:"search", params: requestParams.toParamMap())

    }

}
