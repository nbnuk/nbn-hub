<%@ page import="groovy.json.JsonOutput" %>
<!doctype html>
<html lang="en">
<head>
    <meta name="layout" content="none"/>
    <meta charset="utf-8"/>
    <title>Leaflet + NBN Atlas WMS</title>
    <meta name="viewport" content="width=device-width,initial-scale=1"/>
    <link
            rel="stylesheet"
            href="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.css"
            integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
            crossorigin=""/>
    <style>
    html, body {
        height: 100%;
        margin: 0;
    }

    #map {
        height: 100%;
    }

    .legend {
        background: #fff;
        padding: 8px 10px;
        border-radius: 4px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, .2);
        font: 14px/1.3 system-ui, -apple-system, Segoe UI, Roboto, sans-serif;
    }
    </style>
</head>

<body>
<div id="map"></div>

<script src="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.js"
        integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
        crossorigin=""></script>

<script>
    const params = ${raw(JsonOutput.toJson(initialParams))};
    console.log("params: ", params);
    const bbox = params.bbox;
    const q = params.q;
    // Normalise any fq parameters to an array of strings
    const fqArray = Array.isArray(params.fq)
        ? params.fq
        : (typeof params.fq === 'string' && params.fq.length > 0)
            ? [params.fq]
            : [];
    const qc = params.qc;
    const env = params.ENV;
    const style = params.STYLE;
    const styles = params.styles;
    const format = params.format;
    const transparent = params.transparent;
    const height = params.height;
    const width = params.width;
    const bgColor = params.bgcolor;
    const outline = params.outline;
    const gridDetail = params.GRIDDETAIL;
    const layers = params.layers;
    const request = params.request;
    const service = params.service;
    const extraFq = fqArray
        .filter(fq => fq !== '-occurrence_status:absent')
        .map(value => '&fq=' + encodeURIComponent(value))
        .join('');

    let mapBBox = null;
    let wmsLayer;

    const boundsUrl = new URL('http://localhost:8081/mapping/bounds.json');
    const boundsParams = new URLSearchParams();
    boundsParams.set('q', q);
    if (qc) {
        boundsParams.set('qc', qc);
    }
    let boundsURL = boundsParams.toString();
    if (fqArray && fqArray.length > 0) {
        boundsURL = boundsURL + extraFq;
    }
    boundsUrl.search = boundsURL;

    // Leaflet map
    const map = L.map('map', {
        worldCopyJump: true,
        zoomControl: false,
        scrollWheelZoom: false,
        doubleClickZoom: false,
        touchZoom: false,
        dragging: false,
        boxZoom: false,
        keyboard: false
    }).setView([54.5, -2.5], 6);

    L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png', {
        maxZoom: 18,
        attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright" target="_top">OpenStreetMap</a>, imagery &copy; <a href="https://carto.com/attribution" target="_top">CartoDB</a>'
    }).addTo(map);

    function tryFitBounds(payload) {
        // Expecting: [lonMin, latMin, lonMax, latMax]
        if (!Array.isArray(payload) || payload.length !== 4) return false;

        const sw = L.latLng(payload[1], payload[0]);
        const ne = L.latLng(payload[3], payload[2]);
        const dataBounds = L.latLngBounds(sw, ne);

        if (
            [payload[0], payload[1], payload[2], payload[3]].some(v => !Number.isFinite(v))
        ) return false;

        map.fitBounds(dataBounds);

        return true;
    }

    async function fetchBounds() {
        try {
            console.log('Requesting:', boundsUrl.toString());
            const res = await fetch(boundsUrl.toString(), {
                headers: {'Accept': 'application/json'}
            });

            if (!res.ok) {
                %{--throw new Error(`HTTP ${res.status} ${res.statusText}`);--}%
            }

            const data = await res.json();
            mapBBox = data;
            console.log('Bounds response:', data);

            const fitted = tryFitBounds(data);

            if (!fitted) {
                console.warn('Could not infer bounds shape from payload; showing center/zoom default.');
            }
        } catch (err) {
            console.error('fetchBounds error:', err);
        } finally {
            wmsLayer = createWmsLayer().addTo(map);
        }
    }

    if (bbox) {
        tryFitBounds(bbox);
    } else {
        fetchBounds();
    }

    function createWmsLayer() {
        const wmsUrl = 'http://localhost:8081/mapping/wms/reflect';
        // const wmsUrl = 'https://legacy-records-ws.nbnatlas.org/mapping/wms/reflect';

        const layer = L.tileLayer.wms(wmsUrl, {
            version: '1.1.1',
            layers: layers,
            transparent: transparent,
            uppercase: true,
            tiled: true,
            q: q,
            qc: qc,
            REQUEST: request,
            service: service,
            outline: outline,
            format: format,
            bgcolor: bgColor,
            ENV: env,
            STYLE: style,
            GRIDDETAIL: gridDetail,
            height: height,
            width: width,
        });

        const baseGetTileUrl = layer.getTileUrl.bind(layer);

        // Override getTileUrl to append fq multiple times
        layer.getTileUrl = function (coords) {
            let url = baseGetTileUrl(coords);
            if (fqArray && fqArray.length > 0) {
                url += extraFq;
            }
            return url;
        };
        return layer;
    }

</script>
</body>
</html>
