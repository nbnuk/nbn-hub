<%@ page import="org.apache.commons.lang.StringUtils" %>
%{--<% Map fieldsMap = new HashMap(); pageContext.setAttribute("fieldsMap", fieldsMap); %>--}%
<%-- g:set target="${fieldsMap}" property="aKey" value="value for a key" /--%>
<g:set var="fieldsMap" value="${[:]}"/>
<div id="odsTemplate">
<g:render plugin="biocache-hubs" template="sandboxUploadSourceLinks" model="[dataResourceUid: record?.raw?.attribution?.dataResourceUid]" />
</div>

<div id="occurrenceDataset">

    <!-- ----------------------------------------------------------- -->

    <h3>Overview</h3>
    <table class="occurrenceTable table table-bordered table-striped table-condensed" id="recordTable">

    <!-- Occurrence ID -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="occurrenceID" fieldName="Occurrence ID">
            ${fieldsMap.put("occurrenceID", true)}
            <g:if test="${record.processed.occurrence.occurrenceID && record.raw.occurrence.occurrenceID}">
            <%-- links removed as per issue #6 (github)  --%>
                <g:if test="${StringUtils.startsWith(record.processed.occurrence.occurrenceID,'http://') || StringUtils.startsWith(record.processed.occurrence.occurrenceID,'https://')}"><a href="${record.processed.occurrence.occurrenceID}" target="_blank"></g:if>
                ${record.processed.occurrence.occurrenceID}
                <g:if test="${StringUtils.startsWith(record.processed.occurrence.occurrenceID,'http://') || StringUtils.startsWith(record.processed.occurrence.occurrenceID,'https://')}"></a></g:if>
                <br/><span class="originalValue">Supplied as "${record.raw.occurrence.occurrenceID}"</span>
            </g:if>
            <g:else>
                <g:if test="${StringUtils.startsWith(record.raw.occurrence.occurrenceID,'http://') || StringUtils.startsWith(record.raw.occurrence.occurrenceID,'https://')}"><a href="${record.raw.occurrence.occurrenceID}" target="_blank"></g:if>
                ${record.raw.occurrence.occurrenceID}
                <g:if test="${StringUtils.startsWith(record.raw.occurrence.occurrenceID,'http://') || StringUtils.startsWith(record.raw.occurrence.occurrenceID,'https://')}"></a></g:if>
            </g:else>
        </alatag:occurrenceTableRow>

        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="occurrenceStatus" fieldName="Occurrence Status">
            <g:if test="${record.raw.occurrence.occurrenceStatus && StringUtils.containsIgnoreCase( record.raw.occurrence.occurrenceStatus, 'absent' )}">
                ABSENT
            </g:if>
        </alatag:occurrenceTableRow>

    <!-- Catalogue Number -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="catalogueNumber" fieldName="Catalogue number">
            <g:if test="${record.raw.occurrence.catalogNumber}">
                ${record.raw.occurrence.catalogNumber}
            </g:if>
        </alatag:occurrenceTableRow>

    <!-- Other Catalogue Numbers -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="otherCatalogueNumbers" fieldName="Other catalogue numbers">
            <g:if test="${record.raw.occurrence.otherCatalogNumbers}">
                ${record.raw.occurrence.otherCatalogNumbers}
            </g:if>
        </alatag:occurrenceTableRow>

    <!-- Record Number -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="recordNumber" fieldName="Record number">
            <g:if test="${record.raw.occurrence.recordNumber}">
                ${record.raw.occurrence.recordNumber}
            </g:if>
        </alatag:occurrenceTableRow>


    <!-- Collection -->
        <!--
        <alatag:occurrenceTableRow annotate="false" section="dataset" fieldNameIsMsgCode="true" fieldCode="collectionCode" fieldName="Collection">
            <g:if test="${record.processed.attribution.collectionUid && collectionsWebappContext}">
                ${fieldsMap.put("collectionUid", true)}
                <a href="${collectionsWebappContext}/public/show/${record.processed.attribution.collectionUid}">
            </g:if>
            <g:if test="${record.processed.attribution.collectionName}">
                ${fieldsMap.put("collectionName", true)}
                ${record.processed.attribution.collectionName}
            </g:if>
            <g:elseif test="${collectionName}">
                ${fieldsMap.put("collectionName", true)}
                ${collectionName}
            </g:elseif>
            <g:if test="${record.processed.attribution.collectionUid && collectionsWebappContext}">
                </a>
            </g:if>
            <g:if test="${false && record.raw.occurrence.collectionCode}">
                ${fieldsMap.put("collectionCode", true)}
                <g:if test="${collectionName || record.processed.attribution.collectionName}"><br/></g:if>
                <span class="originalValue" style="display:none"><g:message code="recordcore.span02" default="Supplied collection code"/> "${record.raw.occurrence.collectionCode}"</span>
            </g:if>
        </alatag:occurrenceTableRow>
    -->

    <!-- Basis of Record -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="basisOfRecord" fieldName="Basis of record">
            ${fieldsMap.put("basisOfRecord", true)}
            <g:if test="${record.processed.occurrence.basisOfRecord && record.raw.occurrence.basisOfRecord && record.processed.occurrence.basisOfRecord == record.raw.occurrence.basisOfRecord}">
                <g:message code="${record.processed.occurrence.basisOfRecord}"/>
            </g:if>
            <g:elseif test="${record.processed.occurrence.basisOfRecord && record.raw.occurrence.basisOfRecord}">
                <g:message code="${record.processed.occurrence.basisOfRecord}"/>
                <br/><span class="originalValue"><g:message code="recordcore.span04" default="Supplied basis"/> "${record.raw.occurrence.basisOfRecord}"</span>
            </g:elseif>
            <g:elseif test="${record.processed.occurrence.basisOfRecord}">
                <g:message code="${record.processed.occurrence.basisOfRecord}"/>
            </g:elseif>
            <g:elseif test="${! record.raw.occurrence.basisOfRecord}">
                <g:message code="recordcore.span04.01" default="Not supplied"/>
            </g:elseif>
            <g:else>
                <g:message code="${record.raw.occurrence.basisOfRecord}"/>
            </g:else>
        </alatag:occurrenceTableRow>

    <!-- Scientific name 2 -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="scientificName" fieldName="Scientific name">
            <g:if test="${taxaLinks.baseUrl && record.processed.classification.taxonConceptID}">
                <a href="${taxaLinks.baseUrl}${record.processed.classification.taxonConceptID}">
            </g:if>
            <g:if test="${record.processed.classification.taxonRankID?.toInteger() > 5000}"><i></g:if>

            <g:if test="${taxon?.taxonConcept?.nameComplete}">
                ${taxon.taxonConcept.nameComplete}
            </g:if>
            <g:elseif test="${record.processed.classification.scientificName}">
                ${record.processed.classification.scientificName?:''}
            </g:elseif>
            <g:elseif test="${record.raw.classification.scientificName}">
                ${record.raw.classification.scientificName?:''} (unmatched)
            </g:elseif>

            <g:if test="${record.processed.classification.taxonRankID?.toInteger() > 5000}"></i></g:if>
            <g:if test="${taxaLinks.baseUrl && record.processed.classification.taxonConceptID}">
                </a>
            </g:if>

            <!-- Common Name -->
            <g:if test="${record.processed.classification.vernacularName}">
                ${ " - " }
                ${record.processed.classification.vernacularName}
            </g:if>
            <g:if test="${!record.processed.classification.vernacularName && record.raw.classification.vernacularName}">
                ${ " - " }
                ${record.raw.classification.vernacularName}
            </g:if>

            <g:if test="${false}">
                <g:if test="${record.processed.classification.scientificName && record.raw.classification.scientificName && (record.processed.classification.scientificName.toLowerCase() != record.raw.classification.scientificName.toLowerCase())}">
                    <br/><span class="originalValue">Supplied scientific name "${record.raw.classification.scientificName}"</span>
                </g:if>
                <g:if test="${!record.processed.classification.scientificName && record.raw.classification.scientificName}">
                    ${record.raw.classification.scientificName}
                </g:if>
            </g:if>
        </alatag:occurrenceTableRow>


    <!-- License -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="licence" fieldName="Licence">
            <g:if test="${record.processed.attribution.license}">
                <a href="https://docs.nbnatlas.org/data-licenses/" target="_blank">${ record.processed.attribution.license }</a>
            </g:if>
        </alatag:occurrenceTableRow>

    <!-- Rights Holder -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="rightsHolder" fieldName="Rights Holder">
            <g:if test="${record.raw.occurrence.rightsholder}">
                ${fieldsMap.put("rightsholder", true)}
                ${record.raw.occurrence.rightsholder}
            </g:if>
        </alatag:occurrenceTableRow>

    <!-- New Record Date -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="newRecordDate" fieldName="Record Date">
            <g:if test="${record.processed.event}">
                <g:if test="${record.processed.event.datePrecision && StringUtils.containsIgnoreCase(record.processed.event.datePrecision, 'not supplied')}">
                ${"Not supplied"}
                </g:if>
                <g:else>
                    <g:if test="${record.processed.event.day}">${record.processed.event.year}-${record.processed.event.month}-${record.processed.event.day}</g:if>
                    <g:elseif test="${record.processed.event.month}">${record.processed.event.year}-${record.processed.event.month}</g:elseif>
                    <g:elseif test="${record.processed.event.year}">${record.processed.event.year}</g:elseif>

                    <g:if test="${(record.processed.event.datePrecision != 'Day') && (record.processed.event.datePrecision != 'Month') && (record.processed.event.datePrecision != 'Year')}">
                        ${ " / " }
                        <g:if test="${record.processed.event.endDay}">${record.processed.event.endYear}-${record.processed.event.endMonth}-${record.processed.event.endDay}</g:if>
                        <g:elseif test="${record.processed.event.endMonth}">${record.processed.event.endYear}-${record.processed.event.endMonth}</g:elseif>
                        <g:elseif test="${record.processed.event.endYear}">${record.processed.event.endYear}</g:elseif>
                    </g:if>
                    (${record.processed.event.datePrecision})
                </g:else>
            </g:if>
        </alatag:occurrenceTableRow>

    <!-- Record Date -->
        <g:if test="${false}">
        <g:set var="occurrenceDateLabel">
            <g:if test="${StringUtils.containsIgnoreCase(record.processed.occurrence.basisOfRecord, 'specimen')}"><g:message code="recordcore.occurrencedatelabel.01" default="Collecting date"/></g:if>
            <g:else><g:message code="recordcore.occurrencedatelabel.02" default="Occurrence date"/></g:else>
        </g:set>
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="occurrenceDate" fieldName="${occurrenceDateLabel}">
            ${fieldsMap.put("eventDate", true)}
            <g:if test="${!record.processed.event.eventDate && record.raw.event.eventDate && !record.raw.event.year && !record.raw.event.month && !record.raw.event.day}">
                [<g:message code="recordcore.occurrencedatelabel.03" default="date not supplied"/>]
            </g:if>
            <g:if test="${record.processed.event.eventDate}">
                <span class="isoDate">${record.processed.event.eventDate}</span>
            </g:if>
            <g:if test="${!record.processed.event.eventDate && (record.processed.event.year || record.processed.event.month || record.processed.event.day)}">
                <g:message code="recordcore.occurrencedatelabel.04" default="Year"/>: ${record.processed.event.year},
                <g:message code="recordcore.occurrencedatelabel.05" default="Month"/>: ${record.processed.event.month},
                <g:message code="recordcore.occurrencedatelabel.06" default="Day"/>: ${record.processed.event.day}
            </g:if>

            <g:if test="${false}"> <!-- don't show in Overview -->
            <g:if test="${record.processed.event.eventDate && record.raw.event.eventDate && record.raw.event.eventDate != record.processed.event.eventDate}">
                <br/><span class="originalValue"><g:message code="recordcore.occurrencedatelabel.07" default="Supplied date"/> "${record.raw.event.eventDate}"</span>
            </g:if>
            <g:elseif test="${record.raw.event.year || record.raw.event.month || record.raw.event.day}">
                <br/><span class="originalValue">
                <g:message code="recordcore.occurrencedatelabel.08" default="Supplied as"/>
                <g:if test="${record.raw.event.year}"><g:message code="recordcore.occurrencedatelabel.09" default="year"/>:${record.raw.event.year}&nbsp;</g:if>
                <g:if test="${record.raw.event.month}"><g:message code="recordcore.occurrencedatelabel.10" default="month"/>:${record.raw.event.month}&nbsp;</g:if>
                <g:if test="${record.raw.event.day}"><g:message code="recordcore.occurrencedatelabel.11" default="day"/>:${record.raw.event.day}&nbsp;</g:if>
            </span>
            </g:elseif>
            <g:elseif test="${record.raw.event.eventDate != record.processed.event.eventDate && record.raw.event.eventDate}">
                <br/><span class="originalValue"><g:message code="recordcore.occurrencedatelabel.12" default="Supplied date"/> "${record.raw.event.eventDate}"</span>
            </g:elseif>
            </g:if>
        </alatag:occurrenceTableRow>
        </g:if>


        <!-- Locality -->
        <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="locality" fieldName="Locality">
            <g:if test="${record.processed.location.locality}">
                ${record.processed.location.locality}
            </g:if>
            <g:if test="${!record.processed.location.locality && record.raw.location.locality}">
                ${record.raw.location.locality}
            </g:if>
            <g:if test="${record.processed.location.locality && record.raw.location.locality && (record.processed.location.locality.toLowerCase() != record.raw.location.locality.toLowerCase())}">
                <br/><span class="originalValue">Supplied as: "${record.raw.location.locality}"</span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Data Generalizations -->
        <alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="generalisedInMetres" fieldName="Coordinates generalised">
            <g:if test="${record.processed.occurrence.dataGeneralizations && StringUtils.contains(record.processed.occurrence.dataGeneralizations, 'is already generalised')}">
                ${record.processed.occurrence.dataGeneralizations}
                ${ ' Please contact data provider for more information.' }
            </g:if>
            <g:elseif test="${record.processed.occurrence.dataGeneralizations}">
                <g:message code="recordcore.cg.label" default="Due to sensitivity concerns, the coordinates of this record have been generalised"/>: &quot;<span class="dataGeneralizations">${record.processed.occurrence.dataGeneralizations}</span>&quot;.
                ${(clubView) ? 'NOTE: current user has "club view" and thus coordinates are not generalise.' : ''}
                ${ ' Please contact data provider for more information.' }
            </g:elseif>
        </alatag:occurrenceTableRow>

        <!-- Location -->
        <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="location" fieldName="Location">

            <g:if test="${record.processed.location.gridReference || record.raw.location.gridReference || record.raw.location.decimalLatitude || record.processed.location.decimalLatitude || record.raw.location.decimalLongitude || record.processed.location.decimalLongitude}">

            ${ "Grid Reference: " }
            <g:if test="${record.processed.location.gridReference}">
                ${record.processed.location.gridReference}
            </g:if>
            <g:elseif test="${record.raw.location.gridReference}">
                ${record.raw.location.gridReference}
            </g:elseif>
            <g:else>
                ${ "Not supplied" }
            </g:else>

            <!-- Latitude -->
            ${ " Latitude: " }
            <g:if test="${clubView && record.raw.location.decimalLatitude != record.processed.location.decimalLatitude}">
                ${record.raw.location.decimalLatitude}
            </g:if>
            <g:elseif test="${record.raw.location.decimalLatitude && record.raw.location.decimalLatitude != record.processed.location.decimalLatitude}">
                ${record.processed.location.decimalLatitude}<br/><span class="originalValue">Supplied as: "${record.raw.location.decimalLatitude}"</span>
            </g:elseif>
            <g:elseif test="${record.processed.location.decimalLatitude}">
                ${record.processed.location.decimalLatitude}
            </g:elseif>
            <g:elseif test="${record.raw.location.decimalLatitude}">
                ${record.raw.location.decimalLatitude}
            </g:elseif>
            <g:else>
                ${ "Not supplied" }
            </g:else>

            <!-- Longitude -->
            ${ " Longitude: " }
            <g:if test="${clubView && record.raw.location.decimalLongitude != record.processed.location.decimalLongitude}">
                ${record.raw.location.decimalLongitude}
            </g:if>
            <g:elseif test="${record.raw.location.decimalLongitude && record.raw.location.decimalLongitude != record.processed.location.decimalLongitude}">
                ${record.processed.location.decimalLongitude}<br/><span class="originalValue">Supplied as: "${record.raw.location.decimalLongitude}"</span>
            </g:elseif>
            <g:elseif test="${record.processed.location.decimalLongitude}">
                ${record.processed.location.decimalLongitude}
            </g:elseif>
            <g:elseif test="${record.raw.location.decimalLongitude}">
                ${record.raw.location.decimalLongitude}
            </g:elseif>
            <g:else>
                ${ "Not supplied" }
            </g:else>

            </g:if>
            <g:else>
                ${ "Not supplied" }
            </g:else>

        </alatag:occurrenceTableRow>

    <!-- Recorded By Name -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="recordedBy" fieldName="Recorded by">
            <g:if test="${record.raw.occurrence.recordedBy}">
                ${fieldsMap.put("recordedBy", true)}
                ${record.raw.occurrence.recordedBy}
            </g:if>
        </alatag:occurrenceTableRow>

    <!-- Identifier Name -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="identifiedBy" fieldName="Identified by">
            <g:if test="${record.raw.identification && record.raw.identification.identifiedBy}">
                ${fieldsMap.put("identifiedBy", true)}
                ${record.raw.identification.identifiedBy}
            </g:if>
        </alatag:occurrenceTableRow>

    <!-- Verifier -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="verifier" fieldName="Verifier">
            <g:if test="${record.raw.identification && record.raw.identification.verifier}">
                ${fieldsMap.put("verifier", true)}
                ${record.raw.identification.verifier}
            </g:if>
        </alatag:occurrenceTableRow>

    <!-- Identification Verification Status -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="identificationVerificationStatus" fieldName="Identification Verification Status">
            <g:if test="${record.processed.identification && record.processed.identification.identificationVerificationStatus}">
                ${record.processed.identification.identificationVerificationStatus}
            </g:if>
        </alatag:occurrenceTableRow>

    <!-- Preparations -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="preparations" fieldName="Preparations">
            <g:if test="${record.raw.occurrence.preparations}">
                ${record.raw.occurrence.preparations}
            </g:if>
        </alatag:occurrenceTableRow>

        <g:if test="${record.raw.occurrence.occurrenceRemarks}">
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="occurrenceRemarks" fieldName="Occurrence remarks">
                ${record.raw.occurrence.occurrenceRemarks}
            </alatag:occurrenceTableRow>
        </g:if>

        <g:if test="${record.raw.occurrence.vitality}">
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="occurrenceVitality" fieldName="Occurrence vitality">
                ${record.raw.occurrence.vitality}
            </alatag:occurrenceTableRow>
        </g:if>


        <g:if test="${false}">
        <!-- Grid Reference -->
        <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="gridReference" fieldName="Grid reference">
            <g:if test="${record.processed.location.gridReference}">
                ${record.processed.location.gridReference}
            </g:if>
            <g:elseif test="${record.raw.location.gridReference}">
                ${record.raw.location.gridReference}
            </g:elseif>
        </alatag:occurrenceTableRow>

        <!-- Latitude -->
        <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="latitude" fieldName="Latitude">
            <g:if test="${clubView && record.raw.location.decimalLatitude != record.processed.location.decimalLatitude}">
                ${record.raw.location.decimalLatitude}
            </g:if>
            <g:elseif test="${record.raw.location.decimalLatitude && record.raw.location.decimalLatitude != record.processed.location.decimalLatitude}">
                ${record.processed.location.decimalLatitude}<br/><span class="originalValue">Supplied as: "${record.raw.location.decimalLatitude}"</span>
            </g:elseif>
            <g:elseif test="${record.processed.location.decimalLatitude}">
                ${record.processed.location.decimalLatitude}
            </g:elseif>
            <g:elseif test="${record.raw.location.decimalLatitude}">
                ${record.raw.location.decimalLatitude}
            </g:elseif>
        </alatag:occurrenceTableRow>

        <!-- Longitude -->
        <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="longitude" fieldName="Longitude">
            <g:if test="${clubView && record.raw.location.decimalLongitude != record.processed.location.decimalLongitude}">
                ${record.raw.location.decimalLongitude}
            </g:if>
            <g:elseif test="${record.raw.location.decimalLongitude && record.raw.location.decimalLongitude != record.processed.location.decimalLongitude}">
                ${record.processed.location.decimalLongitude}<br/><span class="originalValue">Supplied as: "${record.raw.location.decimalLongitude}"</span>
            </g:elseif>
            <g:elseif test="${record.processed.location.decimalLongitude}">
                ${record.processed.location.decimalLongitude}
            </g:elseif>
            <g:elseif test="${record.raw.location.decimalLongitude}">
                ${record.raw.location.decimalLongitude}
            </g:elseif>
        </alatag:occurrenceTableRow>
