package uk.org.nbn.biocache.hubs

import au.org.ala.biocache.hubs.SpatialSearchRequestParams
import org.apache.http.HttpStatus
import grails.web.mapping.LinkGenerator
import org.springframework.beans.factory.annotation.Autowired

class OccurrenceController extends au.org.ala.biocache.hubs.OccurrenceController{

    @Autowired
    LinkGenerator linkGenerator

    @Override
    def list(SpatialSearchRequestParams requestParams) {
        String[] fq = params.list("fq") as String[] //what ALA do to override Grails (handles fq=<empty string>)
        String q = params.getOrDefault("q","")
        String defaultFilterExclusionPattern = grailsApplication.config.facets.defaultFiltersQueryExclusionPattern

        if(fq.length == 0 && grailsApplication.config.facets.defaultFilters && !(defaultFilterExclusionPattern != null && q ==~ /$defaultFilterExclusionPattern/)){
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
        requestParams.nbnRequiredFacets = grailsApplication.config.nbnRequiredFacets.split(",")

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

    //NBN method to log map downloads
    def initMapDownload(){
        String userId = authService?.getUserId()

        if (userId == null) {
            log.debug("userId is null")
            return response.sendError(HttpStatus.SC_UNAUTHORIZED)
        } else {
            def postResponse = webServicesService.logMapDownloadEvent(request.remoteAddr, request.getHeader("user-agent"),params.reasonTypeId, params.sourceTypeId, params.searchParams, params.filename)
            render(status: postResponse.statusCode)
        }

    }
}
