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
}
