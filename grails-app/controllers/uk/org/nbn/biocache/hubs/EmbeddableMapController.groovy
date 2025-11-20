package uk.org.nbn.biocache.hubs

class EmbeddableMapController {
    def embeddableMap() {
        log.info "Embeddable map params: ${params}"

        render(view: "/embed/_embeddableMap", model: [initialParams: params])
    }
}