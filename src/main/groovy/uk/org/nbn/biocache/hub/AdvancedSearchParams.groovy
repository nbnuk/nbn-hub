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

import grails.core.GrailsApplication
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
    GrailsApplication grailsApplication;

    String[] taxonText=[];
    String nameType = ""
    String[] basisOfRecord = []
    String identificationVerificationStatus = ""
    String identifiedBy = ""
    String gridReferenceType ="GB"
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
    String viceCountyName = ""
    String viceCountyIrelandName = ""
    String taxonID=""
    String lercName =""
    String nativeStatus = ""
    String habitatTaxon = ""
    String eventID = ""
    String collectionCode = ""


    private String taxa = ""
    private final String QUOTE = "\""
    private final String BOOL_OP = "AND"
    private List queryItems = [];

    /**
     * This custom toString method outputs a valid /occurrence/search query string.
     *
     * @return q
     */
    @Override
    public String toString() {

        addQueryItem(buildBasisOfRecordQuery(basisOfRecord))
        addQueryItem(buildIdentificationVerificationStatusQuery(identificationVerificationStatus));
        addQueryItem(buildNativeStatusQuery(nativeStatus));
        addQueryItem(buildHabitatTaxonQuery(habitatTaxon));
        addQueryItem(buildIdentifiedByQuery(identifiedBy))
        addQueryItem(buildGridReferenceQuery(gridReferenceType, gridReference))
        addQueryItem(buildLicenceQuery(licenceType, selectedLicence))
        addQueryItem(buildRecordedByQuery(recordedBy))
        addQueryItem(buildDateQuery(dateType, yearRange, year, month, day))
        addQueryItem(buildAnnotationsQuery(annotations))
        addQueryItem(buildDataProviderQuery(dataProviderUID))
        addQueryItem(buildLercQuery(lercName))
        addQueryItem(buildViceCountyQuery(viceCountyName))
        addQueryItem(buildViceCountyIrelandQuery(viceCountyIrelandName))
        addQueryItem(buildTaxonIDQuery(taxonID))
        addQueryItem(buildEventIDQuery(eventID))
        addQueryItem(buildCollectionCodeQuery(collectionCode))

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
        queryItems.clear();
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

    private String buildNativeStatusQuery(String nativeStatus) {
        String query="";
        if ("NATIVE".equals(nativeStatus)) {
            query = "establishment_means_taxon:\"Native\""
        }
        else if ("NONE-NATIVE".equals(nativeStatus)){
            query = "establishment_means_taxon:\"Non-native\""
        }
        return query;
    }

    private String buildHabitatTaxonQuery(String habitatTaxon) {
        String query="";
        if ("FRESHWATER".equals(habitatTaxon)) {
            query = "habitats_taxon:\"freshwater\""
        }
        else if ("MARINE".equals(habitatTaxon)){
            query = "habitats_taxon:\"marine\""
        }
        else if ("TERRESTRIAL".equals(habitatTaxon)){
            query = "habitats_taxon:\"terrestrial\""
        }
        return query;
    }

    private String buildDateQuery(String dateType, String yearRange, String year, String month, String day) {
        String query="";
        if ("ANY".equals(dateType)) {
            query=""
        }
        else if ("YEAR_RANGE".equals(dateType)) {
            String[] years = yearRange.split(",");
            //query = "occurrence_date:["+years[0]+"-01-01T00:00:00Z"+" TO "+years[1]+"-12-31T23:59:59Z]";
            query = "year:["+years[0]+" TO "+years[1]+"]";

        }
        else {
            if (year && month && day) {
                query = "occurrence_date:["+year+"-"+month+"-"+day+"T00:00:00Z"+" TO "+year+"-"+month+"-"+day+"T23:59:59Z]"
            }
            else {
                List parts = new ArrayList();
                if (year) {
                    parts.add("year:"+year);
                }
                if (month) {
                    parts.add("month:"+month);
                }
                if (day) {
                    parts.add("day:"+day);
                }
                if (parts.size()) {
                    query = "("+parts.join(" AND ")+")";
                }
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
            default:
                query = "grid_ref:"+gridReference+" AND !cl28:\"Northern Ireland\"";
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
            default:
                query = "grid_ref:"+gridReference+" AND cl28:\"Northern Ireland\"";
                break;
        }
        return query;
    }


    private String buildBasisOfRecordQuery(String[] basisOfRecord){
        return (basisOfRecord?.length && basisOfRecord.length<5)?buildBooleanQuerySegment(basisOfRecord, "basis_of_record", "OR"):"";

    }

    private String buildRecordedByQuery(String recordedBy){
        return recordedBy?"collector_text:"+recordedBy:"";
    }


    private String buildIdentifiedByQuery(String identifiedBy){
        return identifiedBy?"identified_by_text:"+identifiedBy:"";
    }

    private String buildDataProviderQuery(String dataProviderUID){
        return dataProviderUID?"data_provider_uid:"+dataProviderUID:"";
    }

    private String buildLercQuery(String lercName){
        return lercName?"${grailsApplication.config.layer.lerc}:\""+lercName+"\"":"";
    }

    private String buildViceCountyQuery(String viceCountyName){
        return viceCountyName?"${grailsApplication.config.layer.vice_county}:\""+viceCountyName+"\"":"";
    }

    private String buildViceCountyIrelandQuery(String viceCountyIrelandName){
        return viceCountyIrelandName?"${grailsApplication.config.layer.vice_county_ireland}:\""+viceCountyIrelandName+"\"":"";
    }

    private String buildTaxonIDQuery(String taxonID){
        return taxonID?"lsid:"+taxonID:"";
    }

    private String buildEventIDQuery(String eventID){
        return eventID?"event_id:\""+eventID+"\"":"";
    }

    private String buildCollectionCodeQuery(String collectionCode){
        return collectionCode?"collection_code:\""+collectionCode+"\"":"";
    }




    private void addQueryItem(String queryString) {
        if (queryString) {
            queryItems.add(queryString)
        }
    }


}
