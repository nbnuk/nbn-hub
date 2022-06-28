/**
 * Catch sort drop-down and build GET URL manually
 */
function reloadWithParam(paramName, paramValue) {
    var paramList = [];
    //var q = $.url().param('q'); //$.query.get('q')[0];
    //var fqList = $.url().param('fq'); //$.query.get('fq');
    var q = getUrlParameter_nbn('q');
    var fqList = getUrlParameterArray_nbn('fq'); //fix issue where this includes semi-colons ; which are interpreted as param separator

    var sort = $.url().param('sort');
    var dir = $.url().param('dir');
    var wkt = $.url().param('wkt');
    var pageSize = $.url().param('pageSize');
    var lat = $.url().param('lat');
    var lon = $.url().param('lon');
    var rad = $.url().param('radius');
    var taxa = $.url().param('taxa');
    // add query param
    if (q != null) {
        paramList.push("q=" + q);
    }
    // add filter query param
    if (fqList && typeof fqList === "string") {
        fqList = [ fqList ];
    } else if (!fqList) {
        fqList = [];
    }

    if (fqList) {
        paramList.push("fq=" + fqList.join("&fq="));
    }

    // add sort/dir/pageSize params if already set (different to default)
    if (paramName != 'sort' && sort != null) {
        paramList.push('sort' + "=" + sort);
    }

    if (paramName != 'dir' && dir != null) {
        paramList.push('dir' + "=" + dir);
    }

    if (paramName != 'pageSize' && pageSize != null) {
        paramList.push("pageSize=" + pageSize);
    }

    if (paramName != null && paramValue != null) {
        paramList.push(paramName + "=" + paramValue);
    }

    if (lat && lon && rad) {
        paramList.push("lat=" + lat);
        paramList.push("lon=" + lon);
        paramList.push("radius=" + rad);
    }

    if (taxa) {
        paramList.push("taxa=" + taxa);
    }

    if (wkt){
        paramList.push("wkt=" + wkt);
    }

    //alert("params = "+paramList.join("&"));
    //alert("url = "+window.location.pathname);
    window.location.href = window.location.pathname + '?' + paramList.join('&');
}

/**
 * get URL parameter - works when parameter includes semi-colons which can otherwise indicate a delimiter similar to &
 * @param sParam
 * @returns {*}
 */
var getUrlParameter_nbn = function getUrlParameter(sParam) {
    var sPageURL = window.location.search.substring(1),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : decodeURIComponent(sParameterName[1]);
        }
    }
};

var getUrlParameterArray_nbn = function getUrlParameterArray(sParam) {
    var sPageURL = window.location.search.substring(1),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    var matches = [];
    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            if (sParameterName[1] !== undefined) {
                matches.push(decodeURIComponent(sParameterName[1]));
            }
        }
    }
    return matches;
};