</g:if>

    </table>


    <!-- ----------------------------------------------------------- -->

    <h3>Dataset</h3>
    <table class="occurrenceTable table table-bordered table-striped table-condensed" id="newDatasetTable">

    <!-- Data Provider -->
        <alatag:occurrenceTableRow annotate="false" section="dataset" fieldCode="dataProvider" fieldName="Data provider">
            <g:if test="${record.processed.attribution.dataProviderUid && collectionsWebappContext}">
                ${fieldsMap.put("dataProviderUid", true)}
                ${fieldsMap.put("dataProviderName", true)}
                <a href="${collectionsWebappContext}/public/show/${record.processed.attribution.dataProviderUid}">
                    ${record.processed.attribution.dataProviderName}
                </a>
            </g:if>
            <g:else>
                ${fieldsMap.put("dataProviderName", true)}
                ${record.processed.attribution.dataProviderName}
            </g:else>
        </alatag:occurrenceTableRow>

    <!-- Data Resource -->
        <alatag:occurrenceTableRow annotate="false" section="dataset" fieldCode="dataResource" fieldName="Data resource">
            <g:if test="${record.raw.attribution.dataResourceUid != null && record.raw.attribution.dataResourceUid && collectionsWebappContext}">
                ${fieldsMap.put("dataResourceUid", true)}
                ${fieldsMap.put("dataResourceName", true)}
                <a href="${collectionsWebappContext}/public/show/${record.raw.attribution.dataResourceUid}">
                    <g:if test="${record.processed.attribution.dataResourceName}">
                        ${record.processed.attribution.dataResourceName}
                    </g:if>
                    <g:else>
                        ${record.raw.attribution.dataResourceUid}
                    </g:else>
                </a>
            </g:if>
            <g:else>
                ${fieldsMap.put("dataResourceName", true)}
                ${record.processed.attribution.dataResourceName}
            </g:else>
        </alatag:occurrenceTableRow>

    <!-- Collection Code -->
        <alatag:occurrenceTableRow annotate="false" section="dataset" fieldNameIsMsgCode="true" fieldCode="collectionCode" fieldName="Collection">
            <g:if test="${record.raw.occurrence.collectionCode}">
                ${record.raw.occurrence.collectionCode}
            </g:if>
        </alatag:occurrenceTableRow>

    <!-- Institution -->
        <alatag:occurrenceTableRow annotate="false" section="dataset" fieldCode="institutionCode" fieldName="Institution">
            <g:if test="${record.processed.attribution.institutionUid && collectionsWebappContext}">
                ${fieldsMap.put("institutionUid", true)}
                ${fieldsMap.put("institutionName", true)}
                <a href="${collectionsWebappContext}/public/show/${record.processed.attribution.institutionUid}">
                    ${record.processed.attribution.institutionName}
                </a>
            </g:if>
            <g:else>
                ${fieldsMap.put("institutionName", true)}
                ${record.processed.attribution.institutionName}
            </g:else>
            <g:if test="${record.raw.occurrence.institutionCode}">
                ${fieldsMap.put("institutionCode", true)}
                <g:if test="${record.processed.attribution.institutionName}"><br/></g:if>
                <g:if test="${false}">
                <span class="originalValue"><g:message code="recordcore.span01" default="Supplied institution code"/> "${record.raw.occurrence.institutionCode}"</span>
                </g:if>
                ${ "Supplied institution code " }
                "${record.raw.occurrence.institutionCode}"
            </g:if>
        </alatag:occurrenceTableRow>

    <!-- References -->
        <alatag:occurrenceTableRow annotate="false" section="dataset" fieldCode="references" fieldName="References">
            <g:if test="${record.raw.miscProperties.references}">
                ${record.raw.miscProperties.references}
            </g:if>
        </alatag:occurrenceTableRow>


    </table>

        <!-- ----------------------------------------------------------- -->

    <g:if test="${record.raw.occurrence.individualCount ||
                    record.raw.occurrence.organismQuantity ||
                    record.raw.occurrence.organismQuantityType ||
                    (record.raw.miscProperties && (record.raw.miscProperties.organismQuantity || record.raw.miscProperties.organismQuantityType)) ||
                    (record.raw.miscProperties && (record.raw.miscProperties.sampleSizeUnit || record.raw.miscProperties.sampleSizeValue))}">

        <div id="occurrenceAbundance">
        <h3>Abundance</h3>
        <table class="occurrenceTable table table-bordered table-striped table-condensed" id="newAbundanceTable">

            <!-- Individual count -->
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="individualCount" fieldName="Individual count">
                <g:if test="${record.raw.occurrence.individualCount}">
                    ${fieldsMap.put("individualCount", true)}
                    ${record.raw.occurrence.individualCount}
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Organism Quantity -->
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="organismQuantity" fieldName="Organism quantity">
                <g:if test="${record.raw.occurrence.organismQuantity}">
                    ${record.raw.occurrence.organismQuantity}
                </g:if>
                <g:if test="${record.raw.miscProperties && record.raw.miscProperties.organismQuantity}">
                    ${record.raw.miscProperties.organismQuantity}
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Organism Quantity Type -->
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="organismQuantityType" fieldName="Organism quantity type">
                <g:if test="${record.raw.occurrence.organismQuantityType}">
                    ${record.raw.occurrence.organismQuantityType}
                </g:if>
                <g:if test="${record.raw.miscProperties && record.raw.miscProperties.organismQuantityType}">
                    ${record.raw.miscProperties.organismQuantityType}
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Sample Size Unit -->
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="sampleSizeUnit" fieldName="Sample size unit">
                <g:if test="${record.raw.miscProperties && record.raw.miscProperties.sampleSizeUnit}">
                    ${record.raw.miscProperties.sampleSizeUnit}
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Sample Size Value -->
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="sampleSizeValue" fieldName="Sample size value">
                <g:if test="${record.raw.miscProperties && record.raw.miscProperties.sampleSizeValue}">
                    ${record.raw.miscProperties.sampleSizeValue}
                </g:if>
            </alatag:occurrenceTableRow>

        </table>
        </div>
    </g:if>

        <!-- ----------------------------------------------------------- -->

    <g:if test="${record.raw.occurrence.lifeStage || record.raw.occurrence.behavior || record.raw.occurrence.sex ||
                    record.raw.occurrence.organismRemarks ||
                    record.raw.occurrence.organismScope}">

        <div id="occurrenceOrganism">
        <h3>Organism</h3>
        <table class="occurrenceTable table table-bordered table-striped table-condensed" id="organismTable2">

            <!-- Life Stage -->
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="lifeStage" fieldName="Life stage">
                <g:if test="${record.raw.occurrence.lifeStage}">
                    ${record.raw.occurrence.lifeStage}
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Behavior -->
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="behavior" fieldName="Behavior">
                <g:if test="${record.raw.occurrence.behavior}">
                    ${record.raw.occurrence.behavior}
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Sex -->
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="sex" fieldName="Sex">
                <g:if test="${record.raw.occurrence.sex}">
                    ${fieldsMap.put("sex", true)}
                    ${record.raw.occurrence.sex}
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Organism Scope -->
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="organismScope" fieldName="Organism scope">
                <g:if test="${record.raw.occurrence.organismScope}">
                    ${record.raw.occurrence.organismScope}
                </g:if>
            </alatag:occurrenceTableRow>

            <!-- Organism Remarks -->
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="organismRemarks" fieldName="Organism remarks">
                <g:if test="${record.raw.occurrence.organismRemarks}">
                    ${record.raw.occurrence.organismRemarks}
                </g:if>
            </alatag:occurrenceTableRow>

        </table>
        </div>
    </g:if>

    <g:if test="${false}">
        hello inside if
    </g:if>
