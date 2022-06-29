<%@ page import="org.apache.commons.lang.StringUtils" contentType="text/html;charset=UTF-8" %>

<asset:script type="text/javascript">
    var BC_CONF = BC_CONF || { contextPath: "${request.contextPath}", locale: "${(org.springframework.web.servlet.support.RequestContextUtils.getLocale(request).toString())?:request.locale}" }
</asset:script>
<script type="text/javascript">
    var NBN = NBN || {}
    <g:if test="${record}">
        NBN.recordIsAbsent = ${record.raw.occurrence.occurrenceStatus && StringUtils.containsIgnoreCase( record.raw.occurrence.occurrenceStatus, 'absent' )};
        NBN.showFlaggedIssues = ${showFlaggedIssues};
        NBN.isCollectionAdmin = ${isCollectionAdmin};
        NBN.userAssertions50006Label = "<alatag:message code="user_assertions.50006" default="To delete"/>";
    </g:if>
</script>