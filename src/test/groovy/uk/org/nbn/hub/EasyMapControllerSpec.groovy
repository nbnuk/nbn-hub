package uk.org.nbn.hub

import grails.test.mixin.TestFor
import spock.lang.Specification
import spock.lang.Unroll

/**
 * Unit tests for EasyMapController
 * Tests the controller functionality including dr parameter validation
 */
@TestFor(EasyMapController)
class EasyMapControllerSpec extends Specification {

    def setup() {
        // Mock the service
        controller.easyMapService = Mock(EasyMapService)
    }

    def cleanup() {
    }

    // ========== TVK Validation Tests ==========

    @Unroll
    void "test isValidTVK with valid TVK: #tvk"() {
        expect:
        controller.isValidTVK(tvk) == true

        where:
        tvk << [
            "NHMSYS0000458183",
            "NBNSYS0000001234",
            "ABC1234567890",
            "1234567890ABCD"
        ]
    }

    @Unroll
    void "test isValidTVK with invalid TVK: #tvk"() {
        expect:
        controller.isValidTVK(tvk) == false

        where:
        tvk << [
            null,
            "",
            "short",
            "invalid-chars!",
            "lowercase123",
            "TOOLONG1234567890ABCDEFGHIJKLMNOP" // Over 30 characters
        ]
    }

    // ========== Dataset Key Validation Tests ==========

    @Unroll
    void "test isValidDatasetKeys with valid keys: #keys"() {
        expect:
        controller.isValidDatasetKeys(keys) == true

        where:
        keys << [
            null,           // Optional parameter
            "",             // Empty string
            "ds123",        // Single key
            "ds456",        // Another single key
            "dst123",       // Test dataset
            "ds123,ds456",  // Multiple keys
            "ds123,ds456,ds789", // Multiple keys
            "ds123, ds456", // With spaces
            "dsABC123",     // Alphanumeric
            "dstTEST456"    // Test dataset alphanumeric
        ]
    }

    @Unroll
    void "test isValidDatasetKeys with invalid keys: #keys"() {
        expect:
        controller.isValidDatasetKeys(keys) == false

        where:
        keys << [
            "123",          // No prefix
            "dataset123",   // Wrong prefix
            "ds",           // No number
            "ds-123",       // Invalid character
            "ds123,invalid", // Mixed valid/invalid
            "ds123,,ds456", // Double comma
            ",ds123",       // Leading comma
            "ds 123",       // Space in key
            "DS123"         // Wrong case
        ]
    }

    // ========== Controller Action Tests ==========

    void "test easyMap with valid TVK and no ds parameter"() {
        given: "valid parameters"
        params.tvk = "NHMSYS0000458183"
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [scientificName: "Test Species", acceptedTvk: "NHMSYS0000458183"]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful"
        response.status == 200
        1 * controller.easyMapService.getOccurrenceData("NHMSYS0000458183", null)
    }

    void "test easyMap with valid TVK and valid ds parameter"() {
        given: "valid parameters including ds"
        params.tvk = "NHMSYS0000458183"
        params.ds = "ds123"
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [scientificName: "Test Species", acceptedTvk: "NHMSYS0000458183"]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful and ds parameter is passed to service"
        response.status == 200
        1 * controller.easyMapService.getOccurrenceData("NHMSYS0000458183", "ds123")
    }

    void "test easyMap with valid TVK and multiple ds parameters"() {
        given: "valid parameters with multiple ds values"
        params.tvk = "NHMSYS0000458183"
        params.ds = "ds123,ds456"
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [scientificName: "Test Species", acceptedTvk: "NHMSYS0000458183"]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful and multiple ds parameters are passed to service"
        response.status == 200
        1 * controller.easyMapService.getOccurrenceData("NHMSYS0000458183", "ds123,ds456")
    }

    void "test easyMap with invalid TVK"() {
        given: "invalid TVK"
        params.tvk = "invalid"
        params.format = "json"

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is bad request"
        response.status == 400
        0 * controller.easyMapService.getSpeciesInfo(_)
        0 * controller.easyMapService.getOccurrenceData(_, _)
    }

    void "test easyMap with invalid ds parameter"() {
        given: "valid TVK but invalid ds parameter"
        params.tvk = "NHMSYS0000458183"
        params.ds = "invalid-ds"
        params.format = "json"

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is bad request"
        response.status == 400
        0 * controller.easyMapService.getSpeciesInfo(_)
        0 * controller.easyMapService.getOccurrenceData(_, _)
    }

    void "test easyMap with species not found"() {
        given: "valid parameters but species not found"
        params.tvk = "NHMSYS0000458183"
        params.format = "json"

        def mockValidation = [valid: true, message: "Valid parameters"]
        controller.easyMapService.getSpeciesInfo(_) >> null
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is not found"
        response.status == 404
        1 * controller.easyMapService.getSpeciesInfo("NHMSYS0000458183")
        0 * controller.easyMapService.getOccurrenceData(_, _)
    }

    void "test easyMap with invalid bounding box parameters"() {
        given: "valid TVK but invalid bounding box parameters"
        params.tvk = "NHMSYS0000458183"
        params.vc = "999"  // Invalid vice-county
        params.format = "json"

        def mockValidation = [valid: false, message: "Invalid vice-county number: 999. Must be a number between 1 and 112"]
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is bad request"
        response.status == 400
        0 * controller.easyMapService.getSpeciesInfo(_)
        0 * controller.easyMapService.getOccurrenceData(_, _)
    }

    void "test easyMap with valid vice-county parameter"() {
        given: "valid parameters including vice-county"
        params.tvk = "NHMSYS0000458183"
        params.vc = "17"  // Surrey
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [scientificName: "Test Species", acceptedTvk: "NHMSYS0000458183"]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful"
        response.status == 200
        1 * controller.easyMapService.getOccurrenceData("NHMSYS0000458183", null)
    }

    void "test easyMap with valid grid reference bounds"() {
        given: "valid parameters including grid reference bounds"
        params.tvk = "NHMSYS0000458183"
        params.bl = "TQ1234"
        params.tr = "TQ5678"
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [scientificName: "Test Species", acceptedTvk: "NHMSYS0000458183"]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful"
        response.status == 200
        1 * controller.easyMapService.getOccurrenceData("NHMSYS0000458183", null)
    }
}
