package uk.org.nbn.hub


class OccurrenceInterceptor {
    OccurrenceInterceptor() {
//        match(controller: 'occurrence', action:"list")
        match(action:"list")
    }

    boolean before() {
        true
    }

    boolean after() {
        if (model && model.sr) {
            if ("ERROR".equals(model.sr.status)) {
                render(view: "../errorStatus", model: [errorMessage: model.sr.errorMessage])
                return false;
            }
        }
        return true
    }

    void afterView() {
        // no-op
    }
}
