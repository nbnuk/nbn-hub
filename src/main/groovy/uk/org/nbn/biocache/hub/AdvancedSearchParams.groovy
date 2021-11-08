/*
 * Copyright (C) 2014 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */
package uk.org.nbn.biocache.hub

import grails.validation.Validateable
import groovy.util.logging.Slf4j
import org.apache.commons.httpclient.URIException
import org.apache.commons.httpclient.util.URIUtil
import org.apache.commons.lang.StringUtils
import org.grails.web.util.WebUtils

/**
 * Request parameters for the advanced search form (form backing bean)
 *
 */
//@Validateable
@Slf4j
class AdvancedSearchParams implements Validateable {
    String[] taxonText=[];
    String nameType = ""
    String[] basisOfRecord = []
    String identificationVerificationStatus = ""
    String identifiedBy = ""
    String gridReferenceType =""
    String gridReference = ""
    String licenceType = ""
    String[] selectedLicence = []
    String recordedBy = ""
    String dateType = ""
    String yearRange = ""
    String year = ""
    String month = ""
    String day = ""
    String annotations = ""
    String dataProviderUID =""


    private String taxa = ""
    private final String QUOTE = "\""
    private final String BOOL_OP = "AND"

    /**
     * This custom toString method outputs a valid /occurrence/search query string.
     *
     * @return q
     */
    @Override
    public String toString() {


        List queryItems = []
        String queryItem;

        queryItem = buildBasisOfRecordQuery(basisOfRecord);
        if (queryItem) queryItems.add(queryItem)

        queryItem =  buildIdentificationVerificationStatusQuery(identificationVerificationStatus);
        if (queryItem) queryItems.add(queryItem)

        queryItem = buildIdentifiedByQuery(identifiedBy);
        if (queryItem) queryItems.add(queryItem)

        queryItem = buildGridReferenceQuery(gridReferenceType, gridReference);
        if (queryItem) queryItems.add(queryItem)

        queryItem = buildLicenceQuery(licenceType, selectedLicence);
        if (queryItem) queryItems.add(queryItem)

        queryItem = buildRecordedByQuery(recordedBy);
        if (queryItem) queryItems.add(queryItem)

        queryItem  = buildDateQuery(dateType, yearRange, year, month, day);
        if (queryItem) queryItems.add(queryItem)

        queryItem = buildAnnotationsQuery(annotations)
        if (queryItem) queryItems.add(queryItem)

        queryItem = buildDataProviderQuery(dataProviderUID);
        if (queryItem) queryItems.add(queryItem)



        ArrayList<String> taxas = new ArrayList<String>()

        // iterate over the taxa search inputs and if lsid is set use it otherwise use taxa input
        taxonText.each { tt ->
            if (tt) {
                taxas.add(stripChars(quoteText(tt)));
            }
        }

        // if more than one taxa query, add braces so we get correct Boolean precedence
        String[] braces = ["",""]
        if (taxas.size() > 1) {
            braces[0] = "("
            braces[1] = ")"
        }

        if (taxas) {
            log.debug "taxas = ${taxas} || nameType = ${nameType}"

            if (nameType == "taxa") {
                // special case
                taxa = StringUtils.join(taxas*.trim(), " OR " ).replaceAll('"','') // remove quotes which break the "taxa=foo bar" query type
            } else {
                // build up OR'ed taxa query with braces if more than one taxon
                queryItems.add(braces[0] + nameType + ":")
                queryItems.add(StringUtils.join(taxas, " OR " + nameType + ":") + braces[1])
            }
        }

        String encodedQ = queryItems.join(" ${BOOL_OP} ").toString().trim()
        String encodedTaxa = taxa.trim()

        try {
            // attempt to do query encoding
            encodedQ = URIUtil.encodeWithinQuery(encodedQ.replaceFirst("\\?", ""))
            encodedTaxa = URIUtil.encodeWithinQuery(taxa.trim())
        } catch (URIException ex) {
            log.error("URIUtil error: " + ex.getMessage(), ex)
        }

        String finalQuery = ((taxa) ? "taxa=" + encodedTaxa + "&" : "") + ((encodedQ) ? "q=" + encodedQ : "")
        log.debug("query: " + finalQuery)

        return finalQuery
    }

    /**
     * Get the queryString in the form of a Map - for use with 'params' attribute
     * in redirect, etc.
     *
     * @return
     */
    public Map toParamMap() {
        WebUtils.fromQueryString(toString())
    }

