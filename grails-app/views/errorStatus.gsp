<!DOCTYPE html>
<html>
<head>
    <title>Unable to complete request</title>
    <meta name="layout" content="ala"/>
</head>
<body>
<div class="heading-bar row">
<h1>
    We were unable to complete your request
</h1>
</div>

<div class="row" id="content">
<g:if test="${errorMessage.contains("Solr")}">
    <p style="text-align: center">
        Atlas is struggling at the moment. Please try again later.
    </p>
</g:if>
<g:else>
<p style="text-align: center">
    This could just be because the Atlas is very busy. Please try again.
</p>
</g:else>

<g:if env="development">
    <div class="alert warn">
    <h3>This is visible in development view only</h3>
    <ul class="errors">
        <li>Error: ${errorMessage}</li>
    </ul>
    </div>
</g:if>
</div>
</body>
</html>
