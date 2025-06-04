package uk.org.nbn.hub

import grails.converters.JSON
import groovy.util.logging.Slf4j

/**
 * Controller for EasyMap functionality
 * Provides NBN Atlas EasyMap compatible endpoints for species occurrence mapping
 */
@Slf4j
class EasyMapController {

    def easyMapService

    static allowedMethods = [
        easyMap: 'GET',
        easyMapJson: 'GET',
        health: 'GET'
    ]

    /**
     * EasyMap endpoint - returns species occurrence map data
     * Compatible with NBN Atlas EasyMap API
     *
     * @param tvk Required - Taxon Version Key
     * @param w Optional - Map width in pixels (default: 800, max: 800)
     * @param h Optional - Map height in pixels (calculated from width if not provided)
     * @param retina Optional - Retina display multiplier (1 or 2, default: 1)
     * @param cachedays Optional - Cache duration in days (default: 30, 0 to bypass cache)
     * @param format Optional - Response format ('html' or 'json', default: 'html')
     * @param ds Optional - Dataset key(s) obtainable from the NBN Gateway (e.g., 'dr123', 'ds456' or comma-separated list 'dr123,ds456,dr789')
     * @param gd Optional - Grid resolution (1km, 2km, 10km, 100km, default: 10km) - alias: res
     * @param res Optional - Grid resolution (1km, 2km, 10km, 100km, default: 10km) - alias: gd
     * @param zoom Optional - Predefined zoom area (england, scotland, wales, highland, sco-mainland, outer-heb)
     * @param vc Optional - Vice-county number to zoom to a particular vice-county
     * @param bl Optional - Bottom left grid reference (10km, 2km or 1km resolution) - use with tr parameter
     * @param tr Optional - Top right grid reference (10km, 2km or 1km resolution) - use with bl parameter
     * @param blCoord Optional - Bottom left corner as Easting,Northing coordinates - use with trCoord parameter
     * @param trCoord Optional - Top right corner as Easting,Northing coordinates - use with blCoord parameter
     */
    def easyMap() {
        log.debug("EasyMap request received with params: ${params}")

        def tvk = params.tvk as String
        def width = params.w ? Integer.valueOf(params.w as String) : 800
        def height = params.h ? Integer.valueOf(params.h as String) : 600
        def retina = params.retina ? Integer.valueOf(params.retina as String) : 1
        def cachedays = params.cachedays ? Integer.valueOf(params.cachedays as String) : 30
        def format = params.format as String ?: 'html'
        def datasetKeys = params.ds as String

        // TODO Discuss these additional to match EasyMap_Shim functionality
        def b0fill = params.b0fill as String ?: 'df4a21'  // Default red color
        def bg = params.bg as String  // Background map (e.g., 'VC' for Vice Counties)
        def gridResolution = params.gd as String ?: params.res as String ?: '10km'  // Grid resolution
        def zoomArea = params.zoom as String  // Zoom to specific area (e.g., 'highland')

        // New bounding box parameters from EasyMap_Shim
        def viceCounty = params.vc as String  // Vice-county number
        def bottomLeft = params.bl as String  // Bottom left grid reference
        def topRight = params.tr as String  // Top right grid reference
        def bottomLeftCoord = params.blCoord as String  // Bottom left coordinates (Easting,Northing)
        def topRightCoord = params.trCoord as String  // Top right coordinates (Easting,Northing)

        def terms = params.terms as String
        def ref = params.ref as String
        def link = params.link as String
        def css = params.css as String

        if (!tvk || !isValidTVK(tvk)) {
            log.warn("Invalid TVK format provided: ${tvk}")
            response.status = 400
            if (format == 'json') {
                render([result: "ERROR", message: "Invalid TVK format: ${tvk}", data: null] as JSON)
            } else {
                render(view: 'error', model: [message: "Invalid TVK format: ${tvk}", tvk: tvk])
            }
            return
        }

        // Validate dataset keys if provided
        if (datasetKeys && !isValidDatasetKeys(datasetKeys)) {
            log.warn("Invalid dataset key format provided: ${datasetKeys}")
            response.status = 400
            def errorMessage = "Invalid dataset key format: ${datasetKeys}. Expected format: dr123, ds456, or dst789 (comma-separated for multiple keys)"
            if (format == 'json') {
                render([result: "ERROR", message: errorMessage, data: null] as JSON)
            } else {
                render(view: 'error', model: [message: errorMessage, tvk: tvk])
            }
            return
        }

        // Validate grid resolution if provided
        if (gridResolution && !easyMapService.isValidGridResolution(gridResolution)) {
            log.warn("Invalid grid resolution provided: ${gridResolution}")
            response.status = 400
            def errorMessage = "Invalid grid resolution: ${gridResolution}. Supported resolutions: 1km, 2km, 10km, 100km"
            if (format == 'json') {
                render([result: "ERROR", message: errorMessage, data: null] as JSON)
            } else {
                render(view: 'error', model: [message: errorMessage, tvk: tvk])
            }
            return
        }

        // Validate zoom area if provided
        if (zoomArea && !easyMapService.isValidZoomArea(zoomArea)) {
            log.warn("Invalid zoom area provided: ${zoomArea}")
            response.status = 400
            def errorMessage = "Invalid zoom area: ${zoomArea}. Supported areas: england, scotland, wales, highland, sco-mainland, outer-heb"
            if (format == 'json') {
                render([result: "ERROR", message: errorMessage, data: null] as JSON)
            } else {
                render(view: 'error', model: [message: errorMessage, tvk: tvk])
            }
            return
        }

        // Validate bounding box parameters
        def boundingBoxValidation = easyMapService.validateBoundingBoxParams(viceCounty, bottomLeft, topRight, bottomLeftCoord, topRightCoord)
        if (!boundingBoxValidation.valid) {
            log.warn("Invalid bounding box parameters: ${boundingBoxValidation.message}")
            response.status = 400
            if (format == 'json') {
                render([result: "ERROR", message: boundingBoxValidation.message, data: null] as JSON)
            } else {
                render(view: 'error', model: [message: boundingBoxValidation.message, tvk: tvk])
            }
            return
        }

        try {
            def speciesInfo = easyMapService.getSpeciesInfo(tvk)
            if (!speciesInfo) {
                log.warn("Species not found for TVK: ${tvk}")
                response.status = 404
                if (format == 'json') {
                    render([result: "ERROR", message: "Species not found for TVK: ${tvk}", data: null] as JSON)
                } else {
                    render(view: 'notFound', model: [message: "Species not found for TVK: ${tvk}", tvk: tvk])
                }
                return
            }

            def occurrenceData = easyMapService.getOccurrenceData(speciesInfo.acceptedTvk ?: tvk, datasetKeys)
            def mapConfig = easyMapService.prepareMapConfig(occurrenceData, zoomArea, viceCounty, bottomLeft, topRight, bottomLeftCoord, topRightCoord, gridResolution)

            def mapData = [
                tvk: tvk,
                speciesInfo: speciesInfo,
                occurrences: occurrenceData,
                mapConfig: mapConfig,
                datasetFilter: datasetKeys,
                // Additional EasyMap parameters
                b0fill: b0fill,
                bg: bg,
                gridResolution: gridResolution,
                zoomArea: zoomArea,
                // New bounding box parameters
                viceCounty: viceCounty,
                bottomLeft: bottomLeft,
                topRight: topRight,
                bottomLeftCoord: bottomLeftCoord,
                topRightCoord: topRightCoord,
                terms: terms,
                ref: ref,
                link: link,
                css: css
            ]

            log.info("Successfully prepared EasyMap for ${speciesInfo.scientificName}" +
                    (datasetKeys ? " with dataset filter: ${datasetKeys}" : ""))

            if (format == 'json') {
                // Return JSON response
                render([
                    result: "SUCCESS",
                    message: "Map data retrieved successfully",
                    data: mapData
                ] as JSON)
                return
            } else {
                // Return HTML view
                def model = [
                    mapData: mapData,
                    tvk: tvk,
                    width: width,
                    height: height,
                    retina: retina,
                    mapConfigJson: (mapData.mapConfig as JSON).toString(),
                    occurrencesJson: (mapData.occurrences as JSON).toString(),
                    speciesInfoJson: (mapData.speciesInfo as JSON).toString()
                ]

                // Set cache headers based on cachedays parameter
                if (cachedays > 0) {
                    def maxAge = cachedays * 24 * 60 * 60 // Convert days to seconds
                    response.setHeader("Cache-Control", "public, max-age=${maxAge}")
                    response.setHeader("Expires", new Date(System.currentTimeMillis() + (maxAge * 1000)).toString())
                } else {
                    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate")
                    response.setHeader("Pragma", "no-cache")
                    response.setHeader("Expires", "0")
                }

                render(view: "/easyMap/map", model: model)
                return
            }

        } catch (Exception e) {
            log.error("Error processing EasyMap request for TVK ${tvk}: ${e.message}", e)
            response.status = 500
            if (format == 'json') {
                render([result: "ERROR", message: "Internal server error while processing map request", data: null] as JSON)
            } else {
                render(view: 'error', model: [message: "Error loading EasyMap", tvk: tvk])
            }
        }
    }

