<!DOCTYPE html>
<html>
<head>
    <title>Unable to complete request</title>
    <meta name="layout" content="ala"/>
</head>
<body>
<div class="heading-bar row">
<h1>
    Unable to complete request
</h1>
</div>

<div class="row" id="content">
<g:if test="${errorMessage.contains("Solr")}">
    <div class="alert alert-warning text-center" role="alert">
        Atlas is temporarily down at the moment. Please try again later.
    </div>
</g:if>
<g:else>
<p style="text-align: center">
    This could just be because the Atlas is very busy. Please try again.
</p>
</g:else>

<g:if env="development">
    <div class="alert alert-warning" role="alert">
    <h3>Below is visible in development view only</h3>
    <ul class="errors">
        <li>Error: ${errorMessage}</li>
    </ul>
    </div>
</g:if>
</div>
</body>
</html>
