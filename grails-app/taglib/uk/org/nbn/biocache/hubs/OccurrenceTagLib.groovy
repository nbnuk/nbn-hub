package uk.org.nbn.biocache.hubs

import groovy.xml.MarkupBuilder
import org.apache.commons.lang.StringUtils
import org.grails.web.util.WebUtils

class OccurrenceTagLib extends au.org.ala.biocache.hubs.OccurrenceTagLib{

    static namespace = 'alatag'

    /**
     * Output a row (occurrence record) in the search results "Records" tab
     *
     * @attr occurrence REQUIRED
     */
    //Override
    def formatListRecordRow = { attrs ->

        def occurrence = attrs.occurrence
        def mb = new MarkupBuilder(out)
        def outputResultsLabel = { cssClass, label, value, test ->
            if (test) {
                mb.span(class:'resultValue ' + cssClass) {
                    span(class:'resultsLabel') {
                        mkp.yieldUnescaped(label + ": ")
                    }
                    mkp.yieldUnescaped(value)
                }
            }
        }

        def outputDynamicResultsLabel = { label, value, test ->
            if (test) {
                mb.span(class:'resultValue ' + label) {
                    span(class:'resultsLabel') {
                        mkp.yieldUnescaped(formatDynamicLabel(label))
                    }
                    span(class:'resultsValue'){
                        mkp.yieldUnescaped(value)
                    }
                }
            }
        }

        mb.div(class:'recordRow', id:occurrence.uuid ) {
            p(class:'rowA') {
                if (occurrence.taxonRank && occurrence.scientificName) {
                    span(style:'text-transform: capitalize', occurrence.taxonRank)
                    mkp.yieldUnescaped(":&nbsp;")
                    span(class:'occurrenceNames') {
                        mkp.yieldUnescaped(alatag.formatSciName(rankId:occurrence.taxonRankID?:'6000', name:"${occurrence.scientificName}"))
                    }
                } else if(occurrence.raw_scientificName){
                    span(class:'occurrenceNames', occurrence.raw_scientificName)
                }

                if (occurrence.vernacularName || occurrence.raw_vernacularName) {
                    mkp.yieldUnescaped("&nbsp;|&nbsp;")
                    span(class:'occurrenceNames', occurrence.vernacularName?:occurrence.raw_vernacularName)
                }

                span(class:'eventAndLocation') {
                    if (occurrence.eventDate) {
                        outputResultsLabel('eventdate', alatag.message(code:"record.eventdate.label"), g.formatDate(date: new Date(occurrence.eventDate), format:"yyyy-MM-dd"), true)
                    } else if (occurrence.year) {
                        outputResultsLabel('year', alatag.message(code:"record.year.label"), occurrence.year, true)
                    }

                    if (StringUtils.containsIgnoreCase( (occurrence?.miscStringProperties?.occurrence_status_s?:''), 'absent' )) {
                        mkp.yieldUnescaped(" (absent) ")
                    }
                    if (occurrence.stateProvince) {
                        mkp.yieldUnescaped(occurrence.stateProvince)
                        //outputResultsLabel('state', alatag.message(code:"record.state.label"), alatag.message(code:occurrence.stateProvince), true)
                    } else if (occurrence.country) {
                        outputResultsLabel('country', alatag.message(code:"record.country.label"), alatag.message(code:occurrence.country), true)
                    }
                }

                span(class:'gridReference') {
                    if (occurrence.gridReference) {
                        outputResultsLabel("osgr", "OSGR", occurrence.gridReference, true)
                    }
                }

                if (!occurrence.sensitive && (occurrence.publicResolutionInMeters && occurrence.publicResolutionInMeters !="0")) {
                    mkp.yieldUnescaped("&nbsp;|&nbsp;")
                    span(class:'accessControlled'){
                        mkp.yield("public resolution "+formatMetersInner(occurrence.publicResolutionInMeters))
                        mkp.yieldUnescaped(" <i class=\"glyphicon glyphicon-lock\" style=\"font-size: smaller; color:red;margin-right:4px\"></i>")
                    }
//                    span(class:'accessControlled', "public resolution "+occurrence.publicResolutionInMeters+" <a href='#' class='accessControlHelpLink' data-toggle='popover' data-publicResolutionInMeters='${occurrence.publicResolutionInMeters}' data-dataProviderUid='${occurrence.dataProviderUid}' data-dataProviderName='${occurrence.dataProviderName}'><i class='icon-question-sign'></i></a>")
                }

                span(class:'openAssertions') {
                    def user_assert = occurrence.hasUserAssertions?:"0"
                    if (user_assert != "0") {
                        log.info("user_assert for:" + occurrence.toString())
                    }
                    if ((grailsApplication.config.flagAnIssue?.show?: 'false').toBoolean()) {
                        if (user_assert == "50005" || user_assert == "50001") { //only flag open or uncorrected issues
                            mkp.yieldUnescaped("<i class='glyphicon glyphicon-flag' style='color:red;display:inline-block'></i>")
                        }
                    }
                }

                // display dynamic fields
                if(grailsApplication.config.table.displayDynamicProperties?.toString()?.toBoolean()) {
                    span(class: 'dynamicValues') {
                        def count = 0
                        occurrence.miscStringProperties.each { key, value ->
                            if (count < maxDynamicProperties) {
                                if(value && value.length < maxDynamicPropertyLength) {
                                    outputDynamicResultsLabel(key + ": ", value, true)
                                }
                                count++
                            }
                        }
                        occurrence.miscIntProperties.each { key, value ->
                            if (count < maxDynamicProperties) {
                                outputDynamicResultsLabel(key + ": ", value, true)
                                count++
                            }
                        }
                        occurrence.miscDoubleProperties.each { key, value ->
                            if (count < maxDynamicProperties) {
                                outputDynamicResultsLabel(key + ": ", value, true)
                                count++
                            }
                        }
                    }
                }
            }

            p(class:'rowB') {
                outputResultsLabel('institutionName', alatag.message(code:"record.institutionName.label"), alatag.message(code:occurrence.institutionName), occurrence.institutionName)
                outputResultsLabel('collectionName', alatag.message(code:"record.collectionName.label"), alatag.message(code:occurrence.collectionName), occurrence.collectionName)
                outputResultsLabel('dataResourceName', alatag.message(code:"record.dataResourceName.label"), alatag.message(code:occurrence.dataResourceName), !occurrence.collectionName && occurrence.dataResourceName)
                outputResultsLabel('basisofrecord', alatag.message(code:"record.basisofrecord.label"), alatag.message(code:occurrence.basisOfRecord), occurrence.basisOfRecord)
                outputResultsLabel('catalognumber', alatag.message(code:"record.catalogNumber.label"), "${occurrence.raw_collectionCode ? occurrence.raw_collectionCode + ':' : ''}${occurrence.raw_catalogNumber}", occurrence.raw_catalogNumber)
                a(
                        href: g.createLink(url:"${request.contextPath}/occurrences/${occurrence.uuid}"),
                        class:"occurrenceLink",
                        alatag.message(code:"record.view.record")
                )
            }
        }
    }