    /**
     * Alternative endpoint that returns only JSON (for API consumers)
     * GET /EasyMap.json?tvk=TAXONVERSIONKEY
     */
    def easyMapJson() {
        // Set format to json and delegate to main method
        params.format = "json"
        return easyMap()
    }

    /**
     * Health check endpoint for EasyMap service
     */
    def health() {
        try {
            def healthInfo = [
                service: "EasyMap",
                status: "UP",
                timestamp: new Date(),
                version: grailsApplication.metadata.getApplicationVersion()
            ]
            render([result: "SUCCESS", message: "EasyMap service is healthy", data: healthInfo] as JSON)

        } catch (Exception e) {
            log.error("Health check failed: ${e.message}", e)
            response.status = 503
            render([result: "ERROR", message: "EasyMap service is unhealthy", data: [error: e.message]] as JSON)
        }
    }

    private boolean isValidTVK(String tvk) {
        if (!tvk) return false
        // TVK should be at least 10 characters but not excessively long (max 30 characters)
        // and contain only alphanumeric characters
        return tvk.matches(/^[A-Z0-9]{10,30}$/) || tvk.startsWith('NBNSYS')
    }

    /**
     * Validate dataset key format
     * Accepts single key (e.g., 'ds123', 'dr123') or comma-separated list (e.g., 'ds123,dr456')
     * @param datasetKeys The dataset key(s) to validate
     * @return true if valid format, false otherwise
     */
    private boolean isValidDatasetKeys(String datasetKeys) {
        if (!datasetKeys) return true // Optional parameter

        // Split by comma and validate each key
        def keys = datasetKeys.split(',').collect { it.trim() }
        return keys.every { key ->
            // Dataset keys typically follow pattern: ds/dr/dst + alphanumeric (e.g., ds123, dr950, dst456)
            // Must not be empty after trimming and must not end with comma
            key && !key.isEmpty() && (
                key.matches(/^ds[a-zA-Z0-9]+$/) ||
                key.matches(/^dr[a-zA-Z0-9]+$/) ||
                key.matches(/^dst[a-zA-Z0-9]+$/)
            )
        }
    }
}