</div> <!-- occurrenceDatasetNew -->

    <!-- ----------------------------------------------------------- -->
    <!-- Event -->
<div id="occurrenceEvent">
    <h3><g:message code="recordcore.occurenceevent.title" default="Event2"/></h3>
    <table class="occurrenceTable table table-bordered table-striped table-condensed" id="eventTable2">
    <!-- Field Number -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="fieldNumber" fieldName="Field number">
            ${fieldsMap.put("fieldNumber", true)}
            ${record.raw.occurrence.fieldNumber}
        </alatag:occurrenceTableRow>
    <!-- Field Number -->

        <!--
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="identificationRemarks" fieldNameIsMsgCode="true" fieldName="Identification remarks">
            ${fieldsMap.put("identificationRemarks", true)}
            ${record.raw.identification.identificationRemarks}
        </alatag:occurrenceTableRow>
        -->

    <!-- Record Date -->
        <g:set var="occurrenceDateLabel">
            <g:if test="${StringUtils.containsIgnoreCase(record.processed.occurrence.basisOfRecord, 'specimen')}"><g:message code="recordcore.occurrencedatelabel.01" default="Collecting date"/></g:if>
            <g:else><g:message code="recordcore.occurrencedatelabel.02" default="Record date"/></g:else>
        </g:set>
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="occurrenceDate" fieldName="${occurrenceDateLabel}">
            <g:if test="${false}">${fieldsMap.put("eventDate", true)}</g:if>
            <g:if test="${!record.processed.event.eventDate && record.raw.event.eventDate && !record.raw.event.year && !record.raw.event.month && !record.raw.event.day}">
                [<g:message code="recordcore.occurrencedatelabel.03" default="date not supplied"/>]
            </g:if>
            <g:if test="${record.processed.event.eventDate}">
                <span class="isoDate">${record.processed.event.eventDate}</span>
            </g:if>
            <g:if test="${!record.processed.event.eventDate && (record.processed.event.year || record.processed.event.month || record.processed.event.day)}">
                <g:message code="recordcore.occurrencedatelabel.04" default="Year"/>: ${record.processed.event.year},
                <g:message code="recordcore.occurrencedatelabel.05" default="Month"/>: ${record.processed.event.month},
                <g:message code="recordcore.occurrencedatelabel.06" default="Day"/>: ${record.processed.event.day}
            </g:if>
            <g:if test="${record.processed.event.eventDate && record.raw.event.eventDate && record.raw.event.eventDate != record.processed.event.eventDate}">
                <br/><span class="originalValue"><g:message code="recordcore.occurrencedatelabel.07" default="Supplied date"/> "${record.raw.event.eventDate}"</span>
            </g:if>
            <g:elseif test="${record.raw.event.year || record.raw.event.month || record.raw.event.day}">
                <br/><span class="originalValue">
                <g:message code="recordcore.occurrencedatelabel.08" default="Supplied as"/>
                <g:if test="${record.raw.event.year}"><g:message code="recordcore.occurrencedatelabel.09" default="year"/>:${record.raw.event.year}&nbsp;</g:if>
                <g:if test="${record.raw.event.month}"><g:message code="recordcore.occurrencedatelabel.10" default="month"/>:${record.raw.event.month}&nbsp;</g:if>
                <g:if test="${record.raw.event.day}"><g:message code="recordcore.occurrencedatelabel.11" default="day"/>:${record.raw.event.day}&nbsp;</g:if>
            </span>
            </g:elseif>
            <g:elseif test="${record.raw.event.eventDate != record.processed.event.eventDate && record.raw.event.eventDate}">
                <br/><span class="originalValue"><g:message code="recordcore.occurrencedatelabel.12" default="Supplied date"/> "${record.raw.event.eventDate}"</span>
            </g:elseif>
        </alatag:occurrenceTableRow>
        <!-- Sampling Protocol -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="samplingProtocol" fieldName="Sampling protocol">
            <g:if test="${record.raw.occurrence.samplingProtocol}">
                ${fieldsMap.put("samplingProtocol", true)}
                ${record.raw.occurrence.samplingProtocol}
            </g:if>
        </alatag:occurrenceTableRow>

        <alatag:formatExtraDwC compareRecord="${compareRecord}" fieldsMap="${fieldsMap}" group="Event" exclude="${dwcExcludeFields}"/>
    </table>
