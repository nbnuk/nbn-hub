package uk.org.nbn.biocache.hubs

import au.org.ala.biocache.hubs.SpatialSearchRequestParams
import grails.transaction.Transactional
import groovy.util.logging.Slf4j

@Slf4j
@Transactional
class TimelineService {

    def webServicesService
    def grailsApplication

    /**
     * Get temporal bounds (min/max years) for the current search results
     * @param requestParams The search parameters
     * @return Map containing minYear and maxYear
     */
    Map getTemporalBounds(SpatialSearchRequestParams requestParams) {
        try {
            // Create a new params object to avoid modifying the original
            def tempParams = new SpatialSearchRequestParams()

            // Copy core search parameters but exclude year filters for temporal bounds
            tempParams.q = requestParams.q
            tempParams.qc = requestParams.qc

            // Copy filters but exclude any year-related filters
            if (requestParams.fq) {
                def filteredFqs = []
                def fqList = requestParams.fq instanceof String ? [requestParams.fq] : requestParams.fq
                fqList.each { fq ->
                    if (!fq.toString().toLowerCase().contains('year:')) {
                        filteredFqs.add(fq)
                    }
                }
                if (filteredFqs) {
                    tempParams.fq = filteredFqs.size() == 1 ? filteredFqs[0] : filteredFqs
                }
            }

            // Configure for year facet query - only use valid fields
            tempParams.facet = true
            tempParams.facets = ['year', 'occurrence_year']
            tempParams.flimit = 100  // Limit facet results
            tempParams.pageSize = 0  // Don't need actual records

            log.debug("Temporal bounds query: q=${tempParams.q}, fq=${tempParams.fq}")
            def result = webServicesService.fullTextSearch(tempParams)

                        log.debug("Search result: totalRecords=${result?.totalRecords}")
            // Safe debug logging for facetResults
            if (result?.facetResults instanceof Map) {
                log.debug("Facet results available: ${result.facetResults.keySet()}")
            } else if (result?.facetResults instanceof List) {
                log.debug("Facet results available (List): ${result.facetResults}")
            } else {
                log.debug("Facet results available (Other): ${result?.facetResults?.getClass()?.name} - ${result?.facetResults}")
            }

            def allYears = []
            def yearFields = ['year', 'occurrence_year']

            // The facetResults from records-ws is an array of objects: [{fieldName:..., fieldResult:[...]}]
            if (result?.facetResults instanceof List) {
                yearFields.each { fieldName ->
                    def facetObj = result.facetResults.find { it.fieldName == fieldName }
                    if (facetObj && facetObj.fieldResult instanceof List) {
                        log.debug("${fieldName} facet results: ${facetObj.fieldResult}")
                        facetObj.fieldResult.each { facetResult ->
                            if (facetResult && facetResult.label && facetResult.label.isNumber() && facetResult.count > 0) {
                                allYears << (facetResult.label as Integer)
                                log.debug("Found year from ${fieldName}: ${facetResult.label} (count: ${facetResult.count})")
                            }
                        }
                    }
                }
            } else if (result?.facetResults instanceof Map) {
                // fallback for map structure (legacy or test)
                yearFields.each { fieldName ->
                    if (result.facetResults["${fieldName}"]) {
                        log.debug("${fieldName} facet results: ${result.facetResults["${fieldName}"]}")
                        result.facetResults["${fieldName}"].each { facetResult ->
                            if (facetResult && facetResult.key && facetResult.key.isNumber() && facetResult.count > 0) {
                                allYears << (facetResult.key as Integer)
                                log.debug("Found year from ${fieldName}: ${facetResult.key} (count: ${facetResult.count})")
                            }
                        }
                    }
                }
            }

            if (allYears) {
                def uniqueYears = allYears.unique().sort()
                log.debug("All valid years found: ${uniqueYears}")

                if (uniqueYears.size() >= 2) {
                    def bounds = [
                        minYear: uniqueYears.min(),
                        maxYear: uniqueYears.max(),
                        availableYears: uniqueYears,
                        totalYears: uniqueYears.size()
                    ]
                    log.debug("Returning temporal bounds: ${bounds}")
                    return bounds
                } else {
                    log.debug("Not enough years found: ${uniqueYears.size()}")
                }
            } else {
                log.debug("No year facet results found in any field")
            }

            return [
                minYear: null,
                maxYear: null,
                availableYears: [],
                totalYears: 0
            ]

        } catch (Exception e) {
            log.error("Error fetching temporal bounds", e)
            return [
                minYear: null,
                maxYear: null,
                availableYears: [],
                totalYears: 0,
                error: e.message
            ]
        }
    }

