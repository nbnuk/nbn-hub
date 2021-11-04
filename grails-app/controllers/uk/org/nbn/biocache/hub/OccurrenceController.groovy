package uk.org.nbn.biocache.hub

import au.org.ala.biocache.hubs.SpatialSearchRequestParams

class OccurrenceController extends au.org.ala.biocache.hubs.OccurrenceController{

    def list(SpatialSearchRequestParams requestParams) {

        def model = super.list(requestParams)
        if (model) {
            if ("ERROR".equals(model.sr.status))
                render(view: "../errorStatus", model:[errorMessage:model.sr.errorMessage])
//            else
//                render(view: "list", model: model)
        }
        return model
//        render(view: "../error")
//        return view;
    }
}
