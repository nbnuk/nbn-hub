package uk.org.nbn.biocache.hub


class LoadingInterceptor {
    LoadingInterceptor() {
        match(controller: 'occurrence', action:"list")
    }

    boolean before() {
        //loading spinner is only supported for GET requests (for now). Most are GET
        String userAgent = request.getHeader("User-Agent");
        if (request.get && !params.get("nbn_loading") && userAgent.indexOf("UptimeRobot")<0) {
            String url = request.requestURI+"?"+request.queryString+"&nbn_loading=true";
            render(view: "../loading", model:[url:url])
            return false
        }
        return true


    }

    boolean after() { true }

    void afterView() {
        // no-op
    }
}
