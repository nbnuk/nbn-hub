package uk.org.nbn.hub

class HubInterceptor {

    HubInterceptor() {
        matchAll()
    }

    boolean before() {
        request.setAttribute("HUB", HubType.valueOfServerName(request.serverName))
        if (request.session.getAttribute("HUB")) {
            request.setAttribute("HUB", request.session.getAttribute("HUB"))
        }
        true
    }

    boolean after() { true }

    void afterView() {
        // no-op
    }
}
