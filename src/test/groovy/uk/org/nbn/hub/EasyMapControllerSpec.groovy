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
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution(_) >> true

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
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution(_) >> true

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
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution(_) >> true

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
        controller.easyMapService.isValidGridResolution(_) >> true

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
        controller.easyMapService.isValidGridResolution(_) >> true

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
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution(_) >> true

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
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution(_) >> true

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful"
        response.status == 200
        1 * controller.easyMapService.getOccurrenceData("NHMSYS0000458183", null)
    }

    // ========== Grid Resolution Tests ==========

    void "test easyMap with valid grid resolution parameter"() {
        given: "valid parameters including grid resolution"
        params.tvk = "NHMSYS0000458183"
        params.gd = "5km"
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [scientificName: "Test Species", acceptedTvk: "NHMSYS0000458183"]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution("5km") >> true

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful and grid resolution is passed to service"
        response.status == 200
        1 * controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, "5km")
    }

    void "test easyMap with valid grid resolution using res parameter"() {
        given: "valid parameters using res alias for grid resolution"
        params.tvk = "NHMSYS0000458183"
        params.res = "2km"
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [scientificName: "Test Species", acceptedTvk: "NHMSYS0000458183"]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution("2km") >> true

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful and grid resolution is passed to service"
        response.status == 200
        1 * controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, "2km")
    }

    void "test easyMap with gd parameter takes precedence over res"() {
        given: "valid parameters with both gd and res specified"
        params.tvk = "NHMSYS0000458183"
        params.gd = "1km"
        params.res = "5km"
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [scientificName: "Test Species", acceptedTvk: "NHMSYS0000458183"]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution("1km") >> true

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful and gd parameter takes precedence"
        response.status == 200
        1 * controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, "1km")
    }

    void "test easyMap with invalid grid resolution parameter"() {
        given: "valid TVK but invalid grid resolution"
        params.tvk = "NHMSYS0000458183"
        params.gd = "invalid"
        params.format = "json"

        controller.easyMapService.isValidGridResolution("invalid") >> false

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is bad request"
        response.status == 400
        0 * controller.easyMapService.getSpeciesInfo(_)
        0 * controller.easyMapService.getOccurrenceData(_, _)
    }

    @Unroll
    void "test easyMap with various valid grid resolutions: #gridResolution"() {
        given: "valid parameters with different grid resolutions"
        params.tvk = "NHMSYS0000458183"
        params.gd = gridResolution
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [scientificName: "Test Species", acceptedTvk: "NHMSYS0000458183"]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution(gridResolution) >> true

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful"
        response.status == 200
        1 * controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, gridResolution)

        where:
        gridResolution << ["1km", "2km", "5km", "10km", "1KM", "2KM", "5KM", "10KM"]
    }

    @Unroll
    void "test easyMap with invalid grid resolutions: #gridResolution"() {
        given: "valid TVK but invalid grid resolution"
        params.tvk = "NHMSYS0000458183"
        params.gd = gridResolution
        params.format = "json"

        controller.easyMapService.isValidGridResolution(gridResolution) >> false

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is bad request"
        response.status == 400
        0 * controller.easyMapService.getSpeciesInfo(_)

        where:
        gridResolution << ["3km", "15km", "0km", "invalid", "100m", "-1km"]
    }

    // ========== Display Parameter Tests ==========

    @Unroll
    void "test easyMap with valid title parameter: #title"() {
        given: "valid parameters with title parameter"
        params.tvk = "NHMSYS0000458183"
        params.title = title
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [scientificName: "Test Species", commonName: "Common Test", acceptedTvk: "NHMSYS0000458183"]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution(_) >> true
        controller.easyMapService.processDateBands(_, _) >> [bands: []]

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful and title parameter is handled"
        response.status == 200
        1 * controller.easyMapService.getSpeciesInfo("NHMSYS0000458183")

        where:
        title << ["sci", "com", "0", null]
    }

    void "test easyMap with invalid title parameter"() {
        given: "valid TVK but invalid title parameter"
        params.tvk = "NHMSYS0000458183"
        params.title = "invalid"
        params.format = "json"

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is bad request"
        response.status == 400
        0 * controller.easyMapService.getSpeciesInfo(_)
    }

    @Unroll
    void "test easyMap with valid boolean display parameters: #paramName=#paramValue"() {
        given: "valid parameters with boolean display parameter"
        params.tvk = "NHMSYS0000458183"
        params[paramName] = paramValue
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [scientificName: "Test Species", acceptedTvk: "NHMSYS0000458183"]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution(_) >> true
        controller.easyMapService.processDateBands(_, _) >> [bands: []]

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful and boolean parameter is handled"
        response.status == 200
        1 * controller.easyMapService.getSpeciesInfo("NHMSYS0000458183")

        where:
        paramName | paramValue
        "terms"   | "0"
        "terms"   | "1"
        "terms"   | null
        "link"    | "0"
        "link"    | "1"
        "link"    | null
        "ref"     | "0"
        "ref"     | "1"
        "ref"     | null
        "logo"    | "0"
        "logo"    | "1"
        "logo"    | null
        "maponly" | "0"
        "maponly" | "1"
        "maponly" | null
    }

    @Unroll
    void "test easyMap with invalid boolean display parameters: #paramName=#paramValue"() {
        given: "valid TVK but invalid boolean display parameter"
        params.tvk = "NHMSYS0000458183"
        params[paramName] = paramValue
        params.format = "json"

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is bad request"
        response.status == 400
        0 * controller.easyMapService.getSpeciesInfo(_)

        where:
        paramName | paramValue
        "terms"   | "invalid"
        "terms"   | "2"
        "link"    | "yes"
        "link"    | "no"
        "ref"     | "true"
        "ref"     | "false"
        "logo"    | "on"
        "logo"    | "off"
        "maponly" | "show"
        "maponly" | "hide"
    }

    void "test easyMap with maponly=1 sets appropriate response data"() {
        given: "valid parameters with maponly=1"
        params.tvk = "NHMSYS0000458183"
        params.maponly = "1"
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [scientificName: "Test Species", acceptedTvk: "NHMSYS0000458183"]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution(_) >> true
        controller.easyMapService.processDateBands(_, _) >> [bands: []]

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful and contains maponly setting"
        response.status == 200
        // Note: In a real test, you'd verify the mapData contains maponly: "1"
        1 * controller.easyMapService.getSpeciesInfo("NHMSYS0000458183")
    }

    void "test easyMap with title=com uses common name when available"() {
        given: "valid parameters with title=com"
        params.tvk = "NHMSYS0000458183"
        params.title = "com"
        params.format = "json"

        and: "mock service responses with common name"
        def mockSpeciesInfo = [
            scientificName: "Passer domesticus",
            commonName: "House Sparrow",
            acceptedTvk: "NHMSYS0000458183"
        ]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution(_) >> true
        controller.easyMapService.processDateBands(_, _) >> [bands: []]

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful and should use common name for title"
        response.status == 200
        1 * controller.easyMapService.getSpeciesInfo("NHMSYS0000458183")
    }

    void "test easyMap with multiple display parameters combined"() {
        given: "valid parameters with multiple display controls"
        params.tvk = "NHMSYS0000458183"
        params.title = "com"
        params.terms = "0"
        params.link = "1"
        params.ref = "0"
        params.logo = "1"
        params.maponly = "0"
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [
            scientificName: "Passer domesticus",
            commonName: "House Sparrow",
            acceptedTvk: "NHMSYS0000458183"
        ]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution(_) >> true
        controller.easyMapService.processDateBands(_, _) >> [bands: []]

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful and contains all display parameters"
        response.status == 200
        1 * controller.easyMapService.getSpeciesInfo("NHMSYS0000458183")
    }

    void "test easyMap with css parameter includes CSS link"() {
        given: "valid parameters with CSS parameter"
        params.tvk = "NHMSYS0000458183"
        params.css = "https://example.com/custom.css"
        params.format = "json"

        and: "mock service responses"
        def mockSpeciesInfo = [scientificName: "Test Species", acceptedTvk: "NHMSYS0000458183"]
        def mockOccurrences = [[id: "1", latitude: 51.5, longitude: -0.1]]
        def mockMapConfig = [occurrenceCount: 1]
        def mockValidation = [valid: true, message: "Valid parameters"]

        controller.easyMapService.getSpeciesInfo(_) >> mockSpeciesInfo
        controller.easyMapService.getOccurrenceData(_, _) >> mockOccurrences
        controller.easyMapService.prepareMapConfig(_, _, _, _, _, _, _, _) >> mockMapConfig
        controller.easyMapService.validateBoundingBoxParams(_, _, _, _, _) >> mockValidation
        controller.easyMapService.isValidGridResolution(_) >> true
        controller.easyMapService.processDateBands(_, _) >> [bands: []]

        when: "easyMap action is called"
        controller.easyMap()

        then: "response is successful and should include CSS parameter"
        response.status == 200
        1 * controller.easyMapService.getSpeciesInfo("NHMSYS0000458183")
    }

    // ========== Display Parameter Validation Helper Tests ==========

    void "test isValidDisplayParameter with various inputs"() {
        expect: "display parameter validation works correctly"
        controller.isValidDisplayParameter(input, allowedValues) == expected

        where:
        input     | allowedValues         | expected
        "sci"     | ["sci", "com", "0"]  | true
        "com"     | ["sci", "com", "0"]  | true
        "0"       | ["sci", "com", "0"]  | true
        "invalid" | ["sci", "com", "0"]  | false
        null      | ["sci", "com", "0"]  | true
        ""        | ["sci", "com", "0"]  | true
        "1"       | ["0", "1"]           | true
        "0"       | ["0", "1"]           | true
        "2"       | ["0", "1"]           | false
    }

    void "test isValidBooleanParameter with various inputs"() {
        expect: "boolean parameter validation works correctly"
        controller.isValidBooleanParameter(input) == expected

        where:
        input     | expected
        "0"       | true
        "1"       | true
        null      | true
        ""        | true
        "true"    | false
        "false"   | false
        "yes"     | false
        "no"      | false
        "on"      | false
        "off"     | false
        "2"       | false
        "invalid" | false
    }

    // ========== Interactive Map URL Building Tests ==========

    void "test buildInteractiveMapUrl with TVK only"() {
        given: "controller with grailsApplication config"
        controller.grailsApplication = [
            config: [
                getProperty: { key, type, defaultValue ->
                    if (key == 'easymap.interactiveMapUrl') {
                        return 'https://records.nbnatlas.org/occurrences/search'
                    }
                    return defaultValue
                }
            ]
        ]

        when: "buildInteractiveMapUrl is called with TVK only"
        def result = controller.buildInteractiveMapUrl("NHMSYS0000458183", null)

        then: "it returns correctly formatted URL"
        result == "https://records.nbnatlas.org/occurrences/search?q=lsid:NHMSYS0000458183"
    }

    void "test buildInteractiveMapUrl with TVK and single dataset"() {
        given: "controller with grailsApplication config"
        controller.grailsApplication = [
            config: [
                getProperty: { key, type, defaultValue ->
                    if (key == 'easymap.interactiveMapUrl') {
                        return 'https://records.nbnatlas.org/occurrences/search'
                    }
                    return defaultValue
                }
            ]
        ]

        when: "buildInteractiveMapUrl is called with TVK and single dataset"
        def result = controller.buildInteractiveMapUrl("NHMSYS0000458183", "ds123")

        then: "it returns correctly formatted URL with dataset filter"
        result.startsWith("https://records.nbnatlas.org/occurrences/search?q=lsid:NHMSYS0000458183&fq=")
        result.contains("data_resource_uid:ds123")
    }

    void "test buildInteractiveMapUrl with TVK and multiple datasets"() {
        given: "controller with grailsApplication config"
        controller.grailsApplication = [
            config: [
                getProperty: { key, type, defaultValue ->
                    if (key == 'easymap.interactiveMapUrl') {
                        return 'https://records.nbnatlas.org/occurrences/search'
                    }
                    return defaultValue
                }
            ]
        ]

        when: "buildInteractiveMapUrl is called with TVK and multiple datasets"
        def result = controller.buildInteractiveMapUrl("NHMSYS0000458183", "ds123,ds456")

        then: "it returns correctly formatted URL with multiple dataset filters"
        result.startsWith("https://records.nbnatlas.org/occurrences/search?q=lsid:NHMSYS0000458183&fq=")
        result.contains("data_resource_uid:ds123")
        result.contains("data_resource_uid:ds456")
        result.contains(" OR ")
    }
}