</div>

<!-- ----------------------------------------------------------- -->
<!-- Taxonomy -->

<div id="occurrenceTaxonomy">
    <g:if test="${false}"><h3><g:message code="recordcore.occurencetaxonomy.title" default="Taxonomy"/></h3></g:if>
    <h3>Taxonomy</h3>
    <table class="occurrenceTable table table-bordered table-striped table-condensed" id="taxonomyTable2">

        <!-- Scientific name 2 -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="scientificName" fieldName="Scientific name">
            ${fieldsMap.put("taxonConceptID", true)}
            ${fieldsMap.put("scientificName", true)}
            <g:if test="${taxaLinks.baseUrl && record.processed.classification.taxonConceptID}">
                <a href="${taxaLinks.baseUrl}${record.processed.classification.taxonConceptID}">
            </g:if>
            <g:if test="${record.processed.classification.taxonRankID?.toInteger() > 5000}"><i></g:if>

            <g:if test="${taxon?.taxonConcept?.nameComplete}">
                ${taxon.taxonConcept.nameComplete}
            </g:if>
            <g:else>
                ${record.processed.classification.scientificName?:''}
            </g:else>

            <g:if test="${record.processed.classification.taxonRankID?.toInteger() > 5000}"></i></g:if>
            <g:if test="${taxaLinks.baseUrl && record.processed.classification.taxonConceptID}">
                </a>
            </g:if>
            <g:if test="${record.processed.classification.scientificName && record.raw.classification.scientificName && (record.processed.classification.scientificName.toLowerCase() != record.raw.classification.scientificName.toLowerCase())}">
                <br/><span class="originalValue">Supplied scientific name "${record.raw.classification.scientificName}"</span>
            </g:if>
            <g:if test="${!record.processed.classification.scientificName && record.raw.classification.scientificName}">
                ${record.raw.classification.scientificName}
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Common name 5 -->
        <alatag:occurrenceTableRow annotate="false" section="taxonomy" fieldCode="commonName" fieldName="Common name">
            ${fieldsMap.put("vernacularName", true)}
            <g:if test="${record.processed.classification.vernacularName}">
                ${record.processed.classification.vernacularName}
            </g:if>
            <g:if test="${!record.processed.classification.vernacularName && record.raw.classification.vernacularName}">
                ${record.raw.classification.vernacularName}
            </g:if>
            <g:if test="${record.processed.classification.vernacularName && record.raw.classification.vernacularName && (record.processed.classification.vernacularName.toLowerCase() != record.raw.classification.vernacularName.toLowerCase())}">
                <br/><span class="originalValue"><g:message code="recordcore.cn.01" default="Supplied common name"/> "${record.raw.classification.vernacularName}"</span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Taxon Rank 4 -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="taxonRank" fieldName="Taxon rank">
            ${fieldsMap.put("taxonRank", true)}
            ${fieldsMap.put("taxonRankID", true)}
            <g:if test="${record.processed.classification.taxonRank}">
                <span style="text-transform: capitalize;">${record.processed.classification.taxonRank}</span>
            </g:if>
            <g:elseif test="${!record.processed.classification.taxonRank && record.raw.classification.taxonRank}">
                <span style="text-transform: capitalize;">${record.raw.classification.taxonRank}</span>
            </g:elseif>
            <g:else>
                [<g:message code="recordcore.tr01" default="rank not known"/>]
            </g:else>
            <g:if test="${record.processed.classification.taxonRank && record.raw.classification.taxonRank  && (record.processed.classification.taxonRank.toLowerCase() != record.raw.classification.taxonRank.toLowerCase())}">
                <br/><span class="originalValue"><g:message code="recordcore.tr02" default="Supplied as"/> "${record.raw.classification.taxonRank}"</span>
            </g:if>
        </alatag:occurrenceTableRow>

        <g:if test="${record.processed.classification.nameMatchMetric}">
            <!-- Taxonomic issues -->
            <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="nameMatchMetric" fieldName="Name match metric">
                <g:message code="${record.processed.classification.nameMatchMetric}" default="${record.processed.classification.nameMatchMetric}"/>
                <br/>
                <g:message code="nameMatch.${record.processed.classification.nameMatchMetric}" default=""/>
            </alatag:occurrenceTableRow>
        </g:if>

        <!-- Species 12 -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="species" fieldName="Species">
            ${fieldsMap.put("species", true)}
            ${fieldsMap.put("speciesID", true)}
            ${fieldsMap.put("specificEpithet", true)}
            <g:if test="${record.processed.classification.speciesID}">
                <g:if test="${taxaLinks.baseUrl}">
                    <a href="${taxaLinks.baseUrl}${record.processed.classification.speciesID}">
                </g:if>
            </g:if>
            <g:if test="${record.processed.classification.species}">
                <i>${record.processed.classification.species}</i>
            </g:if>
            <g:elseif test="${record.raw.classification.species}">
                <i>${record.raw.classification.species}</i>
            </g:elseif>
            <g:elseif test="${record.raw.classification.specificEpithet && record.raw.classification.genus}">
                <i>${record.raw.classification.genus}&nbsp;${record.raw.classification.specificEpithet}</i>
            </g:elseif>
            <g:if test="${taxaLinks.baseUrl && record.processed.classification.speciesID}">
                </a>
            </g:if>
            <g:if test="${record.processed.classification.species && record.raw.classification.species && (record.processed.classification.species.toLowerCase() != record.raw.classification.species.toLowerCase())}">
                <br/><span class="originalValue"><g:message code="recordcore.species.01" default="Supplied as"/> "<i>${record.raw.classification.species}</i>"</span>
            </g:if>
        </alatag:occurrenceTableRow>

        <!-- Genus 11 -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="genus" fieldName="Genus">
            ${fieldsMap.put("genus", true)}
            ${fieldsMap.put("genusID", true)}
            <g:if test="${record.processed.classification.genusID}">
                <g:if test="${taxaLinks.baseUrl}">
                    <a href="${taxaLinks.baseUrl}${record.processed.classification.genusID}">
                </g:if>
            </g:if>
            <g:if test="${record.processed.classification.genus}">
                <i>${record.processed.classification.genus}</i>
            </g:if>
            <g:if test="${!record.processed.classification.genus && record.raw.classification.genus}">
                <i>${record.raw.classification.genus}</i>
            </g:if>
            <g:if test="${taxaLinks.baseUrl && record.processed.classification.genusID}">
                </a>
            </g:if>
            <g:if test="${record.processed.classification.genus && record.raw.classification.genus && (record.processed.classification.genus.toLowerCase() != record.raw.classification.genus.toLowerCase())}">
                <br/><span class="originalValue"><g:message code="recordcore.genus.01" default="Supplied as"/> "<i>${record.raw.classification.genus}</i>"</span>
            </g:if>
        </alatag:occurrenceTableRow>
        <!-- Family 10 -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="family" fieldName="Family">
            ${fieldsMap.put("family", true)}
            ${fieldsMap.put("familyID", true)}
            <g:if test="${record.processed.classification.familyID}">
                <g:if test="${taxaLinks.baseUrl}">
                    <a href="${taxaLinks.baseUrl}${record.processed.classification.familyID}">
                </g:if>
            </g:if>
            <g:if test="${record.processed.classification.family}">
                ${record.processed.classification.family}
            </g:if>
            <g:if test="${!record.processed.classification.family && record.raw.classification.family}">
                ${record.raw.classification.family}
            </g:if>
            <g:if test="${taxaLinks.baseUrl && record.processed.classification.familyID}">
                </a>
            </g:if>
            <g:if test="${record.processed.classification.family && record.raw.classification.family && (record.processed.classification.family.toLowerCase() != record.raw.classification.family.toLowerCase())}">
                <br/><span class="originalValue"><g:message code="recordcore.family.01" default="Supplied as"/> "${record.raw.classification.family}"</span>
            </g:if>
        </alatag:occurrenceTableRow>
        <!-- Order 9 -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="order" fieldName="Order">
            ${fieldsMap.put("order", true)}
            ${fieldsMap.put("orderID", true)}
            <g:if test="${record.processed.classification.orderID}">
                <g:if test="${taxaLinks.baseUrl}">
                    <a href="${taxaLinks.baseUrl}${record.processed.classification.orderID}">
                </g:if>
            </g:if>
            <g:if test="${record.processed.classification.order}">
                ${record.processed.classification.order}
            </g:if>
            <g:if test="${!record.processed.classification.order && record.raw.classification.order}">
                ${record.raw.classification.order}
            </g:if>
            <g:if test="${taxaLinks.baseUrl && record.processed.classification.orderID}">
                </a>
            </g:if>
            <g:if test="${record.processed.classification.order && record.raw.classification.order && (record.processed.classification.order.toLowerCase() != record.raw.classification.order.toLowerCase())}">
                <br/><span class="originalValue"><g:message code="recordcore.order.01" default="Supplied as"/> "${record.raw.classification.order}"</span>
            </g:if>
        </alatag:occurrenceTableRow>
        <!-- Class 8 -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="classs" fieldName="Class">
            ${fieldsMap.put("classs", true)}
            ${fieldsMap.put("classID", true)}
            <g:if test="${record.processed.classification.classID}">
                <g:if test="${taxaLinks.baseUrl}">
                    <a href="${taxaLinks.baseUrl}${record.processed.classification.classID}">
                </g:if>
            </g:if>
            <g:if test="${record.processed.classification.classs}">
                ${record.processed.classification.classs}
            </g:if>
            <g:if test="${!record.processed.classification.classs && record.raw.classification.classs}">
                ${record.raw.classification.classs}
            </g:if>
            <g:if test="${taxaLinks.baseUrl && record.processed.classification.classID}">
                </a>
            </g:if>
            <g:if test="${record.processed.classification.classs && record.raw.classification.classs && (record.processed.classification.classs.toLowerCase() != record.raw.classification.classs.toLowerCase())}">
                <br/><span classs="originalValue"><g:message code="recordcore.class.01" default="Supplied as"/> "${record.raw.classification.classs}"</span>
            </g:if>
        </alatag:occurrenceTableRow>
        <!-- Phylum 7 -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="phylum" fieldName="Phylum">
            ${fieldsMap.put("phylum", true)}
            ${fieldsMap.put("phylumID", true)}
            <g:if test="${record.processed.classification.phylumID}">
                <g:if test="${taxaLinks.baseUrl}">
                    <a href="${taxaLinks.baseUrl}${record.processed.classification.phylumID}">
                </g:if>
            </g:if>
            <g:if test="${record.processed.classification.phylum}">
                ${record.processed.classification.phylum}
            </g:if>
            <g:if test="${!record.processed.classification.phylum && record.raw.classification.phylum}">
                ${record.raw.classification.phylum}
            </g:if>
            <g:if test="${taxaLinks.baseUrl && record.processed.classification.phylumID}">
                </a>
            </g:if>
            <g:if test="${record.processed.classification.phylum && record.raw.classification.phylum && (record.processed.classification.phylum.toLowerCase() != record.raw.classification.phylum.toLowerCase())}">
                <br/><span class="originalValue"><g:message code="recordcore.phylum.01" default="Supplied as"/> "${record.raw.classification.phylum}"</span>
            </g:if>
        </alatag:occurrenceTableRow>
        <!-- Kingdom 6 -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="kingdom" fieldName="Kingdom">
            ${fieldsMap.put("kingdom", true)}
            ${fieldsMap.put("kingdomID", true)}
            <g:if test="${record.processed.classification.kingdomID}">
                <g:if test="${taxaLinks.baseUrl}">
                    <a href="${taxaLinks.baseUrl}${record.processed.classification.kingdomID}">
                </g:if>
            </g:if>
            <g:if test="${record.processed.classification.kingdom}">
                ${record.processed.classification.kingdom}
            </g:if>
            <g:if test="${!record.processed.classification.kingdom && record.raw.classification.kingdom}">
                ${record.raw.classification.kingdom}
            </g:if>
            <g:if test="${taxaLinks.baseUrl && record.processed.classification.kingdomID}">
                </a>
            </g:if>
            <g:if test="${record.processed.classification.kingdom && record.raw.classification.kingdom && (record.processed.classification.kingdom.toLowerCase() != record.raw.classification.kingdom.toLowerCase())}">
                <br/><span class="originalValue"><g:message code="recordcore.kingdom.01" default="Supplied as"/> "${record.raw.classification.kingdom}"</span>
            </g:if>
        </alatag:occurrenceTableRow>
        <!-- original name usage 3 -->
        <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="originalNameUsage" fieldName="Original name">
            ${fieldsMap.put("originalNameUsage", true)}
            ${fieldsMap.put("originalNameUsageID", true)}
            <g:if test="${record.processed.classification.originalNameUsageID}">
                <g:if test="${taxaLinks.baseUrl}">
                    <a href="${taxaLinks.baseUrl}${record.processed.classification.originalNameUsageID}">
                </g:if>
            </g:if>
            <g:if test="${record.processed.classification.originalNameUsage}">
                ${record.processed.classification.originalNameUsage}
            </g:if>
            <g:if test="${!record.processed.classification.originalNameUsage && record.raw.classification.originalNameUsage}">
                ${record.raw.classification.originalNameUsage}
            </g:if>
            <g:if test="${taxaLinks.baseUrl && record.processed.classification.originalNameUsageID}">
                </a>
            </g:if>
            <g:if test="${record.processed.classification.originalNameUsage && record.raw.classification.originalNameUsage && (record.processed.classification.originalNameUsage.toLowerCase() != record.raw.classification.originalNameUsage.toLowerCase())}">
                <br/><span class="originalValue">Supplied as "${record.raw.classification.originalNameUsage}"</span>
            </g:if>
        </alatag:occurrenceTableRow>
        <!-- Taxon ID -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="taxonID" fieldName="Taxon ID">
            <g:if test="${record.processed.classification.taxonConceptID}">
                ${record.processed.classification.taxonConceptID}
            </g:if>
            <g:if test="${record.processed.classification.taxonConceptID && record.raw.classification.taxonID && (record.processed.classification.taxonConceptID.toLowerCase() != record.raw.classification.taxonID.toLowerCase())}">
                <br/><span class="originalValue">Supplied taxon ID "${record.raw.classification.taxonID}"</span>
            </g:if>
        </alatag:occurrenceTableRow>
        <!-- Higher classification 1 -->
        <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="higherClassification" fieldName="Higher classification">
            ${fieldsMap.put("higherClassification", true)}
            ${record.raw.classification.higherClassification}
        </alatag:occurrenceTableRow>
        <!-- Associated Taxa -->
        <g:if test="${record.raw.occurrence.associatedTaxa}">
            <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="associatedTaxa" fieldName="Associated species">
                ${fieldsMap.put("associatedTaxa", true)}
                <g:set var="colon" value=":"/>
                <g:if test="${taxaLinks.baseUrl && StringUtils.contains(record.raw.occurrence.associatedTaxa,colon)}">
                    <g:set var="associatedName" value="${StringUtils.substringAfter(record.raw.occurrence.associatedTaxa,colon)}"/>
                    ${StringUtils.substringBefore(record.raw.occurrence.associatedTaxa,colon) }: <a href="${taxaLinks.baseUrl}${StringUtils.replace(associatedName, '  ', ' ')}">${associatedName}</a>
                </g:if>
                <g:elseif test="${taxaLinks.baseUrl}">
                    <a href="${taxaLinks.baseUrl}${StringUtils.replace(record.raw.occurrence.associatedTaxa, '  ', ' ')}">${record.raw.occurrence.associatedTaxa}</a>
                </g:elseif>
            </alatag:occurrenceTableRow>
        </g:if>
        <g:if test="${record.processed.classification.taxonomicIssue}">
            <!-- Taxonomic issues -->
            <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="taxonomicIssue" fieldName="Taxonomic issues">
            %{--<alatag:formatJsonArray text="${record.processed.classification.taxonomicIssue}"/>--}%
                <g:each var="issue" in="${record.processed.classification.taxonomicIssue}">
                    <g:message code="${issue}"/>
                </g:each>
            </alatag:occurrenceTableRow>
        </g:if>

        <g:if test="${record.raw.identification.identificationRemarks}">
            <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="identificationRemarks" fieldNameIsMsgCode="true" fieldName="Identification remarks">
                <!-- ${fieldsMap.put("identificationRemarks", true)} -->
                ${record.raw.identification.identificationRemarks}
            </alatag:occurrenceTableRow>
        </g:if>

    <!-- output any tags not covered already (excluding those in dwcExcludeFields) -->
        <alatag:formatExtraDwC compareRecord="${compareRecord}" fieldsMap="${fieldsMap}" group="Classification" exclude="${dwcExcludeFields}"/>
    </table>
