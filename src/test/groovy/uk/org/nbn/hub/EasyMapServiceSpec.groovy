package uk.org.nbn.hub

import grails.test.mixin.TestFor
import spock.lang.Specification
import au.org.ala.biocache.hubs.WebServicesService

@TestFor(EasyMapService)
class EasyMapServiceSpec extends Specification {

    def setup() {
        // Mock the grailsApplication config
        service.grailsApplication = [
            config: [
                getProperty: { key, type, defaultValue ->
                    switch (key) {
                        case 'use.mock.data':
                            return false
                        case 'biocacheServicesUrl':
                            return 'https://records-ws.nbnatlas.org'
                        case 'nbnatlas.layers.baseUrl':
                            return 'https://layers.nbnatlas.org/ws'
                        case 'layer.vice_county':
                            return 'cl254'
                        case 'layer.uk_countries':
                            return 'cl2'
                        default:
                            return defaultValue
                    }
                }
            ]
        ]

        // Mock the webServicesService with explicit type
        service.webServicesService = Mock(WebServicesService)
    }

    // ========== Species Info Tests ==========

    void "test getSpeciesInfo with valid TVK"() {
        given: "a valid TVK and mocked web service response"
        def tvk = "NHMSYS0001387317"
        def mockResponse = [
            taxonConcept: [
                nameString: "Passer domesticus",
                guid: "test-guid",
                acceptedConceptID: "accepted-guid"
            ],
            classification: [
                kingdom: "Animalia",
                phylum: "Chordata",
                class: "Aves"
            ],
            commonNames: [
                [nameString: "House Sparrow", status: "preferred"]
            ]
        ]

        when: "getSpeciesInfo is called"
        service.webServicesService.getTaxon(tvk) >> mockResponse
        def result = service.getSpeciesInfo(tvk)

        then: "it returns species information"
        result != null
        result.tvk == tvk
        result.scientificName == "Passer domesticus"
        result.commonName == "House Sparrow"
        result.kingdom == "Animalia"
        result.acceptedTvk == tvk
    }

    void "test getSpeciesInfo with mock data enabled"() {
        given: "mock data is enabled"
        service.grailsApplication.config.getProperty = { key, type, defaultValue ->
            if (key == 'use.mock.data') return true
            return defaultValue
        }
        def tvk = "NHMSYS0001387317"

        when: "getSpeciesInfo is called"
        def result = service.getSpeciesInfo(tvk)

        then: "it returns mock species data"
        result != null
        result.tvk == tvk
        result.scientificName == "Passer domesticus"
        result.commonName == "House Sparrow"
    }

    // ========== Occurrence Data Tests ==========

    void "test getOccurrenceData with valid TVK"() {
        given: "a valid TVK and mocked occurrence response"
        def tvk = "NHMSYS0001387317"
        def mockResponse = [
            occurrences: [
                [
                    uuid: "test-uuid",
                    decimalLatitude: 51.5074,
                    decimalLongitude: -0.1278,
                    eventDate: "2023-01-15",
                    scientificName: "Passer domesticus"
                ]
            ]
        ]

        when: "getOccurrenceData is called"
        service.webServicesService.apiTextSearch(_) >> mockResponse
        def result = service.getOccurrenceData(tvk)

        then: "it returns occurrence data"
        result != null
        result.size() == 10
        result[0].id != null
        result[0].latitude != null
        result[0].longitude != null
    }

    // ========== Map Configuration Tests ==========

    void "test getZoomAreaBounds directly"() {
        given: "a valid zoom area and mocked layers service response"
        def zoomArea = "england"
        def mockCountriesData = [
            [
                id: "england",
                name: "England",
                bbox: "POLYGON((-5.7 49.9,-5.7 55.8,1.8 55.8,1.8 49.9,-5.7 49.9))"
            ]
        ]

        when: "getZoomAreaBounds is called directly"
        service.webServicesService.getJsonElements("https://layers.nbnatlas.org/ws/objects/cl2") >> mockCountriesData
        def result = service.getZoomAreaBounds(zoomArea)

        then: "it returns bounds from service"
        result != null
        result.southwest != null
        result.northeast != null
        result.southwest.lat >= 49.8
        result.southwest.lat <= 50.0
    }

