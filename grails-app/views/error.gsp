<!DOCTYPE html>
<html>
<head>
    <title><g:if env="development">Grails Runtime Exception</g:if><g:else>Error</g:else></title>
    <meta name="layout" content="ala"/>
    <g:if env="development"><asset:stylesheet src="errors.css" type="text/css"/></g:if>
</head>
<body>
<h1>
    An error has occurred
</h1>

<ul class="errors">
    <g:if test="${exception?.cause?.target?.message?.indexOf("412")>-1}">
        <li>Not permitted. A precondition was not met.</li>
    </g:if>
    <g:else>
        <li>Error: unknown</li>
    </g:else>
</ul>

<g:if env="development">
    <g:renderException exception="${exception}" />
</g:if>

<g:if test="${flash.message}">
    <ul class="errors">
        <li>${flash.message}</li>
    </ul>
</g:if>
</body>
</html>
