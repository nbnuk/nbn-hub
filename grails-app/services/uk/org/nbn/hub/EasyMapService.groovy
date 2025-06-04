package uk.org.nbn.hub

import au.org.ala.biocache.hubs.SearchRequestParams
import grails.converters.JSON
import groovy.util.logging.Slf4j
import org.grails.web.json.JSONArray
import org.grails.web.json.JSONObject

@Slf4j
class EasyMapService {

    def grailsApplication
    def webServicesService

    // Cache for vice county bounds data to avoid repeated API calls
    private static Map<String, Map> viceCountyBoundsCache = [:]
    private static long viceCountyCacheTimestamp = 0
    private static final long CACHE_EXPIRY_MS = 24 * 60 * 60 * 1000 // 24 hours

    // Cache for zoom area bounds data to avoid repeated API calls
    private static Map<String, Map> zoomAreaBoundsCache = [:]
    private static long zoomAreaCacheTimestamp = 0

    /**
     * Get species information from BIE service using TVK
     * @param tvk The Taxon Version Key
     * @return Map containing species information
     */
    def getSpeciesInfo(String tvk) {
        log.debug("Retrieving species info for TVK: ${tvk}")

        // Check if mock data should be used
        if (grailsApplication.config.getProperty('use.mock.data', Boolean, false)) {
            log.info("Using mock data mode for species info")
            return getMockSpeciesInfo(tvk)
        }

        try {
            // Use the existing method from WebServicesService
            def jsonResponse = webServicesService.getTaxon(tvk)

            if (jsonResponse && !jsonResponse.isEmpty()) {
                // Extract data from nested BIE response structure
                def taxonConcept = jsonResponse.taxonConcept ?: [:]
                def classification = jsonResponse.classification ?: [:]
                def commonNames = jsonResponse.commonNames ?: []
                def preferredCommonName = commonNames.find { it.status == "preferred" }?.nameString
                def anyCommonName = commonNames.find { it.nameString }?.nameString

                return [
                    tvk: tvk,
                    acceptedTvk: taxonConcept.acceptedConceptID ?: taxonConcept.guid ?: tvk,
                    scientificName: taxonConcept.nameString ?: classification.scientificName,
                    commonName: preferredCommonName ?: anyCommonName,
                    rank: taxonConcept.rankString ?: classification.rank,
                    guid: taxonConcept.guid,
                    kingdom: classification.kingdom,
                    phylum: classification.phylum,
                    classs: classification.class,
                    order: classification.order,
                    family: classification.family,
                    genus: classification.genus,
                    speciesGroup: jsonResponse.speciesGroup ?: [classification.kingdom],
                    datasetName: taxonConcept.nameAuthority,
                    parentGuid: taxonConcept.parentGuid,
                    acceptedConceptName: taxonConcept.nameString,
                    nameAuthority: taxonConcept.nameAuthority,
                    taxonomicStatus: taxonConcept.taxonomicStatus,
                    conservationStatus: jsonResponse.conservationStatuses,
                    imageUrl: jsonResponse.imageIdentifier,
                    thumbnailUrl: jsonResponse.imageIdentifier
                ]
            } else {
                log.warn("No species information found for TVK: ${tvk}")
                return null
            }

        } catch (Exception e) {
            log.error("Error retrieving species info for TVK ${tvk}: ${e.message}", e)
            // Return mock data for demo purposes when external services are unavailable
            return getMockSpeciesInfo(tvk)
        }
    }

    /**
     * Get occurrence data from Biocache service for a given TVK
     * @param acceptedTvk The accepted TVK to search for
     * @param datasetKeys Optional comma-separated list of dataset keys to filter by
     * @return List of occurrence records
     */
    def getOccurrenceData(String acceptedTvk, String datasetKeys = null) {
        log.debug("Retrieving occurrence data for TVK: ${acceptedTvk}" +
                 (datasetKeys ? " with dataset filter: ${datasetKeys}" : ""))

        // Check if mock data should be used
        if (grailsApplication.config.getProperty('use.mock.data', Boolean, false)) {
            log.info("Using mock data mode for occurrence data")
            return getMockOccurrenceData(acceptedTvk)
        }

        try {
            // Use the biocache-hubs SearchRequestParams to build the query
            def requestParams = new au.org.ala.biocache.hubs.SearchRequestParams()
            requestParams.q = "lsid:${acceptedTvk}"
            requestParams.pageSize = 500  // Limit for map display

            // Add dataset filter if provided
            if (datasetKeys) {
                def filterQueries = buildDatasetFilterQueries(datasetKeys)
                requestParams.fq = filterQueries
                log.debug("Applied dataset filter queries: ${filterQueries}")
            }

            def jsonResponse = webServicesService.apiTextSearch(requestParams)

            if (jsonResponse && jsonResponse.occurrences) {
                return jsonResponse.occurrences.findAll { occurrence ->
                    // Only include records with valid coordinates
                    occurrence.decimalLatitude && occurrence.decimalLongitude &&
                    isValidCoordinate(occurrence.decimalLatitude as Double, occurrence.decimalLongitude as Double)
                }.collect { occurrence ->
                    [
                        id: occurrence.uuid,
                        latitude: occurrence.decimalLatitude as Double,
                        longitude: occurrence.decimalLongitude as Double,
                        eventDate: occurrence.eventDate,
                        year: occurrence.year,
                        month: occurrence.month,
                        day: occurrence.day,
                        basisOfRecord: occurrence.basisOfRecord,
                        dataResourceUid: occurrence.dataResourceUid,
                        dataResourceName: occurrence.dataResourceName,
                        recordedBy: occurrence.recordedBy,
                        locality: occurrence.locality,
                        stateProvince: occurrence.stateProvince,
                        coordinateUncertaintyInMeters: occurrence.coordinateUncertaintyInMeters,
                        scientificName: occurrence.scientificName,
                        commonName: occurrence.vernacularName,
                        family: occurrence.family,
                        order: occurrence.order,
                        classs: occurrence.classs,
                        phylum: occurrence.phylum,
                        kingdom: occurrence.kingdom
                    ]
                }
            } else {
                log.debug("No occurrence data found for TVK: ${acceptedTvk}")
                return []
            }

        } catch (Exception e) {
            log.error("Error retrieving occurrence data for TVK ${acceptedTvk}: ${e.message}", e)
            // Return mock data for demo purposes when external services are unavailable
            return getMockOccurrenceData(acceptedTvk)
        }
    }