    /**
     * Strip unwanted characters from input string
     *
     * @param withCharsToStrip
     * @return
     */
    private String stripChars(String withCharsToStrip){
        if(withCharsToStrip!=null){
            return withCharsToStrip.replaceAll("\\.","")
        }
        return null
    }


    /**
     * Surround phrase search with quotes
     *
     * @param text
     * @return
     */
    private String quoteText(String text) {
        if (StringUtils.contains(text, " ")) {
            text = QUOTE + text + QUOTE
        }

        return text
    }


    private String buildBooleanQuerySegment(String[] values, String fieldName, String booleanType) {
        return "("+fieldName+":"+values.join(" "+booleanType+" "+fieldName+":")+")"
    }

    private String buildIdentificationVerificationStatusQuery(String identificationVerificationStatus) {
        String query="";
        if ("ACCEPTED".equals(identificationVerificationStatus)) {
            query = "(identification_verification_status:\"Accepted\" OR identification_verification_status:\"Accepted - correct\" OR " +
                    "identification_verification_status:\"Accepted - considered correct\")"
        }
        else if ("UNCONFIRMED".equals(identificationVerificationStatus)){
            query = "(identification_verification_status:\"Unconfirmed\" OR identification_verification_status:\"Unconfirmed - plausible\" OR " +
                    "identification_verification_status:\"Unconfirmed - not reviewed\")"
        }
        return query;
    }

    private String buildDateQuery(String dateType, String yearRange, String year, String month, String day) {
        String query="";
        if ("YEAR_RANGE".equals(dateType)) {
            String[] years = yearRange.split(",");
            query = "occurrence_date:["+years[0]+"-01-01T00:00:00Z"+" TO "+years[1]+"-12-31T23:59:59Z]";
        }
        else {
            if (year && !month && !day) {
                query = "year:"+year;
            }
            else if (!year && month && !day) {
                query = "month:"+month;
            }
            else if (year && month && day) {
                query = "occurrence_date:["+year+"-"+month+"-"+day+"T00:00:00Z"+" TO "+year+"-"+month+"-"+day+"T23:59:59Z]"
            }

        }
        return query;
    }



    private String buildAnnotationsQuery(String annotations) {
        String query = "";
        if ("EXCLUDE_ANNOTATIONS".equals(annotations)) {
            query = "!user_assertions:[* TO *]"
        }
    }

    private String buildLicenceQuery(String licenceType, String[] selectedLicence) {
        String query="";
        if ("OPEN".equals(licenceType)){
            query = "(license:CC-BY OR license:CC0 OR license:OGL)"
        }
        else if ("SELECTED".equals(licenceType)){
            if (selectedLicence.length && selectedLicence.length<4) {
                query = buildBooleanQuerySegment(selectedLicence, "license", "OR")
            }
        }
        return query

    }

    private String buildGridReferenceQuery(String gridReferenceType, String gridReference) {
        String query="";

        if (gridReference) {
            if ("IRISH".equals(gridReferenceType)) {
                query = buildGridReferenceIrish(gridReference);
            }
            else {
                query = buildGridReferenceGB(gridReference);
            }
        }
        return query;
    }

    private String buildGridReferenceGB(gridReference) {
        String query = "";
        switch (gridReference.length()) {
            case 4:
                query = "grid_ref_10000:" + gridReference;
                break;
            case 5:
                query = "grid_ref_2000:" + gridReference;
                break;
            case 6:
                query = "grid_ref_1000:" + gridReference;
                break;
            case 8:
                query = "grid_ref_100:" + gridReference;
                break;
        }
        return query;
    }

    private String buildGridReferenceIrish(gridReference) {
        String query = "";
        switch (gridReference.length()) {
            case 3:
                query = "grid_ref_10000:" + gridReference;
                break;
            case 4:
                query = "grid_ref_2000:" + gridReference;
                break;
            case 5:
                query = "grid_ref_1000:" + gridReference;
                break;
            case 7:
                query = "grid_ref_100:" + gridReference;
                break;
        }
        return query;
    }


    private String buildBasisOfRecordQuery(String[] basisOfRecord){
        return (basisOfRecord?.length && basisOfRecord.length<5)?buildBooleanQuerySegment(basisOfRecord, "basis_of_record", "OR"):"";

    }

    private String buildRecordedByQuery(String recordedBy){
        return recordedBy?"collector_text:"+recordedBy+"~":"";
    }

    private String buildIdentifiedByQuery(String identifiedBy){
        return identifiedBy?"identified_by:"+identifiedBy+"~":"";
    }

    private String buildDataProviderQuery(String dataProviderUID){
        return dataProviderUID?"data_provider_uid:"+dataProviderUID:"";
    }


}
