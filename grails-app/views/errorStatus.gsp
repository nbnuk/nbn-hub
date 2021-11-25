<!DOCTYPE html>
<html>
<head>
    <title>Unable to complete request</title>
    <meta name="layout" content="ala"/>
</head>

<body>
<div class="heading-bar row" id="heading-bar">
    <h1 style="font-size: 200%;">
        Unable to complete request
    </h1>
</div>

<div class="row" id="content">
    <g:if test="${errorMessage && errorMessage.contains("Solr")}">
        <div class="status-message-down" style="display:block;text-align:center"role="alert">
            The NBN Atlas records search is unavailable at the moment. Please try again later.
        </div>
    </g:if>
    <g:else>
        <p style="text-align: center">
            This could just be because the Atlas is very busy. Please try again.
        </p>
    </g:else>



    <g:if test="${grails.util.Environment.current == grails.util.Environment.DEVELOPMENT || authService?.userInRole("ROLE_ADMIN")}">
        <div class="alert alert-warning" style="margin-top:2rem" role="alert">
            <h3>Below is visible to admins only</h3>
            <ul class="errors">
                <li>Error message: ${errorMessage}</li>
            </ul>
        </div>
    </g:if>
</div>
</body>
</html>
