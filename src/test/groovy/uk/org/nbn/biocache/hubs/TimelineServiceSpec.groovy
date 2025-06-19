package uk.org.nbn.biocache.hubs

import au.org.ala.biocache.hubs.SpatialSearchRequestParams
import grails.testing.services.ServiceUnitTest
import spock.lang.Specification

class TimelineServiceSpec extends Specification implements ServiceUnitTest<TimelineService> {

    def webServicesService = Mock()

    void "test getTemporalBounds with valid temporal data"() {
        given: "A search request and mock response with temporal data"
        service.webServicesService = webServicesService
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "lsid:NHMSYS0000503827"

        def mockResponse = [
            facetResults: [
                [
                    fieldName: 'year',
                    fieldResult: [
                        [label: '1990', count: 100],
                        [label: '2000', count: 200],
                        [label: '2010', count: 150],
                        [label: '2020', count: 300]
                    ]
                ]
            ]
        ]

        when: "Getting temporal bounds"
        webServicesService.fullTextSearch(_) >> mockResponse
        def result = service.getTemporalBounds(requestParams)

        then: "Returns correct bounds"
        result.hasTemporalData == true
        result.minYear == 1990
        result.maxYear == 2020
        result.totalYears == 4
    }

    void "test getTemporalBounds with no temporal data"() {
        given: "A search request with no temporal data"
        service.webServicesService = webServicesService
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "genus:Homo"

        def mockResponse = [
            facetResults: []
        ]

        when: "Getting temporal bounds"
        webServicesService.fullTextSearch(_) >> mockResponse
        def result = service.getTemporalBounds(requestParams)

        then: "Returns no temporal data"
        result.hasTemporalData == false
        result.minYear == null
        result.maxYear == null
        result.totalYears == 0
    }

    void "test getTemporalDistribution with yearly granularity"() {
        given: "A search request and mock response"
        service.webServicesService = webServicesService
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "lsid:NHMSYS0000503827"

        def mockResponse = [
            facetResults: [
                [
                    fieldName: 'year',
                    fieldResult: [
                        [label: '1990', count: 100],
                        [label: '1991', count: 120],
                        [label: '1992', count: 80]
                    ]
                ]
            ],
            totalRecords: 300
        ]

        when: "Getting temporal distribution"
        webServicesService.fullTextSearch(_) >> mockResponse
        def result = service.getTemporalDistribution(requestParams, 'year')

        then: "Returns correct distribution"
        result.success == true
        result.granularity == 'year'
        result.data[1990] == 100
        result.data[1991] == 120
        result.data[1992] == 80
        result.totalRecords == 300
    }

    void "test getTemporalDistribution with decade granularity"() {
        given: "A search request and mock response"
        service.webServicesService = webServicesService
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "lsid:NHMSYS0000503827"

        def mockResponse = [
            facetResults: [
                [
                    fieldName: 'year',
                    fieldResult: [
                        [label: '1990', count: 100],
                        [label: '1995', count: 120],
                        [label: '2005', count: 80],
                        [label: '2010', count: 150]
                    ]
                ]
            ],
            totalRecords: 450
        ]

        when: "Getting temporal distribution with decade granularity"
        webServicesService.fullTextSearch(_) >> mockResponse
        def result = service.getTemporalDistribution(requestParams, 'decade')

        then: "Returns correct decade aggregation"
        result.success == true
        result.granularity == 'decade'
        result.data['1990s'] == 220  // 1990 + 1995
        result.data['2000s'] == 230  // 2005 + 2010
    }

    void "test getTemporalOccurrenceCount"() {
        given: "A search request and mock response"
        service.webServicesService = webServicesService
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "lsid:NHMSYS0000503827"

        def mockResponse = [
            totalRecords: 500
        ]

        when: "Getting temporal occurrence count"
        webServicesService.fullTextSearch(_) >> mockResponse
        def result = service.getTemporalOccurrenceCount(requestParams, 1990, 2000)

        then: "Returns correct count"
        result.success == true
        result.startYear == 1990
        result.endYear == 2000
        result.count == 500
        result.period == "1990-2000"
    }

    void "test hasTimelineData returns true for sufficient temporal data"() {
        given: "A search request with temporal data"
        service.webServicesService = webServicesService
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "lsid:NHMSYS0000503827"

        def mockResponse = [
            facetResults: [
                [
                    fieldName: 'year',
                    fieldResult: [
                        [label: '1990', count: 100],
                        [label: '2000', count: 200]
                    ]
                ]
            ]
        ]

        when: "Checking if timeline data is available"
        webServicesService.fullTextSearch(_) >> mockResponse
        def result = service.hasTimelineData(requestParams)

        then: "Returns true for sufficient data"
        result == true
    }

    void "test hasTimelineData returns false for insufficient temporal data"() {
        given: "A search request with only one year of data"
        service.webServicesService = webServicesService
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "lsid:NHMSYS0000503827"

        def mockResponse = [
            facetResults: [
                [
                    fieldName: 'year',
                    fieldResult: [
                        [label: '1990', count: 100]
                    ]
                ]
            ]
        ]

        when: "Checking if timeline data is available"
        webServicesService.fullTextSearch(_) >> mockResponse
        def result = service.hasTimelineData(requestParams)

        then: "Returns false for insufficient data"
        result == false
    }

