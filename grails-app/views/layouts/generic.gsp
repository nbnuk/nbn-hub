<%@ page import="org.apache.commons.lang.StringUtils" contentType="text/html;charset=UTF-8" %>
<g:applyLayout name="main">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="description" content="${grailsApplication.config.skin.orgNameLong}"/>
    <meta name="author" content="${grailsApplication.config.skin.orgNameLong}">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><g:layoutTitle /></title>
    <asset:stylesheet src="alaBs.css" />
    <asset:javascript src="alaBs.js" />

    <g:layoutHead />

    <script type="text/javascript">
        var NBN = NBN || {}
        <g:if test="${record}">
        NBN.recordIsAbsent = ${record.raw.occurrence.occurrenceStatus && StringUtils.containsIgnoreCase( record.raw.occurrence.occurrenceStatus, 'absent' )};
        NBN.showFlaggedIssues = ${showFlaggedIssues};
        NBN.isCollectionAdmin = ${isCollectionAdmin};
        NBN.userAssertions50006Label = "<alatag:message code="user_assertions.50006" default="To delete"/>";
        </g:if>
    </script>

    <script src="/assets/application.js" ></script>
</head>
<body class="${pageProperty(name:'body.class')?:'nav-datasets'}" id="${pageProperty(name:'body.id')}" onload="${pageProperty(name:'body.onload')}">
<g:set var="fluidLayout" value="${grailsApplication.config.skin.fluidLayout?.toBoolean()}"/>
<div class="${fluidLayout?'container-fluid':'container'}" id="main-content">
    <g:layoutBody />
</div>

<div class="${fluidLayout?'container-fluid':'container'} hidden-lg">
    <%-- Borrowed from http://marcusasplund.com/optout/ --%>
    <a class="btn toggleResponsive btn-default btn-sm"><i class="icon-resize-full"></i> <span>Desktop</span> version</a>
    %{--<a class="btn toggleResponsive btn-default btn-sm"><i class="icon-resize-full"></i> Desktop version</a>--}%
</div>


</body>
</g:applyLayout>