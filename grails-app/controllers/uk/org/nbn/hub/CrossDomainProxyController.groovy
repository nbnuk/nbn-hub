package uk.org.nbn.hub

class CrossDomainProxyController {

    def authService

    def allowedUrls = [
            "${grailsApplication.config.savedsearch.serverURL}/component/listModal".toString(),
            "${grailsApplication.config.savedsearch.serverURL}/component/createModal".toString(),
            "${grailsApplication.config.savedsearch.serverURL}/component/save".toString(),
            "${grailsApplication.config.savedsearch.serverURL}/component/list".toString(),
            "${grailsApplication.config.savedsearch.serverURL}/component/createForm.toString()"
    ]

    def index() {

        String baseUrl = params.url?.tokenize('?')[0]?.trim()

        println(params)
        println(allowedUrls)

        for (String url in allowedUrls) {
            println("allowedUrl :"+url+":")
        }
        println("baseUrl :"+baseUrl+":")
        println("allowed? "+allowedUrls.contains(baseUrl))
        if (!allowedUrls.contains(baseUrl)) {
            println("Forbidden")
            render status: 403, text: "Forbidden"
            return
        }
        println("proceed")
        if (request.getMethod() == "GET") {
            return _get()
        }
        else if (request.getMethod() == "POST") {
            return _post()
        }

        render status: 403, text: "Forbidden"
        return
    }

    def _get() {println("!!!!!!!!!!!!GET")
        def userId = authService.getUserId()
        def apiKey = grailsApplication.config.biocache.apiKey
        def targetUrl = new URL(params.url + "&userId=${userId}")
        def connection = targetUrl.openConnection()
        connection.setRequestProperty("Authorization", apiKey)
        connection.connect()
println(2)
        def responseText = connection.responseCode == 200 ? connection.inputStream.text : connection.errorStream?.text ?: "Unknown error"
println(responseText)
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
