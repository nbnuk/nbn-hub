package uk.org.nbn.hub

class SpeciesMapController {

    def speciesMapService

    static allowedMethods = [
        show: 'GET',
        index: 'GET'
    ]

    def show(String tvk) {
        log.info("Species map requested for TVK: ${tvk}")

        if (!tvk || !isValidTVK(tvk)) {
            log.warn("Invalid TVK format provided: ${tvk}")
            response.status = 400
            render(view: 'error', model: [
                message: "Invalid TVK format: ${tvk}",
                tvk: tvk
            ])
            return
        }

        try {
            def speciesInfo = speciesMapService.getSpeciesInfo(tvk)
            if (!speciesInfo) {
                log.warn("Species not found for TVK: ${tvk}")
                response.status = 404
                render(view: 'notFound', model: [
                    message: "Species not found for TVK: ${tvk}",
                    tvk: tvk
                ])
                return
            }

            def occurrenceData = speciesMapService.getOccurrenceData(speciesInfo.acceptedTvk ?: tvk)
            def mapConfig = speciesMapService.prepareMapConfig(occurrenceData)

            log.info("Successfully prepared species map for ${speciesInfo.scientificName}")

            [
                tvk: tvk,
                species: speciesInfo,
                occurrences: occurrenceData,
                mapConfig: mapConfig
            ]

        } catch (Exception e) {
            log.error("Error preparing species map for TVK ${tvk}: ${e.message}", e)
            response.status = 500
            render(view: 'error', model: [
                message: "Error loading species map",
                tvk: tvk
            ])
        }
    }

    def index() {
        log.info("Species map index page requested")
        [message: "Welcome to Species Map"]
    }

    private boolean isValidTVK(String tvk) {
        if (!tvk) return false
        return tvk.matches(/^[A-Z0-9]{10,}$/) || tvk.startsWith('NBNSYS')
    }
}
