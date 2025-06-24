<%@ page contentType="text/html;charset=UTF-8" %>
<asset:stylesheet src="map-button-bar.css"/>
<asset:javascript src="map-button-bar.js"/>

<!-- Semi-transparent button bar across top of map -->
<div class="map-button-bar" id="mapButtonBar">
    <!-- Left side buttons -->
    <div class="map-button-bar-left">
        <button id="mapButtonBarDrawPolygon" class="btn map-button-bar-btn" title="Draw polygon">
            <i class="fa fa-square-o"></i>
            <span>Draw polygon</span>
        </button>

        <button id="mapButtonBarTimeline" class="btn map-button-bar-btn" title="Timeline">
            <i class="fa fa-clock-o"></i>
            <span>Timeline</span>
        </button>

        <button id="mapButtonBarMapDisplay" class="btn map-button-bar-btn" title="Map display">
            <i class="fa fa-cog"></i>
            <span>Map display</span>
        </button>

        <button id="mapButtonBarLegend" class="btn map-button-bar-btn" title="Legend">
            <i class="fa fa-list"></i>
            <span>Legend</span>
        </button>
    </div>

    <!-- Right side icons -->
    <div class="map-button-bar-right">
        <button class="btn map-button-bar-icon-btn" title="More options">
            <i class="fa fa-ellipsis-h"></i>
        </button>

        <button class="btn map-button-bar-icon-btn" title="Download">
            <i class="fa fa-download"></i>
        </button>

        <button class="btn map-button-bar-icon-btn" title="Info">
            <i class="fa fa-info-circle"></i>
        </button>

        <button class="btn map-button-bar-icon-btn" title="Expand">
            <i class="fa fa-expand"></i>
        </button>
    </div>
</div>
