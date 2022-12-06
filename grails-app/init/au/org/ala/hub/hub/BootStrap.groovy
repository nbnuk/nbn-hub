package au.org.ala.hub.hub

import au.org.ala.biocache.hubs.SearchRequestParams

class BootStrap {
    def grailsApplication

    def init = { servletContext ->
        log.info "config.security.cas = ${grailsApplication.config.security.cas}"
        log.info "config.ala.skin = ${grailsApplication.config.ala.skin}"
        log.info "config.biocache.ajax.useProxy = ${grailsApplication.config.biocache.ajax.useProxy}"
        log.warn "config.serverName = ${grailsApplication.config.serverName}"
        log.warn "config.grails.serverURL = ${grailsApplication.config.grails.serverURL}"
        log.warn "config.headerAndFooter.baseURL = ${grailsApplication.config.headerAndFooter.baseURL}"

        //set the configured default locale
        Locale.setDefault(Locale.forLanguageTag(grailsApplication.config.defaultLocale?:'en'))

        initSearchRequestParams();
    }
    def destroy = {
    }

    static def initSearchRequestParams = {
        SearchRequestParams.metaClass.nbnRequiredFacets = [] as String[]
    }
}
