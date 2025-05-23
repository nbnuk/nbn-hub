package uk.org.nbn.biocache.hubs


class AccessControlInterceptor {
    def authService

    boolean before() {
        if (!authService?.userInRole('ROLE_ADMIN') && !!authService?.userInRole('ROLE_COLLECTION_EDITOR')) {
            log.debug "User not authorised to access the page: ${params.controller}/${params.action ?: ''}. Redirecting to index."
            flash.message = "You are not authorised to access the page: ${params.controller}/${params.action ?: ''}."
            redirect(controller: "home", action: "index")
            false
        }
        true
    }

    boolean after() { true }

    void afterView() {
        // no-op
    }
}
