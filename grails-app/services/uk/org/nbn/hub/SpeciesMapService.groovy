package uk.org.nbn.hub

import grails.converters.JSON
import groovy.util.logging.Slf4j

@Slf4j
class SpeciesMapService {

    def grailsApplication
    def webService

    def getSpeciesInfo(String tvk) {
        return [tvk: tvk, scientificName: 'Test Species']
    }

    def getOccurrenceData(String tvk) {
        return []
    }

    def prepareMapConfig(List occurrences) {
        return [defaultLatitude: 54.5, defaultLongitude: -3.0, defaultZoom: 6]
    }
}
