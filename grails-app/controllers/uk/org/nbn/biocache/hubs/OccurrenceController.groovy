package uk.org.nbn.biocache.hubs

import au.org.ala.biocache.hubs.SpatialSearchRequestParams
import org.grails.web.json.JSONObject
import grails.converters.JSON

class OccurrenceController extends au.org.ala.biocache.hubs.OccurrenceController{

    def timelineService

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

    /**
     * AJAX endpoint to get temporal bounds for timeline initialization
     */
    def timelineBounds(SpatialSearchRequestParams requestParams) {
        try {
            def bounds = timelineService.getTemporalBounds(requestParams)
            def hasTemporalData = (bounds.totalYears >= 2)

            def response = [
                success: hasTemporalData,
                minYear: bounds.minYear,
                maxYear: bounds.maxYear,
                totalYears: bounds.totalYears,
                hasTemporalData: hasTemporalData
            ]

            if (bounds.error) {
                response.error = bounds.error
            }

            render(contentType: 'application/json', text: response as grails.converters.JSON)
        } catch (Exception e) {
            log.error("Error getting timeline bounds: ${e.message}", e)
            def response = [
                success: false,
                error: e.message,
                hasTemporalData: false
            ]
            render(contentType: 'application/json', text: response as grails.converters.JSON)
        }
    }

    /**
     * AJAX endpoint to get temporal distribution data
     */
    def timelineDistribution(SpatialSearchRequestParams requestParams) {
        try {
            def granularity = params.granularity ?: 'yearly'
            def distribution = timelineService.getTemporalDistribution(requestParams, granularity)

            def response = [
                success: (distribution.distribution?.size() > 0),
                granularity: distribution.granularity,
                data: distribution.distribution,
                totalRecords: distribution.totalRecords ?: 0
            ]

            if (distribution.error) {
                response.error = distribution.error
            }

            render(contentType: 'application/json', text: response as grails.converters.JSON)
        } catch (Exception e) {
            log.error("Error getting timeline distribution: ${e.message}", e)
            def response = [
                success: false,
                error: e.message
            ]
            render(contentType: 'application/json', text: response as grails.converters.JSON)
        }
    }

    /**
     * AJAX endpoint to get occurrence count for specific temporal period
     */
    def timelineCount(SpatialSearchRequestParams requestParams) {
        try {
            def startYear = params.startYear ? Integer.parseInt(params.startYear) : null
            def endYear = params.endYear ? Integer.parseInt(params.endYear) : null

            if (!startYear || !endYear) {
                def response = [
                    success: false,
                    error: "startYear and endYear parameters are required"
                ]
                render(contentType: 'application/json', text: response as grails.converters.JSON)
                return
            }

            def result = timelineService.getTemporalOccurrenceCount(requestParams, startYear, endYear)

            def response = [
                success: (result.count != null),
                startYear: result.startYear,
                endYear: result.endYear,
                count: result.count ?: 0,
                period: "${result.startYear}-${result.endYear}"
            ]

            if (result.error) {
                response.error = result.error
            }

            render(contentType: 'application/json', text: response as grails.converters.JSON)
        } catch (Exception e) {
            log.error("Error getting timeline count: ${e.message}", e)
            def response = [
                success: false,
                error: e.message
            ]
            render(contentType: 'application/json', text: response as grails.converters.JSON)
        }
    }
}
