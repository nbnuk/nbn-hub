// locations to search for config files that get merged into the main config;
// config files can be ConfigSlurper scripts, Java properties files, or classes
// in the classpath in ConfigSlurper format

// grails.config.locations = [ "classpath:${appName}-config.properties",
//                             "classpath:${appName}-config.groovy",
//                             "file:${userHome}/.grails/${appName}-config.properties",
//                             "file:${userHome}/.grails/${appName}-config.groovy"]

// if (System.properties["${appName}.config.location"]) {
//    grails.config.locations << "file:" + System.properties["${appName}.config.location"]
// }

grails.project.groupId = "uk.org.nbn" // change this to alter the default package name and Maven publishing destination

default_config = "/data/${appName}/config/${appName}-config.properties"
if(!grails.config.locations || !(grails.config.locations instanceof List)) {
    grails.config.locations = []
}
if (new File(default_config).exists()) {
    println "[${appName}] Including default configuration file: " + default_config;
    grails.config.locations.add "file:" + default_config
} else {
    println "[${appName}] No external configuration file defined."
}

println "[${appName}] (*) grails.config.locations = ${grails.config.locations}"
//println "default_config = ${default_config}"

/******************************************************************************\
 *  SKINNING
\******************************************************************************/
skin.layout = 'ala'
skin.orgNameLong = "Atlas of Living Australia"
skin.orgNameShort = "ALA"
// whether crumb trail should include a home link that is external to this webabpp - ala.baseUrl is used if true
skin.includeBaseUrl = true
skin.taxaLinks.baseUrl = "https://bie.ala.org.au/species/"
skin.headerUrl = "classpath:resources/generic-header.jsp" // can be external URL
skin.footerUrl = "classpath:resources/generic-footer.jsp" // can be external URL
skin.fluidLayout = true // true or false
skin.exploreUrl = "https://www.ala.org.au/explore-by-location/"

/******************************************************************************\
 *  EXTERNAL SERVERS
\******************************************************************************/

/******************************************************************************\
 *  MISC
\******************************************************************************/

/******************************************************************************\
 *  CAS SETTINGS
 *
 *  NOTE: Some of these will be ignored if default_config exists
\******************************************************************************/
grails.serverURL = 'https://biocache.ala.org.au'
serverName = 'https://biocache.ala.org.au'
security.cas.appServerName = "https://biocache.ala.org.au"
security.cas.casServerName = 'https://auth.ala.org.au'
security.cas.loginUrl = 'https://auth.ala.org.au/cas/login'
security.cas.logoutUrl = 'https://auth.ala.org.au/cas/logout'
security.cas.casServerUrlPrefix = 'https://auth.ala.org.au/cas'
security.cas.bypass = false // set to true for non-ALA deployment
auth.admin_role = "ROLE_ADMIN"

skin.fluidLayout = true
skin.useAlaSpatialPortal = true
skin.useAlaBie = true
skin.taxaLinks.baseUrl = "https://bie.ala.org.au/species/" // 3rd party species pages. Leave blank for no links
test.var = "nbn-hub"
skin.dataQualityLink.show = false // set to true via external config
skin.dataQualityLink.url = "https://biocache-dq-test.ala.org.au"
skin.dataQualityLink.text = "Try the new search interface with automatic filtering based on data quality metrics"
skin.dataQualityLink.tooltip = "Click to run the current search on our test server"

// facets.includeDynamicFacets = true // for sandbox

// The ACCEPT header will not be used for content negotiation for user agents containing the following strings (defaults to the 4 major rendering engines)
grails.mime.disable.accept.header.userAgents = ['Gecko', 'WebKit', 'Presto', 'Trident']
grails.mime.types = [ // the first one is the default format
    all:           '*/*', // 'all' maps to '*' or the first available format in withFormat
    atom:          'application/atom+xml',
    css:           'text/css',
    csv:           'text/csv',
    form:          'application/x-www-form-urlencoded',
    html:          ['text/html','application/xhtml+xml'],
    js:            'text/javascript',
    json:          ['application/json', 'text/json'],
    multipartForm: 'multipart/form-data',
    rss:           'application/rss+xml',
    text:          'text/plain',
    hal:           ['application/hal+json','application/hal+xml'],
    xml:           ['text/xml', 'application/xml']
]

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000


// Legacy setting for codec used to encode data with ${}
grails.views.default.codec = "html"

// The default scope for controllers. May be prototype, session or singleton.
// If unspecified, controllers are prototype scoped.
grails.controllers.defaultScope = 'singleton'

grails.databinding.convertEmptyStringsToNull = false

// GSP settings
grails {
    views {
        gsp {
            encoding = 'UTF-8'
            htmlcodec = 'xml' // use xml escaping instead of HTML4 escaping
            codecs {
                expression = 'html' // escapes values inside ${}
                scriptlet = 'html' // escapes output from scriptlets in GSPs
                taglib = 'none' // escapes output from taglibs
                staticparts = 'none' // escapes output from static template parts
            }
        }
        // escapes all not-encoded output at final stage of outputting
        filteringCodecForContentType {
            //'text/html' = 'html'
        }
    }
}
 
grails.converters.encoding = "UTF-8"
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []
// whether to disable processing of multi part requests
grails.web.disable.multipart=false

// request parameters to mask when logging exceptions
grails.exceptionresolver.params.exclude = ['password']

// configure auto-caching of queries by default (if false you can cache individual queries with 'cache: true')
grails.hibernate.cache.queries = false

environments {
    development {
        serverName = 'http://dev.ala.org.au:8080'
        grails.serverURL = 'http://dev.ala.org.au:8080/' + appName
//        security.cas.appServerName = serverName
//        security.cas.contextPath = "/${appName}"
          //grails.resources.debug = true // cache & resources plugins
    }
    test {
//        grails.serverURL = 'http://130.220.209.134:8080/'
//        serverName='http://130.220.209.134:8080/'
//        security.cas.appServerName = serverName
//        security.cas.contextPath = "/${appName}"

//        security.cas.appServerName = 'http://devt.ala.org.au:8080/'

    }
    production {
//        grails.serverURL = 'https://biocache.ala.org.au'
//        serverName='https://biocache.ala.org.au'
//        security.cas.appServerName = serverName
//        security.cas.contextPath = ""
    }
}

//Restrict sandbox data access to drts by userid or admin
// security.cas.uriFilterPattern=/proxy/.*,/occurrences/.*
// biocache.ajax.useProxy=true
// sandbox.access.restricted=true