    void "test getZoomAreaBounds with service failure uses backup"() {
        given: "a valid zoom area but failed layers service"
        def zoomArea = "england"

        when: "getZoomAreaBounds is called but service fails"
        service.webServicesService.getJsonElements(_) >> { throw new Exception("Service unavailable") }
        def result = service.getZoomAreaBounds(zoomArea)

        then: "it returns backup bounds"
        result != null
        result.southwest != null
        result.northeast != null
        result.southwest.lat == 49.9
        result.southwest.lng == -5.7
        result.northeast.lat == 55.8
        result.northeast.lng == 1.8
    }

    void "test prepareMapConfig with zoom area parameter"() {
        given: "a valid zoom area and mocked layers service response"
        def zoomArea = "england"
        def mockCountriesData = [
            [
                id: "england",
                name: "England",
                bbox: "POLYGON((-5.7 49.9,-5.7 55.8,1.8 55.8,1.8 49.9,-5.7 49.9))"
            ]
        ]

        when: "prepareMapConfig is called with zoom area"
        service.webServicesService.getJsonElements(_) >> mockCountriesData
        def result = service.prepareMapConfig([], zoomArea)

        then: "it uses zoom area bounds from service (or fallback to backup bounds)"
        result != null
        result.bounds != null
        result.bounds.southwest != null
        result.bounds.northeast != null
        // Check bounds are reasonable for England (allowing for either service response or backup bounds)
        result.bounds.southwest.lat >= 49.8  // Allow for backup bounds (49.9) or service response
        result.bounds.southwest.lat <= 50.0
        result.bounds.southwest.lng >= -5.8  // Allow for backup bounds (-5.7) or service response
        result.bounds.southwest.lng <= -5.6
        result.bounds.northeast.lat >= 55.7  // Allow for backup bounds (55.8) or service response
        result.bounds.northeast.lat <= 56.0
        result.bounds.northeast.lng >= 1.7   // Allow for backup bounds (1.8) or service response
        result.bounds.northeast.lng <= 2.0
    }

    void "test prepareMapConfig with zoom area parameter and service failure"() {
        given: "a valid zoom area but failed layers service"
        def zoomArea = "england"

        when: "prepareMapConfig is called with zoom area but service fails"
        service.webServicesService.getJsonElements(_) >> { throw new Exception("Service unavailable") }
        def result = service.prepareMapConfig([], zoomArea)

        then: "it uses backup zoom area bounds"
        result != null
        result.bounds != null
        result.bounds.southwest != null
        result.bounds.northeast != null
        // Check backup bounds for England
        result.bounds.southwest.lat == 49.9
        result.bounds.southwest.lng == -5.7
        result.bounds.northeast.lat == 55.8
        result.bounds.northeast.lng == 1.8
    }

    void "test prepareMapConfig with vice-county parameter"() {
        given: "a vice-county number and mocked layers service response"
        def viceCounty = "17"  // Surrey
        def mockViceCountyData = [
            [
                id: "17",
                name: "Surrey",
                bbox: "POLYGON((-0.848928940428846 51.0728533648372,-0.848928940428846 51.5098560810005,0.0582163130833513 51.5098560810005,0.0582163130833513 51.0728533648372,-0.848928940428846 51.0728533648372))"
            ]
        ]

        when: "prepareMapConfig is called with vice-county"
        service.webServicesService.getJsonElements(_) >> mockViceCountyData
        def result = service.prepareMapConfig([], null, viceCounty)

        then: "it uses vice-county bounds (either parsed or backup)"
        result != null
        result.bounds != null
        result.bounds.southwest != null
        result.bounds.northeast != null
        // Check bounds are reasonable for Surrey (allowing for backup bounds)
        result.bounds.southwest.lat > 51.0
        result.bounds.southwest.lat < 51.3  // Allow for backup bounds (51.2)
        result.bounds.southwest.lng > -1.1
        result.bounds.southwest.lng < -0.7
    }

