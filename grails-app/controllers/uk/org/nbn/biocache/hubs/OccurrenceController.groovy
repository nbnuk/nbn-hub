package uk.org.nbn.biocache.hubs

import au.org.ala.biocache.hubs.SpatialSearchRequestParams
import org.grails.web.json.JSONObject

class OccurrenceController extends au.org.ala.biocache.hubs.OccurrenceController{

    @Override
    def list(SpatialSearchRequestParams requestParams) {

        if(requestParams.fq.length == 0 && grailsApplication.config.facets.defaultFilters){
//            requestParams.fq = grailsApplication.config.facets.defaultFilters.toString().split(',')
//            requestParams.fq = ['occurrence_status:"present"', '-user_assertions:(50001 OR 50005 OR 50006)']
            params.put('fq',grailsApplication.config.facets.defaultFilters.toString().split(','));
            return redirect(action: 'list', params: params)
        }

        if (!params.sort) {
            requestParams.sort = "occurrence_date"
        }

        if (!params.dir) {
            requestParams.dir = "desc"
        }

        //these are for the Overview tab:
        requestParams.nbnRequiredFacets = ["identification_verification_status", "occurrence_status", "basis_of_record", "license"] as String[]

        return super.list(requestParams)

    }

    @Override
    def show(String id) {
        def res = super.show(id)
        res.taxon = null
        if (res.record.processed.classification.taxonConceptID) {
            res.taxon = webServicesService.getTaxon(res.record.processed.classification.taxonConceptID)
        }
        res.showFlaggedIssues = (grailsApplication.config.flagAnIssue?.show?: 'false').toBoolean()
        return res;
    }
}
