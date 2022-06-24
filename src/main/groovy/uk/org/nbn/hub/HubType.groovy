package uk.org.nbn.hub

enum HubType {
    MAIN("records"),
    WALES("wales-records"),
    SCOTLAND("scotland-records"),
    NI("northernireland-records"),
    IOM("isleofman-records")

    String hubName

    HubType(String hubName) {
        this.hubName = hubName;
    }

    public static HubType valueOfServerName(String serverName) {
        String inHubName = computeHubName(serverName);
        for (HubType e : values()) {
            if (e.hubName.equals(inHubName)) {
                return e;
            }
        }
        return MAIN;
    }

    private static String computeHubName(String serverName){
        return (!serverName || serverName.indexOf("local")>-1)?"records":serverName.substring(0,serverName.indexOf("."));
    }
}