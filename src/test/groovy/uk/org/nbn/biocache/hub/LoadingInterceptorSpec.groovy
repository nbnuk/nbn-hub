package uk.org.nbn.biocache.hub


import grails.test.mixin.TestFor
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.web.ControllerUnitTestMixin} for usage instructions
 */
@TestFor(LoadingInterceptor)
class LoadingInterceptorSpec extends Specification {

    def setup() {
    }

    def cleanup() {

    }

    void "Test loading interceptor matching"() {
        when:"A request matches the interceptor"
            withRequest(controller:"loading")

        then:"The interceptor does match"
            interceptor.doesMatch()
    }
}
