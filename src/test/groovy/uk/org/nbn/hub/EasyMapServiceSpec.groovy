package uk.org.nbn.hub

import grails.test.mixin.TestFor
import spock.lang.Specification
import spock.lang.Unroll

/**
 * Unit tests for EasyMapService
 * Tests core functionality of the EasyMap service
 */
@TestFor(EasyMapService)
class EasyMapServiceSpec extends Specification {

    def setup() {
        // Mock the dependencies
        service.webServicesService = Mock(au.org.ala.biocache.hubs.WebServicesService)
        service.grailsApplication = [
            config: [
                getProperty: { key, type, defaultValue ->
                    if (key == 'use.mock.data') return true
                    return defaultValue
                }
            ]
        ]
    }

    def cleanup() {
    }

    // ========== Mock Data Tests ==========

    void "test getSpeciesInfo with mock data returns mock species"() {
        given: "a TVK"
        def tvk = "NHMSYS0000458183"

        when: "getSpeciesInfo is called with mock data enabled"
        def result = service.getSpeciesInfo(tvk)

        then: "it returns mock species data"
        result != null
        result.tvk == tvk
        result.scientificName == "Passer domesticus"
        result.commonName == "House Sparrow"
        result.rank == "species"
        result.kingdom == "Animalia"
        result.family == "Passeridae"
    }

    void "test getOccurrenceData with mock data returns mock occurrences"() {
        given: "a TVK"
        def tvk = "NHMSYS0000458183"

        when: "getOccurrenceData is called with mock data enabled"
        def result = service.getOccurrenceData(tvk)

        then: "it returns mock occurrence data"
        result != null
        result.size() == 10  // Mock data generates 10 occurrences
        result.every { it.scientificName == "Passer domesticus" }
        result.every { it.commonName == "House Sparrow" }
        result.every { it.latitude != null && it.longitude != null }
        result.every { it.id != null }
    }

    // ========== Map Configuration Tests ==========

    void "test prepareMapConfig with valid occurrences calculates bounds"() {
        given: "a list of occurrence records"
        def occurrences = [
            [latitude: 51.5074, longitude: -0.1278],  // London
            [latitude: 53.4808, longitude: -2.2426],  // Manchester
            [latitude: 55.9533, longitude: -3.1883]   // Edinburgh
        ]

        when: "prepareMapConfig is called"
        def result = service.prepareMapConfig(occurrences)

        then: "it returns correct map configuration"
        result != null
        result.occurrenceCount == 3
        result.defaultLatitude != null
        result.defaultLongitude != null
        result.defaultZoom != null
        result.bounds != null
        result.bounds.southwest != null
        result.bounds.northeast != null

        // Check that center is roughly in the middle of UK
        result.defaultLatitude > 50 && result.defaultLatitude < 60
        result.defaultLongitude > -5 && result.defaultLongitude < 0
    }

    void "test prepareMapConfig with empty occurrences returns UK defaults"() {
        given: "an empty list of occurrences"
        def occurrences = []

        when: "prepareMapConfig is called"
        def result = service.prepareMapConfig(occurrences)

        then: "it returns UK default configuration"
        result != null
        result.occurrenceCount == 0
        result.defaultLatitude == 54.5
        result.defaultLongitude == -3.0
        result.defaultZoom == 6
        result.bounds == null
    }

    void "test prepareMapConfig with null occurrences returns UK defaults"() {
        given: "null occurrences"
        def occurrences = null

        when: "prepareMapConfig is called"
        def result = service.prepareMapConfig(occurrences)

        then: "it returns UK default configuration"
        result != null
        result.occurrenceCount == 0
        result.defaultLatitude == 54.5
        result.defaultLongitude == -3.0
        result.defaultZoom == 6
        result.bounds == null
    }

    void "test prepareMapConfig calculates appropriate zoom levels"() {
        given: "occurrences with large coordinate spread"
        def occurrences = [
            [latitude: 49.0, longitude: -8.0],  // Southwest
            [latitude: 59.0, longitude: 2.0]    // Northeast
        ]

        when: "prepareMapConfig is called"
        def result = service.prepareMapConfig(occurrences)

        then: "it returns low zoom level for large spread"
        result.defaultZoom <= 6

        when: "occurrences with small coordinate spread"
        occurrences = [
            [latitude: 51.5, longitude: -0.1],
            [latitude: 51.6, longitude: -0.2]
        ]
        result = service.prepareMapConfig(occurrences)

        then: "it returns high zoom level for small spread"
        result.defaultZoom >= 8
    }