</div>


    <!-- ----------------------------------------------------------- -->
    <!-- original code follows -->


<g:if test="${false}">
<div id="occurrenceEventOld">
<h3><g:message code="recordcore.occurenceevent.title" default="Event"/></h3>
<table class="occurrenceTable table table-bordered table-striped table-condensed" id="eventTable">
    <!-- Field Number -->
    <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="fieldNumber" fieldName="Field number">
        ${fieldsMap.put("fieldNumber", true)}
        ${record.raw.occurrence.fieldNumber}
    </alatag:occurrenceTableRow>
    <!-- Field Number -->
    <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="identificationRemarks" fieldNameIsMsgCode="true" fieldName="Identification remarks">
        ${fieldsMap.put("identificationRemarks", true)}
        ${record.raw.identification.identificationRemarks}
    </alatag:occurrenceTableRow>
<!-- Record Date -->
    <g:set var="occurrenceDateLabel">
        <g:if test="${StringUtils.containsIgnoreCase(record.processed.occurrence.basisOfRecord, 'specimen')}"><g:message code="recordcore.occurrencedatelabel.01" default="Collecting date"/></g:if>
        <g:else><g:message code="recordcore.occurrencedatelabel.02" default="Record date"/></g:else>
    </g:set>
    <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="occurrenceDate" fieldName="${occurrenceDateLabel}">
        ${fieldsMap.put("eventDate", true)}
        <g:if test="${!record.processed.event.eventDate && record.raw.event.eventDate && !record.raw.event.year && !record.raw.event.month && !record.raw.event.day}">
            [<g:message code="recordcore.occurrencedatelabel.03" default="date not supplied"/>]
        </g:if>
        <g:if test="${record.processed.event.eventDate}">
            <span class="isoDate">${record.processed.event.eventDate}</span>
        </g:if>
        <g:if test="${!record.processed.event.eventDate && (record.processed.event.year || record.processed.event.month || record.processed.event.day)}">
            <g:message code="recordcore.occurrencedatelabel.04" default="Year"/>: ${record.processed.event.year},
            <g:message code="recordcore.occurrencedatelabel.05" default="Month"/>: ${record.processed.event.month},
            <g:message code="recordcore.occurrencedatelabel.06" default="Day"/>: ${record.processed.event.day}
        </g:if>
        <g:if test="${record.processed.event.eventDate && record.raw.event.eventDate && record.raw.event.eventDate != record.processed.event.eventDate}">
            <br/><span class="originalValue"><g:message code="recordcore.occurrencedatelabel.07" default="Supplied date"/> "${record.raw.event.eventDate}"</span>
        </g:if>
        <g:elseif test="${record.raw.event.year || record.raw.event.month || record.raw.event.day}">
            <br/><span class="originalValue">
            <g:message code="recordcore.occurrencedatelabel.08" default="Supplied as"/>
            <g:if test="${record.raw.event.year}"><g:message code="recordcore.occurrencedatelabel.09" default="year"/>:${record.raw.event.year}&nbsp;</g:if>
            <g:if test="${record.raw.event.month}"><g:message code="recordcore.occurrencedatelabel.10" default="month"/>:${record.raw.event.month}&nbsp;</g:if>
            <g:if test="${record.raw.event.day}"><g:message code="recordcore.occurrencedatelabel.11" default="day"/>:${record.raw.event.day}&nbsp;</g:if>
        </span>
        </g:elseif>
        <g:elseif test="${record.raw.event.eventDate != record.processed.event.eventDate && record.raw.event.eventDate}">
            <br/><span class="originalValue"><g:message code="recordcore.occurrencedatelabel.12" default="Supplied date"/> "${record.raw.event.eventDate}"</span>
        </g:elseif>
    </alatag:occurrenceTableRow>
