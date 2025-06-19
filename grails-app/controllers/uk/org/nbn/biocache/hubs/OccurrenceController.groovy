package uk.org.nbn.biocache.hubs

import au.org.ala.biocache.hubs.SpatialSearchRequestParams
import org.grails.web.json.JSONObject
import grails.converters.JSON

class OccurrenceController extends au.org.ala.biocache.hubs.OccurrenceController{

    def timelineService
    def timelineConfigService

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

            // Add seasonal type indicator for month-based timelines
            if (distribution.type) {
                response.type = distribution.type
            }

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
     * AJAX endpoint to get timeline configuration
     */
    def timelineConfig() {
        try {
            def config = timelineConfigService.getConfigAsJson()
            render(contentType: 'application/json', text: config)
        } catch (Exception e) {
            log.error("Error getting timeline configuration: ${e.message}", e)
            def response = [
                success: false,
                error: e.message
            ]
            render(contentType: 'application/json', text: response as grails.converters.JSON)
        }
    }

    /**
     * AJAX endpoint to get occurrence count for specific temporal period
     * Supports both year-based and month-based queries
     */
    def timelineCount(SpatialSearchRequestParams requestParams) {
        try {
            def timelineType = params.timelineType ?: 'year'
            def startPeriod = params.startPeriod ? Integer.parseInt(params.startPeriod) : null
            def endPeriod = params.endPeriod ? Integer.parseInt(params.endPeriod) : null

            // Legacy support for year-based queries
            if (!startPeriod && params.startYear) {
                startPeriod = Integer.parseInt(params.startYear)
                timelineType = 'year'
            }
            if (!endPeriod && params.endYear) {
                endPeriod = Integer.parseInt(params.endYear)
                timelineType = 'year'
            }

            if (!startPeriod || !endPeriod) {
                def response = [
                    success: false,
                    error: "startPeriod and endPeriod parameters are required"
                ]
                render(contentType: 'application/json', text: response as grails.converters.JSON)
                return
            }

            def result = timelineService.getTemporalOccurrenceCount(requestParams, startPeriod, endPeriod, timelineType)

            def response = [
                success: (result.count != null),
                startPeriod: result.startPeriod,
                endPeriod: result.endPeriod,
                timelineType: result.timelineType,
                count: result.count ?: 0,
                period: timelineType == 'month' ? getMonthName(result.startPeriod) : "${result.startPeriod}-${result.endPeriod}"
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

    /**
     * AJAX endpoint to get month-based occurrence count for seasonal analysis
     */
    def monthlyCount(SpatialSearchRequestParams requestParams) {
        try {
            def month = params.month ? Integer.parseInt(params.month) : null

            if (!month || month < 1 || month > 12) {
                def response = [
                    success: false,
                    error: "Valid month parameter (1-12) is required"
                ]
                render(contentType: 'application/json', text: response as grails.converters.JSON)
                return
            }

            def result = timelineService.getMonthOccurrenceCount(requestParams, month)

            def response = [
                success: (result.count != null),
                month: month,
                monthName: getMonthName(month),
                count: result.count ?: 0,
                filter: result.filter,
                type: 'seasonal'
            ]

            if (result.error) {
                response.error = result.error
            }

            render(contentType: 'application/json', text: response as grails.converters.JSON)
        } catch (Exception e) {
            log.error("Error getting monthly count: ${e.message}", e)
            def response = [
                success: false,
                error: e.message
            ]
            render(contentType: 'application/json', text: response as grails.converters.JSON)
        }
    }

    /**
     * Helper method to get month name from month number
     */
    private String getMonthName(Integer month) {
        def monthNames = [
            1: 'January', 2: 'February', 3: 'March', 4: 'April',
            5: 'May', 6: 'June', 7: 'July', 8: 'August',
            9: 'September', 10: 'October', 11: 'November', 12: 'December'
        ]
        return monthNames[month] ?: "Month ${month}"
    }
}