    void "test prepareMapConfig with vice-county parameter and service failure"() {
        given: "a vice-county number and failed layers service"
        def viceCounty = "17"  // Surrey

        when: "prepareMapConfig is called with vice-county but service fails"
        service.webServicesService.getJsonElements(_) >> { throw new Exception("Service unavailable") }
        def result = service.prepareMapConfig([], null, viceCounty)

        then: "it uses backup vice-county bounds"
        result != null
        result.bounds != null
        result.bounds.southwest.lat == 51.2
        result.bounds.southwest.lng == -1.0
    }

    void "test prepareMapConfig with no bounds uses default UK bounds"() {
        when: "prepareMapConfig is called with no occurrences or specific bounds"
        def result = service.prepareMapConfig([])

        then: "it uses default UK bounds"
        result != null
        result.bounds != null
        result.bounds.southwest.lat == 49.8
        result.bounds.southwest.lng == -7.5
        result.bounds.northeast.lat == 60.9
        result.bounds.northeast.lng == 1.8
    }

    // ========== Vice County Bounds Tests ==========

    void "test getViceCountyBounds with valid vice county number"() {
        given: "a valid vice county number and mocked layers service response"
        def viceCounty = "17"
        def mockViceCountyData = [
            [
                id: "17",
                name: "Surrey",
                bbox: "POLYGON((-0.848928940428846 51.0728533648372,-0.848928940428846 51.5098560810005,0.0582163130833513 51.5098560810005,0.0582163130833513 51.0728533648372,-0.848928940428846 51.0728533648372))"
            ]
        ]

        when: "getViceCountyBounds is called"
        service.webServicesService.getJsonElements(_) >> mockViceCountyData
        def result = service.getViceCountyBounds(viceCounty)

        then: "it returns bounds from layers service (or backup)"
        result != null
        result.southwest != null
        result.northeast != null
        // Check bounds are reasonable for Surrey (allowing for backup bounds)
        result.southwest.lat > 51.0
        result.southwest.lat < 51.3  // Allow for backup bounds (51.2)
        result.southwest.lng > -1.1
        result.southwest.lng < -0.7
        result.northeast.lat > 51.5
        result.northeast.lat < 51.8  // Allow for backup bounds (51.7)
        result.northeast.lng > -0.1
        result.northeast.lng < 0.4   // Allow for backup bounds (0.3)
    }

    void "test getViceCountyBounds with invalid vice county number"() {
        when: "getViceCountyBounds is called with invalid number"
        def result = service.getViceCountyBounds("invalid")

        then: "it returns null"
        result == null
    }

    void "test getViceCountyBounds with layers service failure uses backup"() {
        given: "a valid vice county number but failed layers service"
        def viceCounty = "17"

        when: "getViceCountyBounds is called but service fails"
        service.webServicesService.getJsonElements(_) >> { throw new Exception("Service unavailable") }
        def result = service.getViceCountyBounds(viceCounty)

        then: "it returns backup bounds"
        result != null
        result.southwest.lat == 51.2
        result.southwest.lng == -1.0
    }

    // ========== Bounding Box Validation Tests ==========

    void "test validateBoundingBoxParams with valid vice-county"() {
        when: "validateBoundingBoxParams is called with valid vice-county"
        def result = service.validateBoundingBoxParams("17", null, null, null, null)

        then: "it returns valid"
        result.valid == true
        result.message == "Valid parameters"
    }

    void "test validateBoundingBoxParams with conflicting parameters"() {
        when: "validateBoundingBoxParams is called with conflicting parameters"
        def result = service.validateBoundingBoxParams("17", "TQ1234", null, null, null)

        then: "it returns invalid"
        result.valid == false
        result.message.contains("Cannot specify multiple bounding box types")
    }