    // ========== Zoom Area Tests ==========

    void "test isValidZoomArea with valid areas"() {
        when: "checking valid zoom areas"
        then: "all supported areas should return true"
        service.isValidZoomArea('england') == true
        service.isValidZoomArea('scotland') == true
        service.isValidZoomArea('wales') == true
        service.isValidZoomArea('highland') == true
        service.isValidZoomArea('sco-mainland') == true
        service.isValidZoomArea('outer-heb') == true

        and: "case insensitive check should work"
        service.isValidZoomArea('ENGLAND') == true
        service.isValidZoomArea('Scotland') == true
        service.isValidZoomArea('Highland') == true
    }

    void "test isValidZoomArea with invalid areas"() {
        when: "checking invalid zoom areas"
        then: "should return false"
        service.isValidZoomArea('invalid') == false
        service.isValidZoomArea('france') == false
        service.isValidZoomArea('') == false
        service.isValidZoomArea(null) == false
    }

    void "test getZoomAreaBounds returns correct bounds for england"() {
        when: "getting bounds for England"
        def bounds = service.getZoomAreaBounds('england')

        then: "should return correct England bounds"
        bounds != null
        bounds.centerLat == 52.8
        bounds.centerLng == -2.0
        bounds.zoom == 6
        bounds.north > bounds.south
        bounds.east > bounds.west
    }

    void "test getZoomAreaBounds returns correct bounds for highland"() {
        when: "getting bounds for Highland"
        def bounds = service.getZoomAreaBounds('highland')

        then: "should return correct Highland bounds"
        bounds != null
        bounds.centerLat == 57.4
        bounds.centerLng == -4.2
        bounds.zoom == 7
        bounds.north > bounds.south
        bounds.east > bounds.west
    }

    void "test getZoomAreaBounds returns null for invalid area"() {
        when: "getting bounds for invalid area"
        def bounds = service.getZoomAreaBounds('invalid')

        then: "should return null"
        bounds == null
    }

    void "test prepareMapConfig with zoom area overrides occurrence bounds"() {
        given: "a list of occurrence records"
        def occurrences = [
            [latitude: 51.5074, longitude: -0.1278],  // London
            [latitude: 53.4808, longitude: -2.2426],  // Manchester
        ]

        when: "prepareMapConfig is called with zoom area"
        def result = service.prepareMapConfig(occurrences, 'scotland')

        then: "it should use Scotland bounds instead of occurrence bounds"
        result != null
        result.occurrenceCount == 2
        result.defaultLatitude == 57.0  // Scotland center lat
        result.defaultLongitude == -4.0  // Scotland center lng
        result.defaultZoom == 6
        result.bounds != null
        result.bounds.southwest.lat == 54.6  // Scotland south
        result.bounds.northeast.lat == 60.9  // Scotland north
    }

    void "test prepareMapConfig with invalid zoom area ignores it"() {
        given: "a list of occurrence records"
        def occurrences = [
            [latitude: 51.5074, longitude: -0.1278]
        ]

        when: "prepareMapConfig is called with invalid zoom area"
        def result = service.prepareMapConfig(occurrences, 'invalid')

        then: "it should ignore the zoom area and use occurrence bounds"
        result != null
        result.occurrenceCount == 1
        // Should calculate from occurrences, not use zoom area
        result.defaultLatitude != 57.0
        result.defaultLongitude != -4.0
    }

    // ========== Statistics Tests ==========

    void "test getOccurrenceStatistics with valid data returns statistics"() {
        given: "a list of occurrence records with various properties"
        def occurrences = [
            [basisOfRecord: "HumanObservation", year: 2023, dataResourceName: "Dataset A"],
            [basisOfRecord: "HumanObservation", year: 2023, dataResourceName: "Dataset A"],
            [basisOfRecord: "PreservedSpecimen", year: 2022, dataResourceName: "Dataset B"],
            [basisOfRecord: "PreservedSpecimen", year: 2021, dataResourceName: "Dataset B"],
            [basisOfRecord: null, year: null, dataResourceName: null]
        ]

        when: "getOccurrenceStatistics is called"
        def result = service.getOccurrenceStatistics(occurrences)

        then: "it returns correct statistics"
        result != null

        // Basis of record counts
        result.basisOfRecord["HumanObservation"] == 2
        result.basisOfRecord["PreservedSpecimen"] == 2
        result.basisOfRecord["Unknown"] == 1

        // Year counts
        result.byYear[2023] == 2
        result.byYear[2022] == 1
        result.byYear[2021] == 1

        // Date range
        result.dateRange.earliest == 2021
        result.dateRange.latest == 2023

        // Data providers
        result.dataProviders["Dataset A"] == 2
        result.dataProviders["Dataset B"] == 2
        result.dataProviders["Unknown"] == 1
    }