    void "test processTemporalData with 5-year granularity"() {
        given: "Yearly data"
        def yearData = [
            1990: 100,
            1992: 120,
            1995: 80,
            1997: 90,
            2000: 150,
            2003: 200
        ]

        when: "Processing with 5-year granularity"
        def result = service.processTemporalData(yearData, '5year')

        then: "Returns correct 5-year periods"
        result['1990-1994'] == 220  // 1990 + 1992
        result['1995-1999'] == 170  // 1995 + 1997
        result['2000-2004'] == 350  // 2000 + 2003
    }

    void "test getMonthlyDistribution returns seasonal data for all months"() {
        given: "A search request for monthly distribution"
        service.webServicesService = webServicesService
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "lsid:NHMSYS0000503827"

        def mockResponse = [
            facetResults: [
                month: [
                    [key: '1', count: 150], // January
                    [key: '3', count: 200], // March
                    [key: '6', count: 300], // June
                    [key: '12', count: 100] // December
                ]
            ]
        ]

        when: "Getting monthly distribution"
        webServicesService.fullTextSearch(_) >> mockResponse
        def result = service.getMonthlyDistribution(requestParams)

        then: "Returns seasonal distribution for all 12 months"
        result.distribution.size() == 12
        result.granularity == 'month'
        result.type == 'seasonal'
        result.distribution[0].period == 'January'
        result.distribution[0].count == 150
        result.distribution[2].period == 'March'
        result.distribution[2].count == 200
        result.distribution[5].period == 'June'
        result.distribution[5].count == 300
        result.distribution[11].period == 'December'
        result.distribution[11].count == 100

        // Months with no data should have count 0
        result.distribution[1].period == 'February'
        result.distribution[1].count == 0
    }

    void "test getTemporalOccurrenceCount supports month-based filtering"() {
        given: "A search request for month-based occurrence count"
        service.webServicesService = webServicesService
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "lsid:NHMSYS0000503827"

        def mockResponse = [totalRecords: 250]

        when: "Getting occurrence count for January (month 1)"
        webServicesService.fullTextSearch(_) >> mockResponse
        def result = service.getTemporalOccurrenceCount(requestParams, 1, 1, 'month')

        then: "Returns month-based count with correct filter"
        result.count == 250
        result.startPeriod == 1
        result.endPeriod == 1
        result.timelineType == 'month'
        result.filter == 'month:[1 TO 1]'
    }

    void "test getMonthOccurrenceCount helper method"() {
        given: "A search request for specific month"
        service.webServicesService = webServicesService
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "lsid:NHMSYS0000503827"

        def mockResponse = [totalRecords: 175]

        when: "Getting occurrence count for June (month 6)"
        webServicesService.fullTextSearch(_) >> mockResponse
        def result = service.getMonthOccurrenceCount(requestParams, 6)

        then: "Returns month-specific count"
        result.count == 175
        result.startPeriod == 6
        result.endPeriod == 6
        result.timelineType == 'month'
    }

    void "test getTemporalDistribution with month granularity"() {
        given: "A search request with month granularity"
        service.webServicesService = webServicesService
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "lsid:NHMSYS0000503827"

        def mockResponse = [
            facetResults: [
                month: [
                    [key: '4', count: 120], // April
                    [key: '8', count: 180]  // August
                ]
            ]
        ]

        when: "Getting temporal distribution with month granularity"
        webServicesService.fullTextSearch(_) >> mockResponse
        def result = service.getTemporalDistribution(requestParams, 'month')

        then: "Returns monthly distribution via getMonthlyDistribution"
        result.distribution.size() == 12
        result.granularity == 'month'
        result.type == 'seasonal'
        result.distribution[3].count == 120  // April (index 3)
        result.distribution[7].count == 180  // August (index 7)
    }

    void "test monthly distribution filters out year and month filters"() {
        given: "A search request with existing year and month filters"
        service.webServicesService = webServicesService
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "lsid:NHMSYS0000503827"
        requestParams.fq = ['year:[1990 TO 2000]', 'month:[3 TO 6]', 'species:bird']

        def mockResponse = [
            facetResults: [
                month: [
                    [key: '7', count: 90]  // July
                ]
            ]
        ]

        when: "Getting monthly distribution"
        webServicesService.fullTextSearch({ params ->
            // Verify that year and month filters are removed but other filters remain
            def fqList = params.fq instanceof String ? [params.fq] : params.fq
            return !fqList.any { it.contains('year:') || it.contains('month:') } &&
                   fqList.contains('species:bird')
        }) >> mockResponse

        def result = service.getMonthlyDistribution(requestParams)

        then: "Filters out temporal filters but keeps other filters"
        result.distribution.size() == 12
        result.distribution[6].count == 90  // July (index 6)
    }
}
