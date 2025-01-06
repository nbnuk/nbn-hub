package uk.org.nbn.hub

class CrossDomainProxyController {

    def authService

    def allowedUrls = [
            "${grailsApplication.config.savedsearch.serverURL}/component/listModal",
            "${grailsApplication.config.savedsearch.serverURL}/component/createModal",
            "${grailsApplication.config.savedsearch.serverURL}/hx/component/save",
            "${grailsApplication.config.savedsearch.serverURL}/hx/component/listInner",
            "${grailsApplication.config.savedsearch.serverURL}/hx/component/createInner"
    ]

    def index() {
        if (!allowedUrls.contains(params.url)) {
            render status: 403, text: "Forbidden"
            return
        }

        if (request.getMethod() == "GET") {
            return _get()
        }
        else if (request.getMethod() == "POST") {
            return _post()
        }

        render status: 403, text: "Forbidden"
        return
    }

    def _get() {
        def userId = authService.getUserId()
        def apiKey = grailsApplication.config.biocache.apiKey
        def targetUrl = new URL(params.url + "?userId=$userId")
        def connection = targetUrl.openConnection()
        connection.setRequestProperty("Authorization", apiKey)
        connection.connect()

        def responseText = connection.responseCode == 200 ? connection.inputStream.text : connection.errorStream?.text ?: "Unknown error"

        render status: connection.responseCode, text: responseText

    }

    def _post() {
        def userId = authService.getUserId()
        def apiKey = grailsApplication.config.biocache.apiKey

        def targetUrl = new URL(params.url)
        def connection = targetUrl.openConnection()

        log.debug("userId: $userId targetUrl: $params.url")

        connection.doOutput = true
        connection.requestMethod = "POST"
        connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded")
        connection.setRequestProperty("Authorization", apiKey)

        def postData = params.findAll { key, value -> key != 'url' }
                .collect { key, value -> "${URLEncoder.encode(key, 'UTF-8')}=${URLEncoder.encode(value.toString(), 'UTF-8')}" }
                .join("&")
        postData += "&userId=${userId?URLEncoder.encode(userId, 'UTF-8'):""}"

        connection.outputStream.withWriter("UTF-8") { writer ->
            writer.write(postData)
        }
        def responseText = connection.responseCode == 200 ? connection.inputStream.text : connection.errorStream?.text ?: "Unknown error"
        render status: connection.responseCode, text: responseText

    }
}
