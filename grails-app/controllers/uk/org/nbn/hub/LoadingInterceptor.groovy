package uk.org.nbn.hub

import javax.servlet.http.Cookie


class LoadingInterceptor {
    LoadingInterceptor() {
        match(controller: 'occurrence', action:"list")
    }

    boolean before() {
        //loading spinner is only supported for GET requests (for now). Most are GET
        String userAgent = request.getHeader("User-Agent");
        boolean loadingCookie = request.cookies?.any {
            it.name == "nbn_loading" && it.value == "true"
        }
        if (request.get && !loadingCookie && userAgent.indexOf("UptimeRobot")<0) {
            render(view: "../loading")
            return false
        }
        def c = new Cookie("nbn_loading", "")
        c.path = "/"
        c.maxAge = 0
        response.addCookie(c)
        return true


    }

    boolean after() { true }

    void afterView() {
        // no-op
    }
}