<!-- Sampling Protocol -->
    <alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="samplingProtocol" fieldName="Sampling protocol">
        ${fieldsMap.put("samplingProtocol", true)}
        ${record.raw.occurrence.samplingProtocol}
    </alatag:occurrenceTableRow>
    <alatag:formatExtraDwC compareRecord="${compareRecord}" fieldsMap="${fieldsMap}" group="Event" exclude="${dwcExcludeFields}"/>
</table>
</div>
</g:if>

<g:if test="${false}">
<div id="occurrenceTaxonomyOld">
<h3><g:message code="recordcore.occurencetaxonomy.title" default="Taxonomy"/></h3>
<table class="occurrenceTable table table-bordered table-striped table-condensed" id="taxonomyTable">
<!-- Higher classification -->
<alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="higherClassification" fieldName="Higher classification">
    ${fieldsMap.put("higherClassification", true)}
    ${record.raw.classification.higherClassification}
</alatag:occurrenceTableRow>
<!-- Scientific name -->
<alatag:occurrenceTableRow annotate="true" section="dataset" fieldCode="scientificName" fieldName="Scientific name">
    ${fieldsMap.put("taxonConceptID", true)}
    ${fieldsMap.put("scientificName", true)}
    <g:if test="${taxaLinks.baseUrl && record.processed.classification.taxonConceptID}">
        <a href="${taxaLinks.baseUrl}${record.processed.classification.taxonConceptID}">
    </g:if>
    <g:if test="${record.processed.classification.taxonRankID?.toInteger() > 5000}"><i></g:if>
    ${record.processed.classification.scientificName?:''}
    <g:if test="${record.processed.classification.taxonRankID?.toInteger() > 5000}"></i></g:if>
    <g:if test="${taxaLinks.baseUrl && record.processed.classification.taxonConceptID}">
        </a>
    </g:if>
    <g:if test="${record.processed.classification.scientificName && record.raw.classification.scientificName && (record.processed.classification.scientificName.toLowerCase() != record.raw.classification.scientificName.toLowerCase())}">
        <br/><span class="originalValue">Supplied scientific name "${record.raw.classification.scientificName}"</span>
    </g:if>
    <g:if test="${!record.processed.classification.scientificName && record.raw.classification.scientificName}">
        ${record.raw.classification.scientificName}
    </g:if>
</alatag:occurrenceTableRow>
<!-- original name usage -->
<alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="originalNameUsage" fieldName="Original name">
    ${fieldsMap.put("originalNameUsage", true)}
    ${fieldsMap.put("originalNameUsageID", true)}
    <g:if test="${record.processed.classification.originalNameUsageID}">
        <g:if test="${taxaLinks.baseUrl}">
            <a href="${taxaLinks.baseUrl}${record.processed.classification.originalNameUsageID}">
        </g:if>
    </g:if>
    <g:if test="${record.processed.classification.originalNameUsage}">
        ${record.processed.classification.originalNameUsage}
    </g:if>
    <g:if test="${!record.processed.classification.originalNameUsage && record.raw.classification.originalNameUsage}">
        ${record.raw.classification.originalNameUsage}
    </g:if>
    <g:if test="${taxaLinks.baseUrl && record.processed.classification.originalNameUsageID}">
        </a>
    </g:if>
    <g:if test="${record.processed.classification.originalNameUsage && record.raw.classification.originalNameUsage && (record.processed.classification.originalNameUsage.toLowerCase() != record.raw.classification.originalNameUsage.toLowerCase())}">
        <br/><span class="originalValue">Supplied as "${record.raw.classification.originalNameUsage}"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- Taxon Rank -->
<alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="taxonRank" fieldName="Taxon rank">
    ${fieldsMap.put("taxonRank", true)}
    ${fieldsMap.put("taxonRankID", true)}
    <g:if test="${record.processed.classification.taxonRank}">
        <span style="text-transform: capitalize;">${record.processed.classification.taxonRank}</span>
    </g:if>
    <g:elseif test="${!record.processed.classification.taxonRank && record.raw.classification.taxonRank}">
        <span style="text-transform: capitalize;">${record.raw.classification.taxonRank}</span>
    </g:elseif>
    <g:else>
        [<g:message code="recordcore.tr01" default="rank not known"/>]
    </g:else>
    <g:if test="${record.processed.classification.taxonRank && record.raw.classification.taxonRank  && (record.processed.classification.taxonRank.toLowerCase() != record.raw.classification.taxonRank.toLowerCase())}">
        <br/><span class="originalValue"><g:message code="recordcore.tr02" default="Supplied as"/> "${record.raw.classification.taxonRank}"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- Common name -->
<alatag:occurrenceTableRow annotate="false" section="taxonomy" fieldCode="commonName" fieldName="Common name">
    ${fieldsMap.put("vernacularName", true)}
    <g:if test="${record.processed.classification.vernacularName}">
        ${record.processed.classification.vernacularName}
    </g:if>
    <g:if test="${!record.processed.classification.vernacularName && record.raw.classification.vernacularName}">
        ${record.raw.classification.vernacularName}
    </g:if>
    <g:if test="${record.processed.classification.vernacularName && record.raw.classification.vernacularName && (record.processed.classification.vernacularName.toLowerCase() != record.raw.classification.vernacularName.toLowerCase())}">
        <br/><span class="originalValue"><g:message code="recordcore.cn.01" default="Supplied common name"/> "${record.raw.classification.vernacularName}"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- Kingdom -->
<alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="kingdom" fieldName="Kingdom">
    ${fieldsMap.put("kingdom", true)}
    ${fieldsMap.put("kingdomID", true)}
    <g:if test="${record.processed.classification.kingdomID}">
        <g:if test="${taxaLinks.baseUrl}">
            <a href="${taxaLinks.baseUrl}${record.processed.classification.kingdomID}">
        </g:if>
    </g:if>
    <g:if test="${record.processed.classification.kingdom}">
        ${record.processed.classification.kingdom}
    </g:if>
    <g:if test="${!record.processed.classification.kingdom && record.raw.classification.kingdom}">
        ${record.raw.classification.kingdom}
    </g:if>
    <g:if test="${taxaLinks.baseUrl && record.processed.classification.kingdomID}">
        </a>
    </g:if>
    <g:if test="${record.processed.classification.kingdom && record.raw.classification.kingdom && (record.processed.classification.kingdom.toLowerCase() != record.raw.classification.kingdom.toLowerCase())}">
        <br/><span class="originalValue"><g:message code="recordcore.kingdom.01" default="Supplied as"/> "${record.raw.classification.kingdom}"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- Phylum -->
<alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="phylum" fieldName="Phylum">
    ${fieldsMap.put("phylum", true)}
    ${fieldsMap.put("phylumID", true)}
    <g:if test="${record.processed.classification.phylumID}">
        <g:if test="${taxaLinks.baseUrl}">
            <a href="${taxaLinks.baseUrl}${record.processed.classification.phylumID}">
        </g:if>
    </g:if>
    <g:if test="${record.processed.classification.phylum}">
        ${record.processed.classification.phylum}
    </g:if>
    <g:if test="${!record.processed.classification.phylum && record.raw.classification.phylum}">
        ${record.raw.classification.phylum}
    </g:if>
    <g:if test="${taxaLinks.baseUrl && record.processed.classification.phylumID}">
        </a>
    </g:if>
    <g:if test="${record.processed.classification.phylum && record.raw.classification.phylum && (record.processed.classification.phylum.toLowerCase() != record.raw.classification.phylum.toLowerCase())}">
        <br/><span class="originalValue"><g:message code="recordcore.phylum.01" default="Supplied as"/> "${record.raw.classification.phylum}"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- Class -->
<alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="classs" fieldName="Class">
    ${fieldsMap.put("classs", true)}
    ${fieldsMap.put("classID", true)}
    <g:if test="${record.processed.classification.classID}">
        <g:if test="${taxaLinks.baseUrl}">
            <a href="${taxaLinks.baseUrl}${record.processed.classification.classID}">
        </g:if>
    </g:if>
    <g:if test="${record.processed.classification.classs}">
        ${record.processed.classification.classs}
    </g:if>
    <g:if test="${!record.processed.classification.classs && record.raw.classification.classs}">
        ${record.raw.classification.classs}
    </g:if>
    <g:if test="${taxaLinks.baseUrl && record.processed.classification.classID}">
        </a>
    </g:if>
    <g:if test="${record.processed.classification.classs && record.raw.classification.classs && (record.processed.classification.classs.toLowerCase() != record.raw.classification.classs.toLowerCase())}">
        <br/><span classs="originalValue"><g:message code="recordcore.class.01" default="Supplied as"/> "${record.raw.classification.classs}"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- Order -->
<alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="order" fieldName="Order">
    ${fieldsMap.put("order", true)}
    ${fieldsMap.put("orderID", true)}
    <g:if test="${record.processed.classification.orderID}">
        <g:if test="${taxaLinks.baseUrl}">
            <a href="${taxaLinks.baseUrl}${record.processed.classification.orderID}">
        </g:if>
    </g:if>
    <g:if test="${record.processed.classification.order}">
        ${record.processed.classification.order}
    </g:if>
    <g:if test="${!record.processed.classification.order && record.raw.classification.order}">
        ${record.raw.classification.order}
    </g:if>
    <g:if test="${taxaLinks.baseUrl && record.processed.classification.orderID}">
        </a>
    </g:if>
    <g:if test="${record.processed.classification.order && record.raw.classification.order && (record.processed.classification.order.toLowerCase() != record.raw.classification.order.toLowerCase())}">
        <br/><span class="originalValue"><g:message code="recordcore.order.01" default="Supplied as"/> "${record.raw.classification.order}"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- Family -->
<alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="family" fieldName="Family">
    ${fieldsMap.put("family", true)}
    ${fieldsMap.put("familyID", true)}
    <g:if test="${record.processed.classification.familyID}">
        <g:if test="${taxaLinks.baseUrl}">
            <a href="${taxaLinks.baseUrl}${record.processed.classification.familyID}">
        </g:if>
    </g:if>
    <g:if test="${record.processed.classification.family}">
        ${record.processed.classification.family}
    </g:if>
    <g:if test="${!record.processed.classification.family && record.raw.classification.family}">
        ${record.raw.classification.family}
    </g:if>
    <g:if test="${taxaLinks.baseUrl && record.processed.classification.familyID}">
        </a>
    </g:if>
    <g:if test="${record.processed.classification.family && record.raw.classification.family && (record.processed.classification.family.toLowerCase() != record.raw.classification.family.toLowerCase())}">
        <br/><span class="originalValue"><g:message code="recordcore.family.01" default="Supplied as"/> "${record.raw.classification.family}"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- Genus -->
<alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="genus" fieldName="Genus">
    ${fieldsMap.put("genus", true)}
    ${fieldsMap.put("genusID", true)}
    <g:if test="${record.processed.classification.genusID}">
        <g:if test="${taxaLinks.baseUrl}">
            <a href="${taxaLinks.baseUrl}${record.processed.classification.genusID}">
        </g:if>
    </g:if>
    <g:if test="${record.processed.classification.genus}">
        <i>${record.processed.classification.genus}</i>
    </g:if>
    <g:if test="${!record.processed.classification.genus && record.raw.classification.genus}">
        <i>${record.raw.classification.genus}</i>
    </g:if>
    <g:if test="${taxaLinks.baseUrl && record.processed.classification.genusID}">
        </a>
    </g:if>
    <g:if test="${record.processed.classification.genus && record.raw.classification.genus && (record.processed.classification.genus.toLowerCase() != record.raw.classification.genus.toLowerCase())}">
        <br/><span class="originalValue"><g:message code="recordcore.genus.01" default="Supplied as"/> "<i>${record.raw.classification.genus}</i>"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- Species -->
<alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="species" fieldName="Species">
    ${fieldsMap.put("species", true)}
    ${fieldsMap.put("speciesID", true)}
    ${fieldsMap.put("specificEpithet", true)}
    <g:if test="${record.processed.classification.speciesID}">
        <g:if test="${taxaLinks.baseUrl}">
            <a href="${taxaLinks.baseUrl}${record.processed.classification.speciesID}">
        </g:if>
    </g:if>
    <g:if test="${record.processed.classification.species}">
        <i>${record.processed.classification.species}</i>
    </g:if>
    <g:elseif test="${record.raw.classification.species}">
        <i>${record.raw.classification.species}</i>
    </g:elseif>
    <g:elseif test="${record.raw.classification.specificEpithet && record.raw.classification.genus}">
        <i>${record.raw.classification.genus}&nbsp;${record.raw.classification.specificEpithet}</i>
    </g:elseif>
    <g:if test="${taxaLinks.baseUrl && record.processed.classification.speciesID}">
        </a>
    </g:if>
    <g:if test="${record.processed.classification.species && record.raw.classification.species && (record.processed.classification.species.toLowerCase() != record.raw.classification.species.toLowerCase())}">
        <br/><span class="originalValue"><g:message code="recordcore.species.01" default="Supplied as"/> "<i>${record.raw.classification.species}</i>"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- Associated Taxa -->
<g:if test="${record.raw.occurrence.associatedTaxa}">
    <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="associatedTaxa" fieldName="Associated species">
        ${fieldsMap.put("associatedTaxa", true)}
        <g:set var="colon" value=":"/>
        <g:if test="${taxaLinks.baseUrl && StringUtils.contains(record.raw.occurrence.associatedTaxa,colon)}">
            <g:set var="associatedName" value="${StringUtils.substringAfter(record.raw.occurrence.associatedTaxa,colon)}"/>
            ${StringUtils.substringBefore(record.raw.occurrence.associatedTaxa,colon) }: <a href="${taxaLinks.baseUrl}${StringUtils.replace(associatedName, '  ', ' ')}">${associatedName}</a>
        </g:if>
        <g:elseif test="${taxaLinks.baseUrl}">
            <a href="${taxaLinks.baseUrl}${StringUtils.replace(record.raw.occurrence.associatedTaxa, '  ', ' ')}">${record.raw.occurrence.associatedTaxa}</a>
        </g:elseif>
    </alatag:occurrenceTableRow>
</g:if>
<g:if test="${record.processed.classification.taxonomicIssue}">
    <!-- Taxonomic issues -->
    <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="taxonomicIssue" fieldName="Taxonomic issues">
        %{--<alatag:formatJsonArray text="${record.processed.classification.taxonomicIssue}"/>--}%
        <g:each var="issue" in="${record.processed.classification.taxonomicIssue}">
            <g:message code="${issue}"/>
        </g:each>
    </alatag:occurrenceTableRow>
</g:if>
<g:if test="${record.processed.classification.nameMatchMetric}">
    <!-- Taxonomic issues -->
    <alatag:occurrenceTableRow annotate="true" section="taxonomy" fieldCode="nameMatchMetric" fieldName="Name match metric">
        <g:message code="${record.processed.classification.nameMatchMetric}" default="${record.processed.classification.nameMatchMetric}"/>
        <br/>
        <g:message code="nameMatch.${record.processed.classification.nameMatchMetric}" default=""/>
    </alatag:occurrenceTableRow>
</g:if>
<!-- output any tags not covered already (excluding those in dwcExcludeFields) -->
<alatag:formatExtraDwC compareRecord="${compareRecord}" fieldsMap="${fieldsMap}" group="Classification" exclude="${dwcExcludeFields}"/>
</table>
</div>
</g:if>

<g:if test="${compareRecord?.Location}">
<div id="occurrenceGeospatial">
<h3><g:message code="recordcore.occurencegeospatial.title" default="Geospatial"/></h3>
<table class="occurrenceTable table table-bordered table-striped table-condensed" id="geospatialTable">
<!-- Higher Geography -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="higherGeography" fieldName="Higher geography">
    ${fieldsMap.put("higherGeography", true)}
    ${record.raw.location.higherGeography}
</alatag:occurrenceTableRow>
<!-- Country -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="country" fieldName="Country">
    ${fieldsMap.put("country", true)}
    <g:if test="${record.processed.location.country}">
        ${record.processed.location.country}
    </g:if>
    <g:elseif test="${record.processed.location.countryCode}">
        <g:message code="country.${record.processed.location.countryCode}"/>
    </g:elseif>
    <g:else>
        ${record.raw.location.country}
    </g:else>
    <g:if test="${record.processed.location.country && record.raw.location.country && (record.processed.location.country.toLowerCase() != record.raw.location.country.toLowerCase())}">
        <br/><span class="originalValue"><g:message code="recordcore.st.01" default="Supplied as"/> "${record.raw.location.country}"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- State/Province -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="state" fieldName="State/Province">
    ${fieldsMap.put("stateProvince", true)}
    <g:set var="stateValue" value="${record.processed.location.stateProvince ? record.processed.location.stateProvince : record.raw.location.stateProvince}" />
    <g:if test="${stateValue}">
        <%--<a href="${bieWebappContext}/regions/aus_states/${stateValue}">--%>
        ${stateValue}
        <%--</a>--%>
    </g:if>
    <g:if test="${record.processed.location.stateProvince && record.raw.location.stateProvince && (record.processed.location.stateProvince.toLowerCase() != record.raw.location.stateProvince.toLowerCase())}">
        <br/><span class="originalValue"><g:message code="recordcore.locality.01" default="Supplied as"/>: "${record.raw.location.stateProvince}"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- Local Govt Area -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="locality" fieldName="Local government area">
    ${fieldsMap.put("lga", true)}
    <g:if test="${record.processed.location.lga}">
        ${record.processed.location.lga}
    </g:if>
    <g:if test="${!record.processed.location.lga && record.raw.location.lga}">
        ${record.raw.location.lga}
    </g:if>
</alatag:occurrenceTableRow>
<!-- Locality -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="locality" fieldName="Locality">
    ${fieldsMap.put("locality", true)}
    <g:if test="${record.processed.location.locality}">
        ${record.processed.location.locality}
    </g:if>
    <g:if test="${!record.processed.location.locality && record.raw.location.locality}">
        ${record.raw.location.locality}
    </g:if>
    <g:if test="${record.processed.location.locality && record.raw.location.locality && (record.processed.location.locality.toLowerCase() != record.raw.location.locality.toLowerCase())}">
        <br/><span class="originalValue">Supplied as: "${record.raw.location.locality}"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- Biogeographic Region -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="biogeographicRegion" fieldName="Biogeographic region">
    ${fieldsMap.put("ibra", true)}
    <g:if test="${record.processed.location.ibra}">
        ${record.processed.location.ibra}
    </g:if>
    <g:if test="${!record.processed.location.ibra && record.raw.location.ibra}">
        ${record.raw.location.ibra}
    </g:if>