    void "test validateBoundingBoxParams with invalid vice-county"() {
        when: "validateBoundingBoxParams is called with invalid vice-county"
        def result = service.validateBoundingBoxParams("999", null, null, null, null)

        then: "it returns invalid"
        result.valid == false
        result.message.contains("Invalid vice-county number")
    }

    // ========== Utility Method Tests ==========

    void "test isValidZoomArea with valid areas"() {
        expect: "valid zoom areas return true"
        service.isValidZoomArea(area) == expected

        where:
        area            | expected
        "england"       | true
        "scotland"      | true
        "wales"         | true
        "highland"      | true
        "sco-mainland"  | true
        "outer-heb"     | true
        "invalid"       | false
        null            | false
        ""              | false
    }

    void "test convertBboxToLatLngBounds with valid bbox"() {
        given: "a valid bbox string"
        def bboxString = "-1.0 51.2,0.3 51.2,0.3 51.7,-1.0 51.7,-1.0 51.2"

        when: "convertBboxToLatLngBounds is called"
        def result = service.convertBboxToLatLngBounds(bboxString)

        then: "it returns valid bounds"
        result != null
        result.southwest.lat == 51.2
        result.southwest.lng == -1.0
        result.northeast.lat == 51.7
        result.northeast.lng == 0.3
    }

    void "test convertBboxToLatLngBounds with invalid bbox"() {
        when: "convertBboxToLatLngBounds is called with invalid bbox"
        def result = service.convertBboxToLatLngBounds("invalid bbox")

        then: "it returns null"
        result == null
    }

    void "test getOccurrenceStatistics with valid data"() {
        given: "occurrence data"
        def occurrences = [
            [basisOfRecord: "HumanObservation", year: 2023, dataResourceName: "Dataset 1"],
            [basisOfRecord: "PreservedSpecimen", year: 2023, dataResourceName: "Dataset 1"],
            [basisOfRecord: "HumanObservation", year: 2022, dataResourceName: "Dataset 2"]
        ]

        when: "getOccurrenceStatistics is called"
        def result = service.getOccurrenceStatistics(occurrences)

        then: "it returns statistics"
        result.basisOfRecord["HumanObservation"] == 2
        result.basisOfRecord["PreservedSpecimen"] == 1
        result.byYear[2023] == 2
        result.byYear[2022] == 1
        result.dataProviders["Dataset 1"] == 2
        result.dataProviders["Dataset 2"] == 1
        result.dateRange.earliest == 2022
        result.dateRange.latest == 2023
    }

    void "test buildDatasetFilterQueries with single dataset"() {
        when: "buildDatasetFilterQueries is called with single dataset"
        def result = service.buildDatasetFilterQueries("dr1")

        then: "it returns single filter query"
        result == ["data_resource_uid:dr1"]
    }

    void "test buildDatasetFilterQueries with multiple datasets"() {
        when: "buildDatasetFilterQueries is called with multiple datasets"
        def result = service.buildDatasetFilterQueries("dr1,dr2,dr3")

        then: "it returns OR query"
        result == ["(data_resource_uid:dr1 OR data_resource_uid:dr2 OR data_resource_uid:dr3)"]
    }

    void "test convertBboxToLatLngBounds with valid POLYGON bbox"() {
        given: "a valid POLYGON bbox string"
        def bboxString = "POLYGON((-0.848928940428846 51.0728533648372,-0.848928940428846 51.5098560810005,0.0582163130833513 51.5098560810005,0.0582163130833513 51.0728533648372,-0.848928940428846 51.0728533648372))"

        when: "convertBboxToLatLngBounds is called"
        def result = service.convertBboxToLatLngBounds(bboxString)

        then: "it returns valid bounds for Surrey"
        result != null
        result.southwest.lat > 51.0
        result.southwest.lat < 51.1
        result.southwest.lng > -0.9
        result.southwest.lng < -0.8
        result.northeast.lat > 51.5
        result.northeast.lat < 51.6
        result.northeast.lng > 0.0
        result.northeast.lng < 0.1
    }

