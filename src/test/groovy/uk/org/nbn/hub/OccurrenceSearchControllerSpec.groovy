package uk.org.nbn.hub

import grails.test.mixin.TestFor
import spock.lang.Specification
import uk.org.nbn.hub.OccurrenceSearchController

/**
 * See the API for {@link grails.test.mixin.web.ControllerUnitTestMixin} for usage instructions
 */
@TestFor(OccurrenceSearchController)
class OccurrenceSearchControllerSpec extends Specification {

    void "searchByOccurrenceID adds disableAllQualityFilters"() {
        when:
        controller.searchByOccurrenceID("abc-123")

        then:
        response.redirectedUrl == "/occurrences/search?q=occurrence_id%3Aabc-123&disableAllQualityFilters=true"
    }

//    void "test something"() {
//        expect:"fix me"
//            true == false
//    }
}