    /**
     * Get temporal distribution data for timeline visualization
     * @param requestParams The search parameters
     * @param granularity The temporal granularity ('year', '5year', 'decade', 'month')
     * @return Map containing temporal distribution data
     */
    Map getTemporalDistribution(SpatialSearchRequestParams requestParams, String granularity = 'yearly') {
        try {
            // Handle month-based timeline differently
            if (granularity == 'month' || granularity == 'monthly') {
                return getMonthlyDistribution(requestParams)
            }

            def bounds = getTemporalBounds(requestParams)
            if (!bounds.minYear || !bounds.maxYear) {
                return [distribution: [], bounds: bounds]
            }

            def tempParams = requestParams.clone()
            tempParams.facet = true
            tempParams.facets = ['year']
            tempParams.flimit = 200
            tempParams.pageSize = 0

            def result = webServicesService.fullTextSearch(tempParams)

            if (result?.facetResults?.year) {
                def yearData = result.facetResults.year.findAll {
                    it.key && it.key.isNumber() && it.count > 0
                }.collectEntries {
                    [(it.key as Integer): it.count as Long]
                }

                def distribution = processTemporalData(yearData, bounds.minYear, bounds.maxYear, granularity)

                return [
                    distribution: distribution,
                    bounds: bounds,
                    granularity: granularity,
                    totalRecords: distribution.sum { it.count }
                ]
            }

            return [
                distribution: [],
                bounds: bounds,
                granularity: granularity,
                totalRecords: 0
            ]

        } catch (Exception e) {
            log.error("Error fetching temporal distribution", e)
            return [
                distribution: [],
                bounds: [:],
                error: e.message
            ]
        }
    }

    /**
     * Get monthly distribution data for seasonal pattern analysis
     * Shows aggregated data for each month across ALL years
     * @param requestParams The search parameters
     * @return Map containing monthly distribution data
     */
    Map getMonthlyDistribution(SpatialSearchRequestParams requestParams) {
        try {
            def tempParams = requestParams.clone()

            // Remove any existing year filters to get data across all years
            if (tempParams.fq) {
                def filteredFqs = []
                def fqList = tempParams.fq instanceof String ? [tempParams.fq] : tempParams.fq
                fqList.each { fq ->
                    if (!fq.toString().toLowerCase().contains('year:') && !fq.toString().toLowerCase().contains('month:')) {
                        filteredFqs.add(fq)
                    }
                }
                if (filteredFqs) {
                    tempParams.fq = filteredFqs.size() == 1 ? filteredFqs[0] : filteredFqs
                } else {
                    tempParams.fq = null
                }
            }

            tempParams.facet = true
            tempParams.facets = ['month'] // Facet by month field
            tempParams.flimit = 12  // Only 12 months
            tempParams.pageSize = 0

            log.debug("Monthly distribution query: q=${tempParams.q}, fq=${tempParams.fq}")
            def result = webServicesService.fullTextSearch(tempParams)

            if (result?.facetResults?.month) {
                def monthData = result.facetResults.month.findAll {
                    it.key && it.key.isNumber() && it.count > 0
                }.collectEntries {
                    [(it.key as Integer): it.count as Long]
                }

                def distribution = processMonthlyData(monthData)

                return [
                    distribution: distribution,
                    granularity: 'month',
                    totalRecords: distribution.sum { it.count ?: 0 },
                    type: 'seasonal'  // Indicates this is seasonal aggregation, not chronological
                ]
            }

            return [
                distribution: [],
                granularity: 'month',
                totalRecords: 0,
                type: 'seasonal'
            ]

        } catch (Exception e) {
            log.error("Error fetching monthly distribution", e)
            return [
                distribution: [],
                granularity: 'month',
                error: e.message,
                type: 'seasonal'
            ]
        }
    }

    /**
     * Process monthly data for seasonal pattern display
     * @param monthData Map of month -> count
     * @return Processed monthly data with month names
     */
    private List processMonthlyData(Map<Integer, Long> monthData) {
        def monthNames = [
            1: 'January', 2: 'February', 3: 'March', 4: 'April',
            5: 'May', 6: 'June', 7: 'July', 8: 'August',
            9: 'September', 10: 'October', 11: 'November', 12: 'December'
        ]

        def distribution = []
        (1..12).each { month ->
            distribution << [
                period: monthNames[month],
                month: month,
                count: monthData[month] ?: 0,
                type: 'month'
            ]
        }

        return distribution
    }

