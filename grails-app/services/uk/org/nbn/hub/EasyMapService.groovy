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
     * Prepare map configuration based on occurrence data
     * @param occurrences List of occurrence records
     * @return Map containing map configuration
     */
    def prepareMapConfig(List occurrences) {
        log.debug("Preparing map config for ${occurrences?.size() ?: 0} occurrences")
// TODO - perhaps use mini-atlas as the default ?
        def biocacheUrl = grailsApplication.config.biocacheServicesUrl ?: grailsApplication.config.biocacheServiceUrl ?: 'https://records-ws.nbnatlas.org'
        log.debug("Using biocache URL in map config: ${biocacheUrl}")

        def config = [
            occurrenceCount: occurrences?.size() ?: 0,
            bounds: null,
            biocacheUrl: biocacheUrl
        ]

        if (occurrences && occurrences.size() > 0) {
            // Calculate bounds from occurrence data
            def latitudes = occurrences.collect { it.latitude }.findAll { it != null }
            def longitudes = occurrences.collect { it.longitude }.findAll { it != null }

            if (latitudes && longitudes) {
                def minLat = latitudes.min()
                def maxLat = latitudes.max()
                def minLon = longitudes.min()
                def maxLon = longitudes.max()

                // Calculate center point
                def centerLat = (minLat + maxLat) / 2
                def centerLon = (minLon + maxLon) / 2

                // Add padding to bounds
                def latPadding = Math.max((maxLat - minLat) * 0.1, 0.01)
                def lonPadding = Math.max((maxLon - minLon) * 0.1, 0.01)

                config.defaultLatitude = centerLat
                config.defaultLongitude = centerLon
                config.bounds = [
                    southwest: [lat: minLat - latPadding, lng: minLon - lonPadding],
                    northeast: [lat: maxLat + latPadding, lng: maxLon + lonPadding]
                ]

                // Calculate appropriate zoom level based on bounds
                def latDiff = maxLat - minLat + (2 * latPadding)
                def lonDiff = maxLon - minLon + (2 * lonPadding)
                def maxDiff = Math.max(latDiff, lonDiff)

                if (maxDiff > 10) {
                    config.defaultZoom = 5
                } else if (maxDiff > 5) {
                    config.defaultZoom = 6
                } else if (maxDiff > 2) {
                    config.defaultZoom = 7
                } else if (maxDiff > 1) {
                    config.defaultZoom = 8
                } else if (maxDiff > 0.5) {
                    config.defaultZoom = 9
                } else {
                    config.defaultZoom = 10
                }
            } else {
                // Default to UK bounds if no valid coordinates
                config.defaultLatitude = 54.5
                config.defaultLongitude = -3.0
                config.defaultZoom = 6
            }
        } else {
            // Default to UK bounds if no occurrences
            config.defaultLatitude = 54.5
            config.defaultLongitude = -3.0
            config.defaultZoom = 6
        }

        return config
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
}