    void "test getOccurrenceStatistics with empty data returns empty statistics"() {
        given: "an empty list of occurrences"
        def occurrences = []

        when: "getOccurrenceStatistics is called"
        def result = service.getOccurrenceStatistics(occurrences)

        then: "it returns empty statistics"
        result == [:]
    }

    void "test getOccurrenceStatistics with null data returns empty statistics"() {
        given: "null occurrences"
        def occurrences = null

        when: "getOccurrenceStatistics is called"
        def result = service.getOccurrenceStatistics(occurrences)

        then: "it returns empty statistics"
        result == [:]
    }

    // ========== Dataset Filter Tests ==========

    void "test getOccurrenceData with single dataset filter"() {
        given: "a TVK and single dataset key"
        def tvk = "NHMSYS0000458183"
        def datasetKey = "ds123"

        when: "getOccurrenceData is called with dataset filter"
        def result = service.getOccurrenceData(tvk, datasetKey)

        then: "it returns filtered mock occurrence data"
        result != null
        result.size() == 10  // Mock data generates 10 occurrences
        result.every { it.scientificName == "Passer domesticus" }
        result.every { it.latitude != null && it.longitude != null }
    }

    void "test getOccurrenceData with multiple dataset filters"() {
        given: "a TVK and multiple dataset keys"
        def tvk = "NHMSYS0000458183"
        def datasetKeys = "ds123,ds456,ds789"

        when: "getOccurrenceData is called with multiple dataset filters"
        def result = service.getOccurrenceData(tvk, datasetKeys)

        then: "it returns filtered mock occurrence data"
        result != null
        result.size() == 10  // Mock data generates 10 occurrences
        result.every { it.scientificName == "Passer domesticus" }
        result.every { it.latitude != null && it.longitude != null }
    }

    void "test getOccurrenceData without dataset filter"() {
        given: "a TVK without dataset filter"
        def tvk = "NHMSYS0000458183"

        when: "getOccurrenceData is called without dataset filter"
        def result = service.getOccurrenceData(tvk, null)

        then: "it returns unfiltered mock occurrence data"
        result != null
        result.size() == 10  // Mock data generates 10 occurrences
        result.every { it.scientificName == "Passer domesticus" }
        result.every { it.latitude != null && it.longitude != null }
    }

    void "test buildDatasetFilterQueries with single key"() {
        given: "a single dataset key"
        def datasetKeys = "ds123"

        when: "buildDatasetFilterQueries is called"
        def result = service.buildDatasetFilterQueries(datasetKeys)

        then: "it returns a single filter query"
        result != null
        result.size() == 1
        result[0] == "data_resource_uid:ds123"
    }

    void "test buildDatasetFilterQueries with multiple keys"() {
        given: "multiple dataset keys"
        def datasetKeys = "ds123,ds456,ds789"

        when: "buildDatasetFilterQueries is called"
        def result = service.buildDatasetFilterQueries(datasetKeys)

        then: "it returns an OR query"
        result != null
        result.size() == 1
        result[0] == "(data_resource_uid:ds123 OR data_resource_uid:ds456 OR data_resource_uid:ds789)"
    }

    void "test buildDatasetFilterQueries with null input"() {
        given: "null dataset keys"
        def datasetKeys = null

        when: "buildDatasetFilterQueries is called"
        def result = service.buildDatasetFilterQueries(datasetKeys)

        then: "it returns empty list"
        result != null
        result.size() == 0
    }

    void "test buildDatasetFilterQueries with empty input"() {
        given: "empty dataset keys"
        def datasetKeys = ""

        when: "buildDatasetFilterQueries is called"
        def result = service.buildDatasetFilterQueries(datasetKeys)

        then: "it returns empty list"
        result != null
        result.size() == 0
    }
}
