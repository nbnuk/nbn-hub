package uk.org.nbn.biocache.hub

class TestController {

    def changeHub(String serverName) {
        request.getSession().setAttribute("HUB",HubType.valueOfServerName(serverName))
        redirect (controller: 'home')

    }
}