</alatag:occurrenceTableRow>
<!-- Habitat -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="habitat" fieldName="Habitat">
    ${fieldsMap.put("habitat", true)}
    ${record.processed.location.habitat}
    <g:if test="${record.raw.location.habitat && record.raw.location.habitat != record.processed.location.habitat}">
        <br/><span class="originalValue"><g:message code="recordcore.span03" default="Supplied as"/> "${record.raw.location.habitat}"</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- Latitude -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="latitude" fieldName="Latitude">
    ${fieldsMap.put("decimalLatitude", true)}
    <g:if test="${clubView && record.raw.location.decimalLatitude != record.processed.location.decimalLatitude}">
        ${record.raw.location.decimalLatitude}
    </g:if>
    <g:elseif test="${record.raw.location.decimalLatitude && record.raw.location.decimalLatitude != record.processed.location.decimalLatitude}">
        ${record.processed.location.decimalLatitude}<br/><span class="originalValue">Supplied as: "${record.raw.location.decimalLatitude}"</span>
    </g:elseif>
    <g:elseif test="${record.processed.location.decimalLatitude}">
        ${record.processed.location.decimalLatitude}
    </g:elseif>
    <g:elseif test="${record.raw.location.decimalLatitude}">
        ${record.raw.location.decimalLatitude}
    </g:elseif>
</alatag:occurrenceTableRow>
<!-- Longitude -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="longitude" fieldName="Longitude">
    ${fieldsMap.put("decimalLongitude", true)}
    <g:if test="${clubView && record.raw.location.decimalLongitude != record.processed.location.decimalLongitude}">
        ${record.raw.location.decimalLongitude}
    </g:if>
    <g:elseif test="${record.raw.location.decimalLongitude && record.raw.location.decimalLongitude != record.processed.location.decimalLongitude}">
        ${record.processed.location.decimalLongitude}<br/><span class="originalValue">Supplied as: "${record.raw.location.decimalLongitude}"</span>
    </g:elseif>
    <g:elseif test="${record.processed.location.decimalLongitude}">
        ${record.processed.location.decimalLongitude}
    </g:elseif>
    <g:elseif test="${record.raw.location.decimalLongitude}">
        ${record.raw.location.decimalLongitude}
    </g:elseif>
</alatag:occurrenceTableRow>
<!-- Geodetic datum -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="geodeticDatum" fieldName="Geodetic datum">
    ${fieldsMap.put("geodeticDatum", true)}
    <g:if test="${clubView && record.raw.location.geodeticDatum != record.processed.location.geodeticDatum}">
        ${record.raw.location.geodeticDatum}
    </g:if>
    <g:elseif test="${record.raw.location.geodeticDatum && record.raw.location.geodeticDatum != record.processed.location.geodeticDatum}">
        ${record.processed.location.geodeticDatum}<br/><span class="originalValue">Supplied datum: "${record.raw.location.geodeticDatum}"</span>
    </g:elseif>
    <g:elseif test="${record.processed.location.geodeticDatum}">
        ${record.processed.location.geodeticDatum}
    </g:elseif>
    <g:elseif test="${record.raw.location.geodeticDatum}">
        ${record.raw.location.geodeticDatum}
    </g:elseif>
</alatag:occurrenceTableRow>
<!-- verbatimCoordinateSystem -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="verbatimCoordinateSystem" fieldName="Verbatim coordinate system">
    ${fieldsMap.put("verbatimCoordinateSystem", true)}
    ${record.raw.location.verbatimCoordinateSystem}
</alatag:occurrenceTableRow>
<!-- Verbatim locality -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="verbatimLocality" fieldName="Verbatim locality">
    ${fieldsMap.put("verbatimLocality", true)}
    ${record.raw.location.verbatimLocality}
</alatag:occurrenceTableRow>
<!-- Water Body -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="waterBody" fieldName="Water body">
    ${fieldsMap.put("waterBody", true)}
    ${record.raw.location.waterBody}
</alatag:occurrenceTableRow>
<!-- Min depth -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="minimumDepthInMeters" fieldName="Minimum depth in metres">
    ${fieldsMap.put("minimumDepthInMeters", true)}
    ${record.raw.location.minimumDepthInMeters}
</alatag:occurrenceTableRow>
<!-- Max depth -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="maximumDepthInMeters" fieldName="Maximum depth in metres">
    ${fieldsMap.put("maximumDepthInMeters", true)}
    ${record.raw.location.maximumDepthInMeters}
</alatag:occurrenceTableRow>
<!-- Min elevation -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="minimumElevationInMeters" fieldName="Minimum elevation in metres">
    ${fieldsMap.put("minimumElevationInMeters", true)}
    ${record.raw.location.minimumElevationInMeters}
</alatag:occurrenceTableRow>
<!-- Max elevation -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="maximumElevationInMeters" fieldName="Maximum elevation in metres">
    ${fieldsMap.put("maximumElevationInMeters", true)}
    ${record.raw.location.maximumElevationInMeters}
</alatag:occurrenceTableRow>
<!-- Island -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="island" fieldName="Island">
    ${fieldsMap.put("island", true)}
    ${record.raw.location.island}
</alatag:occurrenceTableRow>
<!-- Island Group-->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="islandGroup" fieldName="Island group">
    ${fieldsMap.put("islandGroup", true)}
    ${record.raw.location.islandGroup}
</alatag:occurrenceTableRow>
<!-- Location remarks -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="locationRemarks" fieldName="Location remarks">
    ${fieldsMap.put("locationRemarks", true)}
    ${record.raw.location.locationRemarks}
</alatag:occurrenceTableRow>
<!-- Field notes -->
<alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="fieldNotes" fieldName="Field notes">
    ${fieldsMap.put("fieldNotes", true)}
    ${record.raw.occurrence.fieldNotes}
</alatag:occurrenceTableRow>
<!-- Coordinate Precision -->
<alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="coordinatePrecision" fieldName="Coordinate precision">
    ${fieldsMap.put("coordinatePrecision", true)}
    <g:if test="${record.raw.location.decimalLatitude || record.raw.location.decimalLongitude}">
        ${record.raw.location.coordinatePrecision ? record.raw.location.coordinatePrecision : 'Unknown'}
    </g:if>
</alatag:occurrenceTableRow>
<!-- Coordinate Uncertainty -->
<alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="coordinateUncertaintyInMeters" fieldName="Coordinate uncertainty in metres">
    ${fieldsMap.put("coordinateUncertaintyInMeters", true)}
    <g:if test="${record.processed.location.coordinateUncertaintyInMeters}">
        ${record.processed.location.coordinateUncertaintyInMeters ? record.processed.location.coordinateUncertaintyInMeters : 'Unknown'}
    </g:if>
</alatag:occurrenceTableRow>
<!-- Data Generalizations -->
<alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="generalisedInMetres" fieldName="Coordinates generalised">
    ${fieldsMap.put("generalisedInMetres", true)}
    <g:if test="${record.processed.occurrence.dataGeneralizations && StringUtils.contains(record.processed.occurrence.dataGeneralizations, 'is already generalised')}">
        ${record.processed.occurrence.dataGeneralizations}
    </g:if>
    <g:elseif test="${record.processed.occurrence.dataGeneralizations}">
        <g:message code="recordcore.cg.label" default="Due to sensitivity concerns, the coordinates of this record have been generalised"/>: &quot;<span class="dataGeneralizations">${record.processed.occurrence.dataGeneralizations}</span>&quot;.
        ${(clubView) ? 'NOTE: current user has "club view" and thus coordinates are not generalise.' : ''}
    </g:elseif>
</alatag:occurrenceTableRow>
<!-- Information Withheld -->
<alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="informationWithheld" fieldName="Information withheld">
    ${fieldsMap.put("informationWithheld", true)}
    <g:if test="${record.processed.occurrence.informationWithheld}">
        <span class="dataGeneralizations">${record.processed.occurrence.informationWithheld}</span>
    </g:if>
</alatag:occurrenceTableRow>
<!-- GeoreferenceVerificationStatus -->
<alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="georeferenceVerificationStatus" fieldName="Georeference verification status">
    ${fieldsMap.put("georeferenceVerificationStatus", true)}
    ${record.raw.location.georeferenceVerificationStatus}
</alatag:occurrenceTableRow>
<!-- georeferenceSources -->
<alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="georeferenceSources" fieldName="Georeference sources">
    ${fieldsMap.put("georeferenceSources", true)}
    ${record.raw.location.georeferenceSources}
</alatag:occurrenceTableRow>
<!-- georeferenceProtocol -->
<alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="georeferenceProtocol" fieldName="Georeference protocol">
    ${fieldsMap.put("georeferenceProtocol", true)}
    ${record.raw.location.georeferenceProtocol}
</alatag:occurrenceTableRow>
<!-- georeferenceProtocol -->
<alatag:occurrenceTableRow annotate="false" section="geospatial" fieldCode="georeferencedBy" fieldName="Georeferenced by">
    ${fieldsMap.put("georeferencedBy", true)}
    ${record.raw.location.georeferencedBy}
</alatag:occurrenceTableRow>
<!-- output any tags not covered already (excluding those in dwcExcludeFields) -->
<alatag:formatExtraDwC compareRecord="${compareRecord}" fieldsMap="${fieldsMap}" group="Location" exclude="${dwcExcludeFields}"/>
</table>
</div>
</g:if>
<g:if test="${record.raw.miscProperties}">
    <div id="additionalProperties">
        <h3><g:message code="recordcore.div.addtionalproperties.title" default="Additional properties"/></h3>
        <table class="occurrenceTable table table-bordered table-striped table-condensed" id="miscellaneousPropertiesTable">
            <!-- Higher Geography -->
            <g:each in="${record.raw.miscProperties.sort()}" var="entry">
                <g:set var="entryHtml"><span class='dwc'>${entry.key}</span></g:set>
                <g:set var="label"><alatag:camelCaseToHuman text="${entryHtml}"/></g:set>
                <g:if test="${(entry.key != 'references') &&
                                (entry.key != 'organismQuantity') &&
                                (entry.key != 'organismQuantityType') &&
                                (entry.key != 'sampleSizeUnit') &&
                                (entry.key != 'sampleSizeValue') &&
                                (entry.key != 'organismScope') &&
                                (entry.key != 'organismRemarks')}">
                    <alatag:occurrenceTableRow annotate="true" section="geospatial" fieldCode="${entry.key}" fieldName="${label}">${entry.value}</alatag:occurrenceTableRow>
                </g:if>
            </g:each>
        </table>
    </div>
</g:if>
