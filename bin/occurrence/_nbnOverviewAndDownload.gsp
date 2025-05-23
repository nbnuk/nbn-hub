<asset:stylesheet src="nbn/nbnOverviewAndDownload.css" />

<g:if test="${grailsApplication.config.useDownloadPlugin?.toBoolean()}">
    <div id="overview" class="tab-pane">
        <g:set var="maxDownloadExceeded" value="${grailsApplication.config.maxDownloadRecords && Integer.parseInt(grailsApplication.config.maxDownloadRecords) < sr.totalRecords}"/>
        <g:set var="unconfirmedIdentificationCount" value="${
            (sr.facetResults?.find{it.fieldName=="identification_verification_status"}?.fieldResult.find{it.label=="Unconfirmed"}?.count ?: 0) +
            (sr.facetResults?.find{it.fieldName=="identification_verification_status"}?.fieldResult.find{it.label=="Unconfirmed - not reviewed"}?.count ?: 0) +
            (sr.facetResults?.find{it.fieldName=="identification_verification_status"}?.fieldResult.find{it.label=="Unconfirmed - plausible"}?.count ?: 0)
        }"/>
        <g:set var="absenceCount" value="${sr.facetResults?.find{it.fieldName=="occurrence_status"}?.fieldResult?.find{it.label=="absent"}?.count}"/>
        <g:set var="fossilCount" value="${sr.facetResults?.find{it.fieldName=="basis_of_record"}?.fieldResult?.find{it.label=="Fossil specimen"}?.count}"/>
        <g:set var="licenceCount" value="${sr.facetResults?.find{it.fieldName=="license"}?.fieldResult?.find{it.label=="CC-BY-NC"}?.count}"/>
        <g:set var="buttonCount" value="${(unconfirmedIdentificationCount > 0 ? 1 : 0) + (absenceCount > 0 ? 1 : 0) + (fossilCount > 0 ? 1 : 0) + (licenceCount > 0 ? 1 : 0)}"/>
        <g:set var="absenceFilterPresent" value="${sr.activeFacetMap["-occurrence_status"]?.value == '"absent"'}" />
        %{--                            ${absenceFilterPresent}--}%

        <h3><g:message code="list.overviewtab.title" default="Overview"/></h3>
        <g:if test="${buttonCount > 0}">
        %{-- <p><g:message code="list.overviewtab.description" default="Here you can refine your results before downloading them."/></p>--}%
            <p><g:message code="list.overviewtab.description" default="Use the button${buttonCount>1 ? "s" : ""} if you wish to remove the following records from your download:"/></p>
        </g:if>
        <g:else>
            <p><g:message code="list.overviewtab.descriptionempty" default="There are no records that can be excluded, use the download button to continue:"/></p>
        </g:else>
        <ul class="list-group exclude-helpers">
            <li class="list-group-item">
                <label><span class="count unconfirmed-identification-count"><g:formatNumber number="${unconfirmedIdentificationCount ?: 0}" format="###,###,###,##0"/></span> unconfirmed identifications</label>
                <g:if test="${unconfirmedIdentificationCount > 0}">
                    <g:if test="${sr.totalRecords == unconfirmedIdentificationCount}">
                        <a class="btn btn-primary disabled exclude">You cannot exclude all records</a>
                    </g:if>
                    <g:else>
                        <a href='${sr.query}&fq=-(identification_verification_status%3A"Unconfirmed" OR identification_verification_status%3A"Unconfirmed - not reviewed" OR identification_verification_status%3A"Unconfirmed - plausible")' class="btn btn-primary exclude">Exclude unconfirmed identifications</a>
                    </g:else>
                </g:if>
            </li>
            <li class="list-group-item">
                <label><span class="count absence-record-count"><g:formatNumber number="${absenceCount ?: 0}" format="###,###,###,##0"/></span> absence records ${absenceFilterPresent ? "(excluded by default)" : ""}</label>
                <g:if test="${absenceCount > 0}">
                    <g:if test="${sr.totalRecords == absenceCount}">
                        <a class="btn btn-primary disabled exclude">You cannot exclude all records</a>
                    </g:if>
                    <g:else>
                        <a href="${sr.query}&fq=-occurrence_status:absent" class="btn btn-primary exclude">Exclude absence records</a>
                    </g:else>
                </g:if>
            </li>
            <li class="list-group-item">
                <label><span class="count fossil-record-count"><g:formatNumber number="${fossilCount ?: 0}" format="###,###,###,##0"/></span> fossil records</label>
                <g:if test="${fossilCount > 0}">
                    <g:if test="${sr.totalRecords == fossilCount}">
                        <a class="btn btn-primary disabled exclude">You cannot exclude all records</a>
                    </g:if>
                    <g:else>
                        <a href="${sr.query}&fq=-basis_of_record:FossilSpecimen" class="btn btn-primary exclude">Exclude fossil records</a>
                    </g:else>
                </g:if>
            </li>
            <li class="list-group-item">
                <label><span class="count cc-by-nc-count"><g:formatNumber number="${licenceCount ?: 0}" format="###,###,###,##0"/></span> records with a CC-BY-NC licence*</label>
                <g:if test="${licenceCount > 0}">
                    <g:if test="${sr.totalRecords == licenceCount}">
                        <a class="btn btn-primary disabled exclude">You cannot exclude all records</a>
                    </g:if>
                    <g:else>
                        <a href="${sr.query}&fq=-license:CC-BY-NC" class="btn btn-primary exclude">Exclude CC-BY-NC licensed records</a>
                    </g:else>
                </g:if>
            </li>
        </ul>
        %{--                            ${sr}--}%
        <div class="footer-text">* You cannot use these records for commercial purposes without the prior agreement of the data provider. Please check the licence conditions and non-commercial use guidance <a href="${grailsApplication.config.downloads?.termsOfUseUrl?:""}">here</a>.</div>
        <br>
        %{--                            <h4>Sensitive species</h4>--}%
        %{--                            <p>Your search may include records of sensitive species. Their locations may have been blurred to protect them from unnecessary harm. Higher resolution records of sensitive species may be available from the data provider.</p>--}%

        <div id="downloads" class="btn btn-primary pull-right">
            <g:if test="${maxDownloadExceeded}">
                <a href="javascript:void(0)"
                   class="tooltips newDownload"
                   title="Maximum records that can be downloaded is ${g.formatNumber(number: grailsApplication.config.maxDownloadRecords, format: "#,###,###")}. Please apply filters before downloading."
                                    >
            </g:if>
            <g:else>
                <a href="${g.createLink(uri: '/download')}?searchParams=${sr?.urlParameters?.encodeAsURL()}&licenceCount=${licenceCount ?: 0}&targetUri=${(request.forwardURI)}&totalRecords=${sr.totalRecords}"
                                       class="tooltips newDownload"
                                       title="Download all ${g.formatNumber(number: sr.totalRecords, format: "#,###,###")} records"
                                    >
            </g:else>
            <i class="fa fa-download"></i>&nbsp;&nbsp;<g:message code="list.downloads.navigator" default="Download"/></a>
        </div>

    </div>
</g:if>