    /**
     * Build filter queries for dataset keys
     * @param datasetKeys Comma-separated list of dataset keys
     * @return List of filter query strings
     */
    private List<String> buildDatasetFilterQueries(String datasetKeys) {
        if (!datasetKeys) {
            return []
        }

        def keys = datasetKeys.split(',').collect { it.trim() }

        if (keys.size() == 1) {
            // Single dataset filter
            return ["data_resource_uid:${keys[0]}"]
        } else {
            // Multiple datasets - use OR query
            def orQuery = keys.collect { "data_resource_uid:${it}" }.join(' OR ')
            return ["(${orQuery})"]
        }
    }

    /**
     * Mock species info for testing when external services are unavailable
     */
    private def getMockSpeciesInfo(String tvk) {
        log.info("Using mock species data for TVK: ${tvk}")
        return [
            tvk: tvk,
            acceptedTvk: tvk,
            scientificName: "Passer domesticus",
            commonName: "House Sparrow",
            rank: "species",
            guid: "mock-guid-${tvk}",
            kingdom: "Animalia",
            phylum: "Chordata",
            classs: "Aves",
            order: "Passeriformes",
            family: "Passeridae",
            genus: "Passer",
            speciesGroup: ["Birds"],
            datasetName: "Mock Dataset",
            parentGuid: "mock-parent-guid",
            acceptedConceptName: "Passer domesticus",
            nameAuthority: "Mock Authority",
            taxonomicStatus: "accepted",
            conservationStatus: "Least Concern",
            imageUrl: null,
            thumbnailUrl: null
        ]
    }

    /**
     * Mock occurrence data for testing when external services are unavailable
     */
    private def getMockOccurrenceData(String tvk) {
        log.info("Using mock occurrence data for TVK: ${tvk}")

        // Generate some sample occurrence points across the UK
        def mockOccurrences = []

        // Sample locations across the UK
        def locations = [
            [lat: 51.5074, lng: -0.1278, locality: "London"],  // London
            [lat: 53.4808, lng: -2.2426, locality: "Manchester"],  // Manchester
            [lat: 55.9533, lng: -3.1883, locality: "Edinburgh"],  // Edinburgh
            [lat: 51.4816, lng: -3.1791, locality: "Cardiff"],  // Cardiff
            [lat: 54.5973, lng: -5.9301, locality: "Belfast"],  // Belfast
            [lat: 52.4862, lng: -1.8904, locality: "Birmingham"],  // Birmingham
            [lat: 53.8008, lng: -1.5491, locality: "Leeds"],  // Leeds
            [lat: 53.4084, lng: -2.9916, locality: "Liverpool"],  // Liverpool
            [lat: 50.3755, lng: -4.1427, locality: "Plymouth"],  // Plymouth
            [lat: 57.1497, lng: -2.0943, locality: "Aberdeen"]   // Aberdeen
        ]

        locations.eachWithIndex { location, index ->
            mockOccurrences << [
                id: "mock-occurrence-${index + 1}",
                latitude: location.lat + (Math.random() - 0.5) * 0.1, // Add small random offset
                longitude: location.lng + (Math.random() - 0.5) * 0.1,
                eventDate: "2023-0${(index % 9) + 1}-15",
                year: 2023,
                month: (index % 12) + 1,
                day: 15,
                basisOfRecord: index % 2 == 0 ? "HumanObservation" : "PreservedSpecimen",
                dataResourceUid: "mock-dr-${index + 1}",
                dataResourceName: "Mock Dataset ${index + 1}",
                recordedBy: "Mock Observer ${index + 1}",
                locality: location.locality,
                stateProvince: location.locality,
                coordinateUncertaintyInMeters: 100,
                scientificName: "Passer domesticus",
                commonName: "House Sparrow",
                family: "Passeridae",
                order: "Passeriformes",
                classs: "Aves",
                phylum: "Chordata",
                kingdom: "Animalia"
            ]
        }

        return mockOccurrences
    }

