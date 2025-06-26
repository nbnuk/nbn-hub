package uk.org.nbn.biocache.hubs

import au.org.ala.biocache.hubs.SpatialSearchRequestParams
import grails.test.mixin.TestFor
import spock.lang.Specification

@TestFor(TimelineService)
class TimelineServiceSpec extends Specification {

    def setup() {
        // Mock the webServicesService
        service.webServicesService = Mock(au.org.ala.biocache.hubs.WebServicesService)
    }

    void "test service is injected"() {
        expect: "Service should be available"
        service != null
    }

    void "test basic temporal bounds functionality"() {
        given: "A search request"
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "test"

        and: "Mock response with no temporal data"
        service.webServicesService.fullTextSearch(_) >> [facetResults: []]

        when: "Getting temporal bounds"
        def result = service.getTemporalBounds(requestParams)

        then: "Returns expected structure"
        result != null
        result.minYear == null
        result.maxYear == null
        result.totalYears == 0
    }

    void "test temporal bounds with valid data"() {
        given: "A search request"
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "test"

        and: "Mock response with temporal data"
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
        service.webServicesService.fullTextSearch(_) >> mockResponse

        when: "Getting temporal bounds"
        def result = service.getTemporalBounds(requestParams)

        then: "Returns temporal data"
        result != null
        result.minYear == 1990
        result.maxYear == 2000
        result.totalYears == 2
    }

    void "test timeline data availability check"() {
        given: "A search request"
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "test"

        and: "Mock response with sufficient temporal data"
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
        service.webServicesService.fullTextSearch(_) >> mockResponse

        when: "Checking timeline data availability"
        def result = service.hasTimelineData(requestParams)

        then: "Returns true for sufficient data"
        result == true
    }

    void "test timeline data unavailable with insufficient data"() {
        given: "A search request"
        def requestParams = new SpatialSearchRequestParams()
        requestParams.q = "test"

        and: "Mock response with insufficient temporal data"
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
        service.webServicesService.fullTextSearch(_) >> mockResponse

        when: "Checking timeline data availability"
        def result = service.hasTimelineData(requestParams)

        then: "Returns false for insufficient data"
        result == false
    }
}