    /**
     * Get occurrence count for a specific temporal period
     * Supports both year-based and month-based filtering
     * @param requestParams The search parameters
     * @param startPeriod The start period (year or month)
     * @param endPeriod The end period (year or month)
     * @param timelineType The type of timeline ('year' or 'month')
     * @return Map containing count and query details
     */
    Map getTemporalOccurrenceCount(SpatialSearchRequestParams requestParams, Integer startPeriod, Integer endPeriod, String timelineType = 'year') {
        try {
            def tempParams = requestParams.clone()

            // Add temporal filter based on timeline type
            def temporalFilter
            if (timelineType == 'month') {
                // Month-based filter: month:[1 TO 1] for January, etc.
                temporalFilter = "month:[${startPeriod} TO ${endPeriod}]"
            } else {
                // Year-based filter: year:[1990 TO 2000]
                temporalFilter = "year:[${startPeriod} TO ${endPeriod}]"
            }

            if (tempParams.fq) {
                tempParams.fq = tempParams.fq + "&${temporalFilter}"
            } else {
                tempParams.fq = temporalFilter
            }

            tempParams.pageSize = 0
            tempParams.facet = false

            def result = webServicesService.fullTextSearch(tempParams)

            return [
                count: result?.totalRecords ?: 0,
                startPeriod: startPeriod,
                endPeriod: endPeriod,
                timelineType: timelineType,
                filter: temporalFilter
            ]

        } catch (Exception e) {
            log.error("Error fetching temporal occurrence count for ${timelineType} ${startPeriod}-${endPeriod}", e)
            return [
                count: 0,
                startPeriod: startPeriod,
                endPeriod: endPeriod,
                timelineType: timelineType,
                error: e.message
            ]
        }
    }



    /**
     * Get month-based occurrence count for seasonal analysis
     * @param requestParams The search parameters
     * @param month The month (1-12)
     * @return Map containing count and query details
     */
    Map getMonthOccurrenceCount(SpatialSearchRequestParams requestParams, Integer month) {
        return getTemporalOccurrenceCount(requestParams, month, month, 'month')
    }

    /**
     * Process temporal data according to granularity
     * @param yearData Map of year -> count
     * @param minYear The start year
     * @param maxYear The end year
     * @param granularity The desired granularity
     * @return Processed temporal data
     */
    private List processTemporalData(Map<Integer, Long> yearData, Integer minYear, Integer maxYear, String granularity) {
        def distribution = []

        switch (granularity) {
            case 'yearly':
                (minYear..maxYear).each { year ->
                    distribution << [
                        period: year.toString(),
                        year: year,
                        count: yearData[year] ?: 0
                    ]
                }
                break

            case '5year':
                def startDecade = (minYear.intdiv(5)) * 5
                def endDecade = (maxYear.intdiv(5)) * 5
                (startDecade..endDecade).step(5) { period ->
                    def periodEnd = period + 4
                    def periodCount = ((period)..(Math.min(periodEnd, maxYear))).sum { year ->
                        yearData[year] ?: 0
                    }
                    distribution << [
                        period: "${period}-${periodEnd}",
                        year: period,
                        count: periodCount
                    ]
                }
                break

            case 'decade':
                def startDecade = (minYear.intdiv(10)) * 10
                def endDecade = (maxYear.intdiv(10)) * 10
                (startDecade..endDecade).step(10) { decade ->
                    def decadeEnd = decade + 9
                    def decadeCount = ((decade)..(Math.min(decadeEnd, maxYear))).sum { year ->
                        yearData[year] ?: 0
                    }
                    distribution << [
                        period: "${decade}s",
                        year: decade,
                        count: decadeCount
                    ]
                }
                break

            default:
                // Default to yearly
                (minYear..maxYear).each { year ->
                    distribution << [
                        period: year.toString(),
                        year: year,
                        count: yearData[year] ?: 0
                    ]
                }
        }

        return distribution
    }

    /**
     * Check if the search results have sufficient temporal data for timeline
     * @param requestParams The search parameters
     * @return Boolean indicating if timeline should be available
     */
    boolean hasTimelineData(SpatialSearchRequestParams requestParams) {
        try {
            def bounds = getTemporalBounds(requestParams)
            return bounds.totalYears >= 2
        } catch (Exception e) {
            log.error("Error checking timeline data availability", e)
            return false
        }
    }


}
