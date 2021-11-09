package uk.org.nbn.biocache.hub

import au.org.ala.biocache.hubs.SpatialSearchRequestParams

class OccurrenceController extends au.org.ala.biocache.hubs.OccurrenceController{

    def list(SpatialSearchRequestParams requestParams) {

        def model = super.list(requestParams)
//        render(view: "../errorStatus", model:[errorMessage:"Error: No live SolrServers available to handle this request:[http://172.31.9.81:8983/solr/biocache, http://172.31.15.129:8983/solr/biocache, http://172.31.23.235:8983/solr/biocache]"])
        if (model) {
            if ("ERROR".equals(model.sr.status))
                render(view: "../errorStatus", model:[errorMessage:model.sr.errorMessage])
        }
        return model
    }
}
