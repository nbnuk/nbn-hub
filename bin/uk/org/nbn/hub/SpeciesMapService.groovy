package uk.org.nbn.hub

import grails.converters.JSON
import groovy.util.logging.Slf4j
import org.grails.web.json.JSONArray
import org.grails.web.json.JSONObject

@Slf4j
class SpeciesMapService {

    def grailsApplication
    def webService

    /**
     * Get species information from BIE service using TVK
     * @param tvk The Taxon Version Key
     * @return Map containing species information
     */
    def getSpeciesInfo(String tvk) {
        log.debug("Retrieving species info for TVK: ${tvk}")

        try {
            // First, try to get the species by TVK directly
            def bieUrl = "${grailsApplication.config.bieService.baseUrl}/species/${tvk.encodeAsURL()}"
            log.debug("Calling BIE service: ${bieUrl}")

            def jsonResponse = webService.getJson(bieUrl)

            if (jsonResponse && !jsonResponse.isEmpty()) {
                return [
                    tvk: tvk,
                    acceptedTvk: jsonResponse.acceptedConceptID ?: tvk,
                    scientificName: jsonResponse.scientificName ?: jsonResponse.nameComplete,
                    commonName: jsonResponse.commonName ?: jsonResponse.vernacularName,
                    rank: jsonResponse.rank ?: jsonResponse.taxonRank,
                    guid: jsonResponse.guid,
                    kingdom: jsonResponse.kingdom,
                    phylum: jsonResponse.phylum,
                    classs: jsonResponse.classs,
                    order: jsonResponse.order,
                    family: jsonResponse.family,
                    genus: jsonResponse.genus,
                    speciesGroup: jsonResponse.speciesGroup,
                    datasetName: jsonResponse.datasetName,
                    parentGuid: jsonResponse.parentGuid,
                    acceptedConceptName: jsonResponse.acceptedConceptName,
                    nameAuthority: jsonResponse.nameAuthority,
                    taxonomicStatus: jsonResponse.taxonomicStatus,
                    conservationStatus: jsonResponse.conservationStatus,
                    imageUrl: jsonResponse.image ?: jsonResponse.smallImageUrl,
                    thumbnailUrl: jsonResponse.thumbnailUrl ?: jsonResponse.smallImageUrl
                ]
            } else {
                log.warn("No species information found for TVK: ${tvk}")
                return null
            }

        } catch (Exception e) {
            log.error("Error retrieving species info for TVK ${tvk}: ${e.message}", e)
            return null
        }
    }

    /**
     * Get occurrence data from Biocache service for a given TVK
     * @param acceptedTvk The accepted TVK to search for
     * @return List of occurrence records
     */
    def getOccurrenceData(String acceptedTvk) {
        log.debug("Retrieving occurrence data for TVK: ${acceptedTvk}")

        try {
            // Build search parameters for biocache
            def searchParams = [
                q: "lsid:${acceptedTvk}",
                facets: "basis_of_record",
                pageSize: 500,  // Limit for map display
                fl: "id,latitude,longitude,eventDate,basisOfRecord,dataResourceUid,dataResourceName,recordedBy,locality,stateProvince,coordinateUncertaintyInMeters,year,month,day,scientificName,commonName,family,order,class,phylum,kingdom",
                sort: "eventDate",
                dir: "desc"
            ]

            def queryString = searchParams.collect { k, v -> "${k}=${v.toString().encodeAsURL()}" }.join('&')
            def biocacheUrl = "${grailsApplication.config.biocache.baseUrl}/occurrences/search?${queryString}"

            log.debug("Calling Biocache service: ${biocacheUrl}")

            def jsonResponse = webService.getJson(biocacheUrl)

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
            return []
        }
    }

    /**
     * Prepare map configuration based on occurrence data
     * @param occurrences List of occurrence records
     * @return Map containing map configuration
     */
    def prepareMapConfig(List occurrences) {
        log.debug("Preparing map config for ${occurrences?.size() ?: 0} occurrences")

        def config = [
            occurrenceCount: occurrences?.size() ?: 0,
            bounds: null
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
