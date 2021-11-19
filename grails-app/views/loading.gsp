
<%@ page contentType="text/html;charset=UTF-8" %>
<g:set var="hostName" value="${request.requestURL.replaceFirst(request.requestURI, '')}"/>
<g:set var="fullName" value="${grailsApplication.config.skin.orgNameLong}"/>
<g:set var="shortName" value="${grailsApplication.config.skin.orgNameShort}"/>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    <meta name="section" content="help"/>
    <title>Searching</title>

<script type="text/javascript">
    $(document).ready(function() {
        location.replace("${raw(url)}")
    })

</script>
</head>

<body>
%{--<div id="listHeader" class="heading-bar row">--}%
%{--</div>--}%
<div style="margin-top:3rem;">
<p style="text-align: center;">
<asset:image src="indicator.gif" alt="indicator icon" />
</p>

<p style="text-align: center;">
    Please wait while we search over 200 million records
</p>

</div>

%{--<p>--}%
%{--    <asset:image src="spinner.gif" alt="indicator icon"/>--}%
%{--</p>--}%
%{--<p>--}%
%{--<asset:image src="nbn/loading.gif" alt="indicator icon"/>--}%
%{--</p>--}%
</body>
</html>
