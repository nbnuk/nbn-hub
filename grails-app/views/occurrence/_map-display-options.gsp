<%@ page contentType="text/html;charset=UTF-8" %>
<asset:stylesheet src="map-display-options.css"/>
<asset:javascript src="map-display-options.js"/>

<!-- Map Display Options Toggle Button -->
<div id="mapDisplayToggleContainer" class="map-display-toggle-container" style="display:none;">
    <button id="mapDisplayToggle" class="btn map-display-black-toggle-btn" title="Map display">
        <i class="fa fa-cog"></i>
        <span>Map display</span>
    </button>
</div>

<!-- Map Display Options Dialog Content -->
<div id="mapDisplayControl" class="map-display-container" style="display:none;">
    <div class="map-display-content" id="mapDisplayContent" style="display:none !important;">
        <div class="panel panel-default map-display-panel">
            <!-- Header with close button (matching timeline pattern) -->
            <div class="panel-heading map-display-figma-header">
                <div class="map-display-header-left">
                    <i class="fa fa-th map-display-menu-icon"></i>
                    <h4 class="panel-title map-display-figma-title">Map display</h4>
                </div>
                <div class="map-display-header-right">
                    <button class="btn btn-link btn-xs timeline-close-btn" id="mapDisplayCloseBtn" title="Close">
                        <i class="fa fa-times"></i>
                    </button>
                </div>
            </div>

            <div class="panel-body">
                <!-- Basemap Style Section -->
                <div class="form-group">
                    <label class="control-label map-display-section-label">Basemap style</label>
                    <div class="map-display-basemap-grid">
                        <div class="map-display-basemap-option map-display-basemap-minimal active" data-basemap="Minimal">
                            <div class="map-display-basemap-label">Minimal</div>
                        </div>
                        <div class="map-display-basemap-option map-display-basemap-road" data-basemap="Road">
                            <div class="map-display-basemap-label">Road</div>
                        </div>
                        <div class="map-display-basemap-option map-display-basemap-terrain" data-basemap="Terrain">
                            <div class="map-display-basemap-label">Terrain</div>
                        </div>
                        <div class="map-display-basemap-option map-display-basemap-satellite" data-basemap="Satellite">
                            <div class="map-display-basemap-label">Satellite</div>
                        </div>
                    </div>
                </div>

                <!-- Occurrence Display Section -->
                <div class="form-group">
                    <label class="control-label map-display-section-label">Occurrence display</label>
                    <select id="mapDisplayOccurrenceType" class="form-control map-display-dropdown">
                        <option value="variablegrid">Variable grids</option>
                        <option value="singlegrid">Responsive grids</option>
                        <option value="10kgrid">10km grids</option>
                        <option value="">Points - default colour</option>
                    </select>
                </div>

                <!-- Size and Opacity Controls (side by side) -->
                <div class="form-group map-display-controls-horizontal-container" id="gridSizeSection">
                    <div class="map-display-control-column">
                        <label class="control-label map-display-section-label">Size</label>
                        <div class="map-display-button-control-row">
                            <button type="button" class="map-display-decrement-btn" id="gridSizeDecrementBtn">
                                <i class="fa fa-minus"></i>
                            </button>
                            <span class="map-display-value-display" id="gridSizeValue">4</span>
                            <button type="button" class="map-display-increment-btn" id="gridSizeIncrementBtn">
                                <i class="fa fa-plus"></i>
                            </button>
                        </div>
                    </div>
                    <div class="map-display-control-column">
                        <label class="control-label map-display-section-label">Opacity</label>
                        <div class="map-display-button-control-row">
                            <button type="button" class="map-display-decrement-btn" id="opacityDecrementBtn">
                                <i class="fa fa-minus"></i>
                            </button>
                            <span class="map-display-value-display" id="opacityValue">60%</span>
                            <button type="button" class="map-display-increment-btn" id="opacityIncrementBtn">
                                <i class="fa fa-plus"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Outline Section -->
                <div class="form-group">
                    <div class="map-display-checkbox-container">
                        <input type="checkbox" id="mapDisplayOutline" class="map-display-checkbox">
                        <label for="mapDisplayOutline" class="map-display-checkbox-label">Outline</label>
                    </div>
                </div>

                <!-- Apply Button Section -->
                <div class="form-group" style="text-align: center; margin-top: 20px; padding-top: 15px; border-top: 1px solid #eee;">
                    <button id="applyMapDisplayBtn" class="btn btn-default" style="background: white !important; border: 2px solid #000 !important; color: #000 !important; padding: 10px 30px; font-weight: 500; border-radius: 8px !important;">
                        Apply
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>
