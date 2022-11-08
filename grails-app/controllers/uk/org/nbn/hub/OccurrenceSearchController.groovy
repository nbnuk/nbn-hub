package uk.org.nbn.hub

import org.apache.commons.httpclient.util.URIUtil

class OccurrenceSearchController {

    private final String OCCURRENCE_SEARCH="/occurrences/search";

    def searchByOccurrenceID(String occurrenceID) {
        return redirect(controller: 'occurrences', action: 'search', params: [q:"occurrence_id:"+occurrenceID])
    }

    def searchByEventID(String eventID) {
        return redirect(controller: 'occurrences', action: 'search', params: [q:"event_id:"+eventID])
    }

    def searchByCollectionCode(String collectionCode) {
        return redirect(controller: 'occurrences', action: 'search', params: [q:"collection_code:"+collectionCode])
    }

    def searchByOther(AdvancedSearchParams requestParams) {
        Map paramMap = requestParams.toParamMap();
       // paramMap.put("sort","score")
       redirect(controller: "occurrences", action:"search", params: paramMap)

    }

    private String buildOccurrenceIDQuery(String occurrenceID){
        return URIUtil.encodeWithinQuery(occurrenceID?"occurrence_id:"+occurrenceID:"*:*");
    }

    private String buildEventIDQuery(String eventID){
        return URIUtil.encodeWithinQuery(eventID?"event_id:"+eventID:"*:*");
    }

    private String buildCollectionCodeQuery(String collectionCode){
        return URIUtil.encodeWithinQuery(collectionCode?"collection_code:"+collectionCode:"*:*");
    }



}