    /**
     * Generate a query string for the remove spatial filter link
     */
    //Override
    def getQueryStringForWktRemove = { attr ->
        def paramsCopy = params.clone()
        paramsCopy.remove("wkt")
        paramsCopy.remove("action")
        paramsCopy.remove("controller")
        def fqMultiQueryString = ""
        if (paramsCopy.get("fq") != null && paramsCopy.get("fq").getClass().isArray()) {
            //this is a workaround for the contents of a the fq parameter being an array instead of another mapo (which I think would be handled by toQueryString by recursion)
            paramsCopy.get("fq").each {
                fqMultiQueryString = fqMultiQueryString + "&fq=" +
                        URLEncoder.encode(it.value.toString(), "UTF-8")
            }
            paramsCopy.remove("fq")
        }
        def queryString = WebUtils.toQueryString(paramsCopy) + fqMultiQueryString
        log.debug "queryString = ${queryString}"
        out << queryString
    }

    def simpleResultCount = { attrs, body ->
        def mb = new MarkupBuilder(out)

            mb.span(id:'returnedText') {
                strong g.formatNumber(number: "${attrs.totalRecords}", format: "#,###,###")
                span alatag.message(code:"list.resultsreturned.span.returnedtext1", default:'results for')
            }

    }

    def formatMeters = { attrs, body ->
        def mb = new MarkupBuilder(out)
        mb.yield(formatMetersInner(attrs.distance))
//        def distance = attrs.distance
//        if (distance > 1000) {
//            mb.yield(g.formatNumber(number: distance/1000, format: "#,###,###") + "km")
//        } else {
//            mb.yield(g.formatNumber(number: distance, format: "#,###,###") + "m")
//        }
    }

    private String formatMetersInner(distance){
        if (distance > 1000) {
            g.formatNumber(number: distance/1000, format: "#,###,###") + "km"
        } else {
            g.formatNumber(number: distance, format: "#,###,###") + "m"
        }
    }
}