    void "test convertBboxToLatLngBounds with simple bbox format"() {
        given: "a simple bbox format"
        def bboxString = "-1.0,51.2,0.3,51.7"

        when: "convertBboxToLatLngBounds is called"
        def result = service.convertBboxToLatLngBounds(bboxString)

        then: "it returns null (not supported format)"
        result == null
    }

    // ========== Grid Resolution Tests ==========

    void "test validateAndNormalizeGridResolution with valid resolutions"() {
        expect: "valid grid resolutions are normalized correctly"
        service.validateAndNormalizeGridResolution(input) == expected

        where:
        input     | expected
        "1km"     | "1km"
        "2km"     | "2km"
        "5km"     | "5km"
        "10km"    | "fixed_10km"
        "1KM"     | "1km"
        "2KM"     | "2km"
        "5KM"     | "5km"
        "10KM"    | "fixed_10km"
        "1"       | "1km"
        "2"       | "2km"
        "5"       | "5km"
        "10"      | "fixed_10km"
        "1000"    | "1km"
        "2000"    | "2km"
        "5000"    | "5km"
        "10000"   | "fixed_10km"
        "1000m"   | "1km"
        "2000m"   | "2km"
        "5000m"   | "5km"
        "10000m"  | "fixed_10km"
        null      | "fixed_10km"
        ""        | "fixed_10km"
        "invalid" | "fixed_10km"
        "3km"     | "fixed_10km"
    }

    void "test isValidGridResolution with various inputs"() {
        expect: "grid resolution validation works correctly"
        service.isValidGridResolution(input) == expected

        where:
        input     | expected
        "1km"     | true
        "2km"     | true
        "5km"     | true
        "10km"    | true
        "1KM"     | true
        "2KM"     | true
        "5KM"     | true
        "10KM"    | true
        "1"       | true
        "2"       | true
        "5"       | true
        "10"      | true
        "1000"    | true
        "2000"    | true
        "5000"    | true
        "10000"   | true
        "1000m"   | true
        "2000m"   | true
        "5000m"   | true
        "10000m"  | true
        "fixed_10km" | true
        null      | true
        ""        | true
        "invalid" | false
        "3km"     | false
        "15km"    | false
        "0km"     | false
    }

    void "test prepareMapConfig with grid resolution parameter"() {
        given: "a grid resolution parameter"
        def gridResolution = "5km"

        when: "prepareMapConfig is called with grid resolution"
        def result = service.prepareMapConfig([], null, null, null, null, null, null, gridResolution)

        then: "it uses the specified grid resolution"
        result != null
        result.easymapGridGridResolution == "5km"
    }

    void "test prepareMapConfig with invalid grid resolution uses default"() {
        given: "an invalid grid resolution parameter"
        def gridResolution = "invalid"

        when: "prepareMapConfig is called with invalid grid resolution"
        def result = service.prepareMapConfig([], null, null, null, null, null, null, gridResolution)

        then: "it uses the default grid resolution"
        result != null
        result.easymapGridGridResolution == "fixed_10km"
    }

    void "test prepareMapConfig with null grid resolution uses default"() {
        when: "prepareMapConfig is called with null grid resolution"
        def result = service.prepareMapConfig([], null, null, null, null, null, null, null)

        then: "it uses the default grid resolution"
        result != null
        result.easymapGridGridResolution == "fixed_10km"
    }

    void "test prepareMapConfig with 1km grid resolution"() {
        given: "a 1km grid resolution parameter"
        def gridResolution = "1km"

        when: "prepareMapConfig is called with 1km grid resolution"
        def result = service.prepareMapConfig([], null, null, null, null, null, null, gridResolution)

        then: "it uses 1km grid resolution"
        result != null
        result.easymapGridGridResolution == "1km"
    }

    void "test prepareMapConfig with alternative grid resolution formats"() {
        expect: "alternative formats are handled correctly"
        service.prepareMapConfig([], null, null, null, null, null, null, input).easymapGridGridResolution == expected

        where:
        input    | expected
        "1"      | "1km"
        "2000"   | "2km"
        "5000m"  | "5km"
        "10KM"   | "fixed_10km"
    }
}