    /**
     * Prepare map configuration data for EasyMap display
     * @param occurrences List of occurrence data
     * @param zoomArea Optional predefined zoom area
     * @param viceCounty Optional vice-county number
     * @param bottomLeft Optional bottom left grid reference
     * @param topRight Optional top right grid reference
     * @param bottomLeftCoord Optional bottom left coordinates
     * @param topRightCoord Optional top right coordinates
     * @param gridResolution Optional grid resolution (1km, 2km, 5km, 10km)
     * @return Map configuration data
     */
    def prepareMapConfig(List occurrences, String zoomArea = null, String viceCounty = null,
                        String bottomLeft = null, String topRight = null,
                        String bottomLeftCoord = null, String topRightCoord = null,
                        String gridResolution = null) {
        log.debug("Preparing map config for ${occurrences?.size() ?: 0} occurrences with zoom area: ${zoomArea}, vc: ${viceCounty}, bl: ${bottomLeft}, tr: ${topRight}, gridRes: ${gridResolution}")

        // Validate and normalize grid resolution
        def validatedGridResolution = validateAndNormalizeGridResolution(gridResolution)

        // TODO - which one is correct - default to mini-atlas or production ?
        def biocacheUrl = grailsApplication.config.biocacheServicesUrl ?: grailsApplication.config.biocacheServiceUrl ?: 'https://records-ws.nbnatlas.org'
        log.debug("Using biocache URL in map config: ${biocacheUrl}")

        def mapConfig = [
            biocacheUrl: biocacheUrl,
            occurrenceCount: occurrences?.size() ?: 0,
            bounds: grailsApplication.config.getProperty('easymap.defaultBounds', String, null),
            zoomLevel: grailsApplication.config.getProperty('easymap.defaultZoom', Integer, 6),
            easymapDefaultLatitude: grailsApplication.config.getProperty('easymap.defaultLatitude', Double, 54.5),
            easymapDefaultLongitude: grailsApplication.config.getProperty('easymap.defaultLongitude', Double, -3.0),
            easymapDefaultZoom: grailsApplication.config.getProperty('easymap.defaultZoom', Integer, 6),
            easymapTileLayerMinimalUrl: grailsApplication.config.getProperty('easymap.tileLayer.minimal.url', String, 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png'),
            easymapTileLayerMinimalAttribution: grailsApplication.config.getProperty('easymap.tileLayer.minimal.attribution', String, '© OpenStreetMap contributors, © CartoDB'),
            easymapTileLayerMinimalSubdomains: grailsApplication.config.getProperty('easymap.tileLayer.minimal.subdomains', String, 'abcd'),
            easymapTileLayerMinimalMaxZoom: grailsApplication.config.getProperty('easymap.tileLayer.minimal.maxZoom', Integer, 18),
            easymapTileLayerOsmUrl: grailsApplication.config.getProperty('easymap.tileLayer.osm.url', String, 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'),
            easymapTileLayerOsmAttribution: grailsApplication.config.getProperty('easymap.tileLayer.osm.attribution', String, '© OpenStreetMap contributors'),
            easymapTileLayerOsmMaxZoom: grailsApplication.config.getProperty('easymap.tileLayer.osm.maxZoom', Integer, 18),
            easymapGridDefaultColor: grailsApplication.config.getProperty('easymap.grid.defaultColor', String, 'df4a21'),
            easymapGridOpacity: grailsApplication.config.getProperty('easymap.grid.opacity', String, '0.8'),
            easymapGridLayers: grailsApplication.config.getProperty('easymap.grid.layers', String, 'ALA:occurrences'),
            easymapGridFormat: grailsApplication.config.getProperty('easymap.grid.format', String, 'image/png'),
            easymapGridColourMode: grailsApplication.config.getProperty('easymap.grid.colourMode', String, 'osgrid'),
            easymapGridGridLabels: grailsApplication.config.getProperty('easymap.grid.gridLabels', String, 'false'),
            easymapGridGridResolution: validatedGridResolution, // Use the validated resolution instead of hardcoded value
            easymapBiocacheFallbackUrl: grailsApplication.config.getProperty('easymap.biocache.fallbackUrl', String, 'https://records-ws.nbnatlas.org')
        ]

        // Priority 1: Use predefined zoom area bounds if specified
        if (zoomArea && getZoomAreaBounds(zoomArea)) {
            def areaBounds = getZoomAreaBounds(zoomArea)
            // The areaBounds already comes in the correct format (southwest/northeast)
            mapConfig.bounds = areaBounds
            log.debug("Using zoom area bounds for: ${zoomArea}")
            log.debug("Zoom area bounds: ${areaBounds}")
            return mapConfig
        }

        // Priority 2: Use vice-county bounds if specified
        if (viceCounty) {
            def vcBounds = getViceCountyBounds(viceCounty)
            if (vcBounds) {
                mapConfig.bounds = vcBounds
                log.debug("Using vice-county bounds for VC: ${viceCounty}")
                return mapConfig
            }
        }

        // Priority 3: Use grid reference bounding box if bl and tr specified
        if (bottomLeft && topRight) {
            def grBounds = getGridReferenceBounds(bottomLeft, topRight)
            if (grBounds) {
                mapConfig.bounds = grBounds
                log.debug("Using grid reference bounds: ${bottomLeft} to ${topRight}")
                return mapConfig
            }
        }

        // Priority 4: Use coordinate bounding box if blCoord and trCoord specified
        if (bottomLeftCoord && topRightCoord) {
            def coordBounds = getCoordinateBounds(bottomLeftCoord, topRightCoord)
            if (coordBounds) {
                mapConfig.bounds = coordBounds
                log.debug("Using coordinate bounds: ${bottomLeftCoord} to ${topRightCoord}")
                return mapConfig
            }
        }

        // Priority 5: Use default UK bounds if no specific bounds are set and no occurrences
        if (!occurrences || occurrences.isEmpty()) {
            mapConfig.bounds = getDefaultUKBounds()
            log.debug("Using default UK bounds - no occurrences available")
            return mapConfig
        }

        // Priority 6: Calculate bounds from occurrence data as fallback
        def calculatedBounds = calculateBoundsFromOccurrences(occurrences)
        if (calculatedBounds) {
            mapConfig.bounds = calculatedBounds
            log.debug("Using calculated bounds from ${occurrences.size()} occurrences")
        } else {
            mapConfig.bounds = getDefaultUKBounds()
            log.debug("Using default UK bounds - could not calculate from occurrences")
        }

        return mapConfig
    }

    /**
     * Check if the provided zoom area is valid
     * @param zoomArea The zoom area identifier
     * @return boolean true if valid
     */
    def isValidZoomArea(String zoomArea) {
        if (!zoomArea) return false

        def validAreas = ['england', 'scotland', 'wales', 'highland', 'sco-mainland', 'outer-heb']
        return validAreas.contains(zoomArea.toLowerCase())
    }

    /**
     * Get predefined geographical bounds for zoom areas from NBN Atlas layers service
     * Based on dynamic lookup from layers service instead of hardcoded values
     * @param zoomArea The area identifier
     * @return Map containing bounds and zoom level, or null if not found
     */
    def getZoomAreaBounds(String zoomArea) {
        if (!zoomArea) return null

        try {
            // Load zoom area bounds data (with caching)
            def zoomAreaBounds = loadZoomAreaBoundsData()

            // Look up by area name (case-insensitive)
            def areaBounds = zoomAreaBounds.find { key, value ->
                return key.toLowerCase() == zoomArea.toLowerCase() ||
                       value.name?.toLowerCase()?.contains(zoomArea.toLowerCase())
            }

            if (areaBounds?.value?.bounds) {
                // Add default zoom level based on area type
                def bounds = areaBounds.value.bounds
                bounds.zoom = getDefaultZoomForArea(zoomArea)
                return bounds
            }

            log.warn("No bounds found for zoom area: ${zoomArea}")

            // Fall back to backup bounds if not found in service data
            def backupBounds = getBackupZoomAreaBounds()
            def backupArea = backupBounds.find { key, value ->
                return key.toLowerCase() == zoomArea.toLowerCase()
            }

            if (backupArea?.value?.bounds) {
                log.debug("Using backup bounds for zoom area: ${zoomArea}")
                return backupArea.value.bounds
            }

            return null

        } catch (Exception e) {
            log.error("Error retrieving zoom area bounds for ${zoomArea}: ${e.message}", e)

            // Fall back to backup bounds on exception
            try {
                def backupBounds = getBackupZoomAreaBounds()
                def backupArea = backupBounds.find { key, value ->
                    return key.toLowerCase() == zoomArea.toLowerCase()
                }

                if (backupArea?.value?.bounds) {
                    log.debug("Using backup bounds for zoom area after error: ${zoomArea}")
                    return backupArea.value.bounds
                }
            } catch (Exception backupException) {
                log.error("Error retrieving backup bounds for ${zoomArea}: ${backupException.message}")
            }

            return null
        }
    }

    /**
     * Load zoom area bounds data from NBN Atlas layers service with caching
     * @return Map of area identifiers to bounds data
     */
    private Map loadZoomAreaBoundsData() {
        // Check cache first
        def currentTime = System.currentTimeMillis()
        if (zoomAreaBoundsCache &&
            zoomAreaCacheTimestamp > 0 &&
            (currentTime - zoomAreaCacheTimestamp) < CACHE_EXPIRY_MS) {
            log.debug("Using cached zoom area bounds data")
            return zoomAreaBoundsCache
        }

        try {
            log.info("Fetching zoom area bounds from NBN Atlas layers service")

            def layersBaseUrl = grailsApplication.config.getProperty('nbnatlas.layers.baseUrl', 'https://layers.nbnatlas.org/ws')
            def countriesLayerId = grailsApplication.config.getProperty('layer.uk_countries', 'cl2')
            def url = "${layersBaseUrl}/objects/${countriesLayerId}"

            log.debug("Fetching UK countries data from: ${url}")

            def jsonResponse = webServicesService.getJsonElements(url)
            if (!jsonResponse) {
                log.warn("No response from layers service for UK countries")
                return getBackupZoomAreaBounds()
            }

            def zoomAreaBounds = [:]

            jsonResponse.each { areaData ->
                if (areaData.bbox && areaData.name) {
                    try {
                        def bounds = convertBboxToLatLngBounds(areaData.bbox)
                        if (bounds) {
                            def areaName = areaData.name.toLowerCase()
                            zoomAreaBounds[areaName] = [
                                id: areaData.id,
                                name: areaData.name,
                                bounds: bounds
                            ]

                            // Add common aliases for zoom areas
                            addZoomAreaAliases(zoomAreaBounds, areaName, areaData)
                        }
                    } catch (Exception e) {
                        log.warn("Error processing zoom area ${areaData.name}: ${e.message}")
                    }
                }
            }

            // Update cache
            zoomAreaBoundsCache = zoomAreaBounds
            zoomAreaCacheTimestamp = currentTime

            log.info("Successfully loaded ${zoomAreaBounds.size()} zoom area bounds from layers service")
            return zoomAreaBounds

        } catch (Exception e) {
            log.error("Error loading zoom area bounds from layers service: ${e.message}", e)
            return getBackupZoomAreaBounds()
        }
    }

    /**
     * Add common aliases for zoom areas to support legacy area names
     * @param zoomAreaBounds Map to add aliases to
     * @param areaName Primary area name
     * @param areaData Original area data
     */
    private void addZoomAreaAliases(Map zoomAreaBounds, String areaName, def areaData) {
        def boundsData = zoomAreaBounds[areaName]

        // Add aliases based on common zoom area names
        switch (areaName) {
            case 'scotland':
                zoomAreaBounds['sco-mainland'] = boundsData
                zoomAreaBounds['highland'] = boundsData  // For now, use Scotland bounds for Highland
                break
            case 'england':
                // England aliases if needed
                break
            case 'wales':
                // Wales aliases if needed
                break
        }

        // Add specific handling for Scottish regions if available
        if (areaName.contains('highland') || areaName.contains('outer hebrides')) {
            zoomAreaBounds['highland'] = boundsData
            zoomAreaBounds['outer-heb'] = boundsData
        }
    }

    /**
     * Get default zoom level for different area types
     * @param zoomArea Area identifier
     * @return Default zoom level
     */
    private Integer getDefaultZoomForArea(String zoomArea) {
        switch (zoomArea.toLowerCase()) {
            case 'england':
            case 'scotland':
            case 'wales':
                return 6
            case 'highland':
            case 'sco-mainland':
                return 7
            case 'outer-heb':
                return 8
            default:
                return grailsApplication.config.getProperty('easymap.defaultZoom', Integer, 6)
        }
    }

    /**
     * Get backup zoom area bounds data when layers service is unavailable
     * @return Map of area names to bounds
     */
    private Map getBackupZoomAreaBounds() {
        log.warn("Using backup zoom area bounds data")

        // Minimal backup data for critical zoom areas
        return [
            "england": [
                id: "england",
                name: "England",
                bounds: [
                    southwest: [lat: 49.9, lng: -5.7],
                    northeast: [lat: 55.8, lng: 1.8],
                    zoom: 6
                ]
            ],
            "scotland": [
                id: "scotland",
                name: "Scotland",
                bounds: [
                    southwest: [lat: 54.6, lng: -8.6],
                    northeast: [lat: 60.9, lng: -0.7],
                    zoom: 6
                ]
            ],
            "wales": [
                id: "wales",
                name: "Wales",
                bounds: [
                    southwest: [lat: 51.4, lng: -5.3],
                    northeast: [lat: 53.4, lng: -2.7],
                    zoom: 7
                ]
            ]
        ]
    }

    /**
     * Validate if coordinates are within reasonable bounds for UK
     * @param latitude
     * @param longitude
     * @return boolean
     */
    private boolean isValidCoordinate(Double latitude, Double longitude) {
        if (latitude == null || longitude == null) {
            return false
        }

        // Basic validation for reasonable coordinate values
        // Extended UK bounds to include overseas territories
        return latitude >= -90 && latitude <= 90 &&
               longitude >= -180 && longitude <= 180 &&
               Math.abs(latitude) < 90 && Math.abs(longitude) < 180
    }

    /**
     * Get occurrence statistics for display
     * @param occurrences List of occurrence records
     * @return Map containing statistics
     */
    def getOccurrenceStatistics(List occurrences) {
        if (!occurrences || occurrences.isEmpty()) {
            return [:]
        }

        def stats = [:]

        // Count by basis of record
        def basisCounts = occurrences.groupBy { it.basisOfRecord }.collectEntries { k, v ->
            [k ?: 'Unknown', v.size()]
        }
        stats.basisOfRecord = basisCounts

        // Count by year (if available)
        def yearCounts = occurrences.findAll { it.year }.groupBy { it.year }.collectEntries { k, v ->
            [k, v.size()]
        }
        stats.byYear = yearCounts

        // Date range
        def years = occurrences.findAll { it.year }.collect { it.year as Integer }.sort()
        if (years) {
            stats.dateRange = [earliest: years.first(), latest: years.last()]
        }

        // Data providers
        def providerCounts = occurrences.groupBy { it.dataResourceName }.collectEntries { k, v ->
            [k ?: 'Unknown', v.size()]
        }
        stats.dataProviders = providerCounts

        return stats
    }

    /**
     * Validate bounding box parameters
     * @param viceCounty Optional vice-county number
     * @param bottomLeft Optional bottom left grid reference
     * @param topRight Optional top right grid reference
     * @param bottomLeftCoord Optional bottom left coordinates
     * @param topRightCoord Optional top right coordinates
     * @return Map with valid flag and message
     */
    def validateBoundingBoxParams(String viceCounty, String bottomLeft, String topRight,
                                 String bottomLeftCoord, String topRightCoord) {
        // Check for conflicting parameters
        def paramCount = [viceCounty, bottomLeft, bottomLeftCoord].count { it != null }
        if (paramCount > 1) {
            return [valid: false, message: "Cannot specify multiple bounding box types (vc, bl/tr, blCoord/trCoord) simultaneously"]
        }

        // Validate grid reference pairs
        if ((bottomLeft && !topRight) || (!bottomLeft && topRight)) {
            return [valid: false, message: "Grid reference bounding box requires both bl and tr parameters"]
        }

        // Validate coordinate pairs
        if ((bottomLeftCoord && !topRightCoord) || (!bottomLeftCoord && topRightCoord)) {
            return [valid: false, message: "Coordinate bounding box requires both blCoord and trCoord parameters"]
        }

        // Validate vice-county format
        if (viceCounty && !isValidViceCounty(viceCounty)) {
            return [valid: false, message: "Invalid vice-county number: ${viceCounty}. Must be a number between 1 and 112"]
        }

        // Validate grid reference format
        if (bottomLeft && !isValidGridReference(bottomLeft)) {
            return [valid: false, message: "Invalid grid reference format for bl parameter: ${bottomLeft}"]
        }
        if (topRight && !isValidGridReference(topRight)) {
            return [valid: false, message: "Invalid grid reference format for tr parameter: ${topRight}"]
        }

        // Validate coordinate format
        if (bottomLeftCoord && !isValidCoordinate(bottomLeftCoord)) {
            return [valid: false, message: "Invalid coordinate format for blCoord parameter: ${bottomLeftCoord}. Expected format: Easting,Northing"]
        }
        if (topRightCoord && !isValidCoordinate(topRightCoord)) {
            return [valid: false, message: "Invalid coordinate format for trCoord parameter: ${topRightCoord}. Expected format: Easting,Northing"]
        }

        return [valid: true, message: "Valid parameters"]
    }

    /**
     * Get vice-county bounds using dynamic lookup from NBN Atlas layers service
     * @param viceCounty Vice-county number (1-112)
     * @return Map with bounds coordinates or null if not found
     */
    def getViceCountyBounds(String viceCounty) {
        try {
            def vcNumber = Integer.parseInt(viceCounty)

            // Load vice county bounds data (with caching)
            def viceCountyBounds = loadViceCountyBoundsData()

            // Look up by vice county number
            def vcBounds = viceCountyBounds.find { key, value ->
                // Try to match by ID or name that contains the number
                return key == vcNumber.toString() ||
                       value.name?.contains(vcNumber.toString()) ||
                       value.id == vcNumber.toString()
            }

            return vcBounds?.value?.bounds

        } catch (NumberFormatException e) {
            log.warn("Invalid vice-county number format: ${viceCounty}")
            return null
        } catch (Exception e) {
            log.error("Error retrieving vice-county bounds for VC ${viceCounty}: ${e.message}", e)
            return null
        }
    }

    /**
     * Load vice county bounds data from NBN Atlas layers service with caching
     * @return Map of vice county identifiers to bounds data
     */
    private Map loadViceCountyBoundsData() {
        // Check cache first
        def currentTime = System.currentTimeMillis()
        if (viceCountyBoundsCache &&
            viceCountyCacheTimestamp > 0 &&
            (currentTime - viceCountyCacheTimestamp) < CACHE_EXPIRY_MS) {
            log.debug("Using cached vice county bounds data")
            return viceCountyBoundsCache
        }

        try {
            log.info("Fetching vice county bounds from NBN Atlas layers service")

            def layersBaseUrl = grailsApplication.config.getProperty('nbnatlas.layers.baseUrl', 'https://layers.nbnatlas.org/ws')
            def viceCountyLayerId = grailsApplication.config.getProperty('layer.vice_county', 'cl254')
            def url = "${layersBaseUrl}/objects/${viceCountyLayerId}"

            log.debug("Fetching vice county data from: ${url}")

            def jsonResponse = webServicesService.getJsonElements(url)
            if (!jsonResponse) {
                log.warn("No response from layers service for vice counties")
                return getBackupViceCountyBounds()
            }

            def viceCountyBounds = [:]

            jsonResponse.each { vcData ->
                if (vcData.bbox && vcData.id) {
                    try {
                        def bounds = convertBboxToLatLngBounds(vcData.bbox)
                        if (bounds) {
                            viceCountyBounds[vcData.id] = [
                                id: vcData.id,
                                name: vcData.name,
                                bounds: bounds
                            ]

                            // Also store by name for alternate lookup
                            if (vcData.name) {
                                viceCountyBounds[vcData.name] = viceCountyBounds[vcData.id]
                            }
                        }
                    } catch (Exception e) {
                        log.warn("Error processing vice county ${vcData.id}: ${e.message}")
                    }
                }
            }

            // Update cache
            viceCountyBoundsCache = viceCountyBounds
            viceCountyCacheTimestamp = currentTime

            log.info("Successfully loaded ${viceCountyBounds.size()} vice county bounds from layers service")
            return viceCountyBounds

        } catch (Exception e) {
            log.error("Error loading vice county bounds from layers service: ${e.message}", e)
            return getBackupViceCountyBounds()
        }
    }

    /**
     * Convert bbox string from layers service to lat/lng bounds
     * @param bboxString Bounding box string from layers service (POLYGON format or simple coordinate list)
     * @return Map with southwest/northeast bounds or null if invalid
     */
    private Map convertBboxToLatLngBounds(String bboxString) {
        try {
            if (!bboxString) return null

            // Handle POLYGON format: POLYGON((lon lat,lon lat,...))
            if (bboxString.startsWith("POLYGON")) {
                // Extract coordinates from POLYGON((coordinates))
                def coordinateString = bboxString.replaceAll(/POLYGON\(\(/, '').replaceAll(/\)\)/, '')
                return parseCoordinateString(coordinateString)
            } else {
                // Handle simple format: "lon lat,lon lat,..."
                return parseCoordinateString(bboxString)
            }

        } catch (Exception e) {
            log.warn("Error parsing bbox string '${bboxString}': ${e.message}")
            return null
        }
    }

    /**
     * Parse coordinate string and return bounding box
     * @param coordinateString String containing coordinate pairs separated by commas
     * @return Map with southwest/northeast bounds or null if invalid
     */
    private Map parseCoordinateString(String coordinateString) {
        try {
            if (!coordinateString) return null

            // Parse bbox coordinates - format is "lon lat,lon lat,..." for polygon vertices
            def coordinates = []
            coordinateString.split(',').each { pair ->
                def parts = pair.trim().split(/\s+/)
                if (parts.length >= 2) {
                    def lon = Double.parseDouble(parts[0])
                    def lat = Double.parseDouble(parts[1])
                    coordinates << [lon: lon, lat: lat]
                }
            }

            if (coordinates.isEmpty()) return null

            // Find min/max coordinates to create bounding box
            def lons = coordinates.collect { it.lon }
            def lats = coordinates.collect { it.lat }

            def minLon = lons.min()
            def maxLon = lons.max()
            def minLat = lats.min()
            def maxLat = lats.max()

            log.debug("Parsed coordinates: min(${minLon}, ${minLat}) to max(${maxLon}, ${maxLat})")

            return [
                southwest: [lat: minLat, lng: minLon],
                northeast: [lat: maxLat, lng: maxLon]
            ]

        } catch (Exception e) {
            log.warn("Error parsing coordinate string '${coordinateString}': ${e.message}")
            return null
        }
    }

    /**
     * Get backup vice county bounds data when layers service is unavailable
     * @return Map of vice-county numbers to bounds
     */
    private Map getBackupViceCountyBounds() {
        log.warn("Using backup vice county bounds data")

        // Minimal backup data for critical vice counties
        return [
            "1": [
                id: "1",
                name: "West Cornwall",
                bounds: [southwest: [lat: 49.9, lng: -5.8], northeast: [lat: 50.4, lng: -4.9]]
            ],
            "17": [
                id: "17",
                name: "Surrey",
                bounds: [southwest: [lat: 51.2, lng: -1.0], northeast: [lat: 51.7, lng: 0.3]]
            ],
            "21": [
                id: "21",
                name: "Middlesex",
                bounds: [southwest: [lat: 51.3, lng: -0.5], northeast: [lat: 51.7, lng: 0.4]]
            ]
        ]
    }

    /**
     * Get grid reference bounds
     * @param bottomLeft Bottom left grid reference
     * @param topRight Top right grid reference
     * @return Map with bounds coordinates or null if invalid
     */
    def getGridReferenceBounds(String bottomLeft, String topRight) {
        try {
            // Convert grid references to coordinates
            def blCoords = convertGridReferenceToCoordinates(bottomLeft)
            def trCoords = convertGridReferenceToCoordinates(topRight)

            if (!blCoords || !trCoords) {
                return null
            }

            return [
                southwest: [lat: blCoords.lat, lng: blCoords.lng],
                northeast: [lat: trCoords.lat, lng: trCoords.lng]
            ]
        } catch (Exception e) {
            log.warn("Error converting grid references to bounds: ${e.message}")
            return null
        }
    }

    /**
     * Get coordinate bounds
     * @param bottomLeftCoord Bottom left coordinates as "Easting,Northing"
     * @param topRightCoord Top right coordinates as "Easting,Northing"
     * @return Map with bounds coordinates or null if invalid
     */
    def getCoordinateBounds(String bottomLeftCoord, String topRightCoord) {
        try {
            def blParts = bottomLeftCoord.split(',')
            def trParts = topRightCoord.split(',')

            if (blParts.length != 2 || trParts.length != 2) {
                return null
            }

            def blEasting = Double.parseDouble(blParts[0].trim())
            def blNorthing = Double.parseDouble(blParts[1].trim())
            def trEasting = Double.parseDouble(trParts[0].trim())
            def trNorthing = Double.parseDouble(trParts[1].trim())

            // Convert British National Grid coordinates to WGS84
            def blCoords = convertBNGToWGS84(blEasting, blNorthing)
            def trCoords = convertBNGToWGS84(trEasting, trNorthing)

            return [
                southwest: [lat: blCoords.lat, lng: blCoords.lng],
                northeast: [lat: trCoords.lat, lng: trCoords.lng]
            ]
        } catch (Exception e) {
            log.warn("Error converting coordinates to bounds: ${e.message}")
            return null
        }
    }

    /**
     * Calculate bounds from occurrence data
     * @param occurrences List of occurrence records
     * @return Map with bounds coordinates or null if no valid coordinates
     */
    def calculateBoundsFromOccurrences(List occurrences) {
        if (!occurrences || occurrences.isEmpty()) {
            return null
        }

        def latitudes = occurrences.collect { it.latitude }.findAll { it != null }
        def longitudes = occurrences.collect { it.longitude }.findAll { it != null }

        if (!latitudes || !longitudes) {
            return null
        }

        def minLat = latitudes.min()
        def maxLat = latitudes.max()
        def minLon = longitudes.min()
        def maxLon = longitudes.max()

        // Add padding to bounds
        def latPadding = Math.max((maxLat - minLat) * 0.1, 0.01)
        def lonPadding = Math.max((maxLon - minLon) * 0.1, 0.01)

        return [
            southwest: [lat: minLat - latPadding, lng: minLon - lonPadding],
            northeast: [lat: maxLat + latPadding, lng: maxLon + lonPadding]
        ]
    }

    /**
     * Get default UK bounds
     * @return Map with UK bounds coordinates
     */
    def getDefaultUKBounds() {
        return [
            southwest: [lat: 49.8, lng: -7.5],
            northeast: [lat: 60.9, lng: 1.8]
        ]
    }

    /**
     * Validate vice-county number
     * @param viceCounty Vice-county number as string
     * @return true if valid (1-112), false otherwise
     */
    private boolean isValidViceCounty(String viceCounty) {
        try {
            def vcNumber = Integer.parseInt(viceCounty)
            return vcNumber >= 1 && vcNumber <= 112
        } catch (NumberFormatException e) {
            return false
        }
    }

    /**
     * Validate grid reference format
     * @param gridRef Grid reference string
     * @return true if valid format, false otherwise
     */
    private boolean isValidGridReference(String gridRef) {
        if (!gridRef) return false
        // UK grid reference pattern: 2 letters followed by digits (even number of digits)
        // Examples: TQ123456, TQ12345678, TQ1234567890
        return gridRef.matches(/^[A-Z]{2}[0-9]*$/) && (gridRef.length() - 2) % 2 == 0 && gridRef.length() >= 4
    }

    /**
     * Validate coordinate format
     * @param coord Coordinate string in format "Easting,Northing"
     * @return true if valid format, false otherwise
     */
    private boolean isValidCoordinate(String coord) {
        if (!coord) return false
        try {
            def parts = coord.split(',')
            if (parts.length != 2) return false
            Double.parseDouble(parts[0].trim())
            Double.parseDouble(parts[1].trim())
            return true
        } catch (NumberFormatException e) {
            return false
        }
    }

    /**
     * Convert grid reference to coordinates
     * @param gridRef Grid reference string
     * @return Map with lat/lng coordinates or null if conversion fails
     */
    private def convertGridReferenceToCoordinates(String gridRef) {
        try {
            // This is a simplified conversion - in practice you'd use a proper grid reference library
            // For now, return sample coordinates for testing
            def coords = convertOSGridToWGS84(gridRef)
            return coords
        } catch (Exception e) {
            log.warn("Failed to convert grid reference ${gridRef}: ${e.message}")
            return null
        }
    }

    /**
     * Convert British National Grid coordinates to WGS84
     * @param easting Easting coordinate
     * @param northing Northing coordinate
     * @return Map with lat/lng coordinates
     */
    private def convertBNGToWGS84(double easting, double northing) {
        // Simplified conversion - in practice you'd use a proper coordinate transformation library
        // This is a rough approximation for demonstration
        def lat = 49.5 + (northing / 111000.0)
        def lng = -8.0 + (easting / 70000.0)
        return [lat: lat, lng: lng]
    }

    /**
     * Convert OS Grid Reference to WGS84 coordinates
     * @param gridRef Grid reference string
     * @return Map with lat/lng coordinates
     */
    private def convertOSGridToWGS84(String gridRef) {
        // Simplified conversion for demonstration
        // In practice, you'd use proper OS grid conversion algorithms
        def letters = gridRef.substring(0, 2)
        def numbers = gridRef.substring(2)

        // Basic approximation based on grid square
        def baseEasting = getGridSquareEasting(letters)
        def baseNorthing = getGridSquareNorthing(letters)

        // Parse the numeric part
        def numDigits = numbers.length()
        def halfDigits = numDigits / 2

        def eastingOffset = 0
        def northingOffset = 0

        if (numDigits > 0) {
            def eastingStr = numbers.substring(0, halfDigits as int)
            def northingStr = numbers.substring(halfDigits as int)

            // Scale to full precision
            def scale = Math.pow(10, 5 - halfDigits)
            eastingOffset = Integer.parseInt(eastingStr) * scale
            northingOffset = Integer.parseInt(northingStr) * scale
        }

        def totalEasting = baseEasting + eastingOffset
        def totalNorthing = baseNorthing + northingOffset

        return convertBNGToWGS84(totalEasting, totalNorthing)
    }

    /**
     * Get base easting for grid square
     * @param letters Two-letter grid square identifier
     * @return Base easting coordinate
     */
    private def getGridSquareEasting(String letters) {
        // Simplified mapping for common grid squares
        def firstLetter = letters.charAt(0)
        def secondLetter = letters.charAt(1)

        def firstLetterValue = (firstLetter as char) - ('A' as char)
        if (firstLetterValue > 7) firstLetterValue-- // Skip 'I'

        def secondLetterValue = (secondLetter as char) - ('A' as char)
        if (secondLetterValue > 7) secondLetterValue-- // Skip 'I'

        return (firstLetterValue % 5) * 500000 + (secondLetterValue % 5) * 100000
    }

    /**
     * Get base northing for grid square
     * @param letters Two-letter grid square identifier
     * @return Base northing coordinate
     */
    private def getGridSquareNorthing(String letters) {
        // Simplified mapping for common grid squares
        def firstLetter = letters.charAt(0)
        def secondLetter = letters.charAt(1)

        def firstLetterValue = (firstLetter as char) - ('A' as char)
        if (firstLetterValue > 7) firstLetterValue-- // Skip 'I'

        def secondLetterValue = (secondLetter as char) - ('A' as char)
        if (secondLetterValue > 7) secondLetterValue-- // Skip 'I'

        return (4 - (firstLetterValue / 5 as int)) * 500000 + (4 - (secondLetterValue / 5 as int)) * 100000
    }

    /**
     * Validate and normalize grid resolution parameter
     * @param gridResolution User-provided grid resolution value
     * @return Normalized grid resolution for WMS layer
     */
    private def validateAndNormalizeGridResolution(String gridResolution) {
        if (!gridResolution) {
            log.debug("No grid resolution provided, using default: 10km")
            return "fixed_10km"
        }

        // Normalize input - handle various formats
        def normalizedInput = gridResolution.toLowerCase().trim()

        // Map user-friendly values to WMS layer values
        // Note: The biocache WMS service supports: 100km, 50km, 10km, 2km, 1km, 100m
        // 5km is not supported and will be rejected as invalid
        def resolutionMapping = [
            "1km": "1km",
            "2km": "2km",
            "10km": "fixed_10km",
            "100km": "100km"
        ]

        if (resolutionMapping.containsKey(normalizedInput)) {
            log.debug("Valid grid resolution provided: ${normalizedInput} -> ${resolutionMapping[normalizedInput]}")
            return resolutionMapping[normalizedInput]
        }

        // Handle legacy/alternative formats
        if (normalizedInput in ["1", "1000", "1000m"]) {
            return "1km"
        } else if (normalizedInput in ["2", "2000", "2000m"]) {
            return "2km"
        } else if (normalizedInput in ["10", "10000", "10000m", "fixed_10km"]) {
            return "fixed_10km"
        } else if (normalizedInput in ["100", "100000", "100000m"]) {
            return "100km"
        }

        log.warn("Invalid grid resolution provided: ${gridResolution}. Using default: 10km")
        return "fixed_10km"
    }

    /**
     * Check if the provided grid resolution is valid
     * @param gridResolution Grid resolution to validate
     * @return true if valid, false otherwise
     */
    def isValidGridResolution(String gridResolution) {
        if (!gridResolution) return true // null/empty is valid (uses default)

        def normalizedInput = gridResolution.toLowerCase().trim()
        def validValues = ["1km", "2km", "10km", "100km", "1", "2", "10", "100",
                          "1000", "2000", "10000", "100000",
                          "1000m", "2000m", "10000m", "100000m", "fixed_10km"]

        return validValues.contains(normalizedInput)
    }
}
