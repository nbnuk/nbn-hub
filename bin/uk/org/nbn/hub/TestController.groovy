package uk.org.nbn.hub

class TestController {

    def changeHub(String serverName) {
        request.getSession().setAttribute("HUB", HubType.valueOfServerName(serverName))
        redirect (controller: 'home')

    }
}
