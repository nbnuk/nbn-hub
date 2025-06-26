// Map Display Options JavaScript - Phase 1: Basic Dialog Structure
// Following timeline-simple.js pattern for consistency

var MapDisplayOptions = {
    // Configuration
    config: {
        ajaxTimeout: 30000,
        animationDuration: 200
    },

    // Current state - now with original state tracking for Apply functionality
    state: {
        basemap: 'Minimal',
        occurrenceDisplay: 'variablegrid',
        gridSize: 4,
        opacity: 0.6, // 60% to match Figma design
        outline: false,
        isOpen: false,
        isInitialized: false,
        originalParams: null,  // Store original state for rollback (like Timeline)
        pendingChanges: {},    // Track changes before Apply
        isApplying: false      // Prevent concurrent applies
    },

    /**
     * Initialize the map display options dialog
     */
    initialize: function() {
        if (this.state.isInitialized) {
            console.log('MapDisplayOptions: Already initialized');
            return;
        }

        console.log('MapDisplayOptions: Initializing dialog');

        // CRITICAL: Disable any existing Bootstrap sliders that might still be active
        this.disableOriginalSliders();

        this.bindEvents();
        this.initializeUIState();
        this.state.isInitialized = true;
        console.log('MapDisplayOptions: Dialog initialized');
    },

    /**
     * Disable original Bootstrap sliders to prevent immediate map updates
     */
    disableOriginalSliders: function() {
        console.log('MapDisplayOptions: Disabling original Bootstrap sliders');

        try {
            // Destroy any existing Bootstrap slider on opacity element
            if ($('#opacityslider').length && $('#opacityslider').data('slider')) {
                console.log('MapDisplayOptions: Found active Bootstrap opacity slider, destroying it');
                $('#opacityslider').slider('destroy');
                console.log('MapDisplayOptions: Bootstrap opacity slider destroyed');
            }

            // Also disable any slider on size element for consistency
            if ($('#sizeslider').length && $('#sizeslider').data('slider')) {
                console.log('MapDisplayOptions: Found active Bootstrap size slider, destroying it');
                $('#sizeslider').slider('destroy');
                console.log('MapDisplayOptions: Bootstrap size slider destroyed');
            }

                    // Remove any event handlers that might still be bound
        $('#opacityslider').off();
        $('#sizeslider').off();

        // Remove any potential Bootstrap slider event delegation
        $(document).off('click.slider.data-api mousedown.slider.data-api');

        // Explicitly prevent any slider reinitialization
        $('#opacityslider, #sizeslider').addClass('slider-disabled');

            console.log('MapDisplayOptions: Original sliders disabled successfully');
        } catch (error) {
            console.warn('MapDisplayOptions: Error disabling original sliders:', error);
            // Continue even if there's an error - sliders might not exist
        }
    },

    /**
     * Initialize UI state
     */
    initializeUIState: function() {
        // Make sure the dialog starts in the correct state
        $('#mapDisplayToggle').removeClass('active');
        $('#mapDisplayContent').removeClass('show').hide();

        // Set initial values in the UI (placeholder values for Phase 1)
        this.updateDialogUI();

        console.log('MapDisplayOptions: UI state initialized');
    },

    /**
     * Update dialog UI to reflect current state
     */
    updateDialogUI: function() {
        console.log('MapDisplayOptions: Updating dialog UI to match current state');

        // Update basemap selection
        $('.basemap-btn').removeClass('active');
        $('.basemap-btn[data-basemap="' + this.state.basemap + '"]').addClass('active');

        // Update occurrence display selection
        $('input[name="occurrenceDisplay"][value="' + this.state.occurrenceDisplay + '"]').prop('checked', true);

        // Update grid size display
        $('#gridSizeValue').text(this.state.gridSize);
        $('#gridSizeSlider').val(this.state.gridSize);

        // Update opacity display (convert to percentage)
        var opacityPercent = Math.round(this.state.opacity * 100);
        $('#opacityValue').text(opacityPercent + '%');
        $('#opacitySlider').val(opacityPercent);

        // Update outline checkbox
        $('#outlineCheck').prop('checked', this.state.outline);

        // Show/hide grid options based on occurrence display
        this.toggleGridOptions(this.state.occurrenceDisplay);

        console.log('MapDisplayOptions: Dialog UI updated');
    },

    /**
     * Toggle the dialog panel visibility (following timeline pattern)
     */
    togglePanel: function() {
        var content = $('#mapDisplayContent');
        var container = $('#mapDisplayControl');
        var toggle = $('#mapDisplayToggle');
        var isVisible = content.hasClass('show');

        console.log('MapDisplayOptions: Toggling panel, currently visible:', isVisible);

        if (isVisible) {
            this.closePanel();
        } else {
            this.openPanel();
        }
    },

    /**
     * Open the dialog panel
     */
    openPanel: function() {
        var content = $('#mapDisplayContent');
        var container = $('#mapDisplayControl');
        var toggle = $('#mapDisplayToggle');

        // Load current map state when opening (like Timeline does)
        this.loadCurrentMapState();

        content.addClass('show').slideDown(this.config.animationDuration);
        container.addClass('show');
        toggle.addClass('active');
        this.state.isOpen = true;

        console.log('MapDisplayOptions: Panel opened');
    },

    /**
     * Load current map state from existing DOM elements (like Timeline does)
     */
    loadCurrentMapState: function() {
        console.log('MapDisplayOptions: Loading current map state from existing elements');

        // Read from existing DOM elements that the old controls used
        var currentOccurrenceDisplay = $('#colourBySelect').val() || 'variablegrid';
        var currentSize = parseInt($('#sizeslider-val').html()) || 4;
        var currentOpacity = parseFloat($('#opacityslider-val').html()) || 0.8;
        var currentOutline = $('#outlineDots').is(':checked') || false;

        // Determine current basemap from MAP_VAR if available
        var currentBasemap = 'Minimal'; // default
        if (typeof MAP_VAR !== 'undefined' && MAP_VAR.map) {
            // Find which basemap is currently active
            for (var layerName in MAP_VAR.baseLayers) {
                if (MAP_VAR.map.hasLayer(MAP_VAR.baseLayers[layerName])) {
                    currentBasemap = layerName;
                    break;
                }
            }
        }

        // Update state with current values
        this.state.basemap = currentBasemap;
        this.state.occurrenceDisplay = currentOccurrenceDisplay;
        this.state.gridSize = currentSize;
        this.state.opacity = currentOpacity;
        this.state.outline = currentOutline;

        // Update UI to reflect current state
        this.updateDialogUI();

        // Reset pending changes
        this.state.pendingChanges = {};

        console.log('MapDisplayOptions: Current state loaded:', {
            basemap: currentBasemap,
            occurrenceDisplay: currentOccurrenceDisplay,
            gridSize: currentSize,
            opacity: currentOpacity,
            outline: currentOutline
        });
    },

    /**
     * Close the dialog panel
     */
    closePanel: function() {
        var content = $('#mapDisplayContent');
        var container = $('#mapDisplayControl');
        var toggle = $('#mapDisplayToggle');

        content.removeClass('show').slideUp(this.config.animationDuration);
        container.removeClass('show');
        toggle.removeClass('active');
        this.state.isOpen = false;

        console.log('MapDisplayOptions: Panel closed');

        // Emit event for button bar integration
        $(document).trigger('mapDisplayDialogClosed');
    },

    /**
     * Handle basemap selection changes
     */
    selectBasemap: function(basemapType) {
        console.log('MapDisplayOptions: Basemap selected:', basemapType);

        // Update state (will be applied when Apply is clicked)
        this.state.basemap = basemapType;

        // Update UI to show selection
        $('.basemap-btn').removeClass('active');
        $('.basemap-btn[data-basemap="' + basemapType + '"]').addClass('active');

        // Track pending change
        this.state.pendingChanges.basemap = basemapType;

        console.log('MapDisplayOptions: Basemap change tracked, will apply on Apply button');
    },

    /**
     * Handle occurrence display type changes
     */
    changeOccurrenceDisplay: function(displayType) {
        console.log('MapDisplayOptions: Occurrence display changed:', displayType);

        // Update state (will be applied when Apply is clicked)
        this.state.occurrenceDisplay = displayType;

        // Show/hide grid options
        this.toggleGridOptions(displayType);

        // Track pending change
        this.state.pendingChanges.occurrenceDisplay = displayType;

        console.log('MapDisplayOptions: Occurrence display change tracked, will apply on Apply button');
    },

    /**
     * Show/hide grid size section based on occurrence display type
     */
    toggleGridOptions: function(displayType) {
        var gridSection = $('#gridSizeSection');
        var isGridType = ['variablegrid', 'singlegrid', '10kgrid'].includes(displayType);

        if (isGridType) {
            gridSection.show();
        } else {
            gridSection.hide();
        }

        console.log('MapDisplayOptions: Grid options visibility:', isGridType ? 'visible' : 'hidden');
    },

    /**
     * Handle grid size changes
     */
    changeGridSize: function(newSize) {
        console.log('MapDisplayOptions: ===== changeGridSize CALLED =====');
        console.log('MapDisplayOptions: Grid size changed:', newSize);
        console.log('MapDisplayOptions: Current state.isApplying:', this.state.isApplying);

        // Ensure size stays within bounds
        newSize = Math.max(1, Math.min(10, newSize));
        console.log('MapDisplayOptions: Size after bounds check:', newSize);

        // Update state (will be applied when Apply is clicked)
        this.state.gridSize = newSize;
        console.log('MapDisplayOptions: Updated internal state.gridSize to:', this.state.gridSize);

        // Update display
        console.log('MapDisplayOptions: About to update dialog UI element #gridSizeValue');
        $('#gridSizeValue').text(newSize);
        console.log('MapDisplayOptions: Updated #gridSizeValue to:', $('#gridSizeValue').text());

        // Track pending change
        this.state.pendingChanges.gridSize = newSize;
        console.log('MapDisplayOptions: Added to pendingChanges:', this.state.pendingChanges);

        console.log('MapDisplayOptions: Grid size change tracked, will apply on Apply button');
        console.log('MapDisplayOptions: ===== changeGridSize COMPLETED =====');

        // IMPORTANT: This function should NOT call any server functions
        // Server functions should only be called from applyServerSideChanges()
    },

    /**
     * Increment grid size
     */
    incrementGridSize: function() {
        this.changeGridSize(this.state.gridSize + 1);
    },

    /**
     * Decrement grid size
     */
    decrementGridSize: function() {
        this.changeGridSize(this.state.gridSize - 1);
    },

    /**
     * Handle opacity changes
     */
    changeOpacity: function(newOpacity) {
        console.log('MapDisplayOptions: ===== changeOpacity CALLED =====');
        console.log('MapDisplayOptions: Opacity changed:', newOpacity);
        console.log('MapDisplayOptions: Current state.isApplying:', this.state.isApplying);

        // Prevent opacity changes during apply process to avoid infinite loops
        if (this.state.isApplying) {
            console.log('MapDisplayOptions: Opacity change blocked - apply in progress');
            return;
        }

        // Ensure opacity stays within bounds (0-100 for percentage display)
        newOpacity = Math.max(0, Math.min(100, newOpacity));
        console.log('MapDisplayOptions: Opacity after bounds check:', newOpacity);

        // Update state (convert to decimal for internal state, will be applied when Apply is clicked)
        this.state.opacity = newOpacity / 100;
        console.log('MapDisplayOptions: Updated internal state.opacity to:', this.state.opacity);

        // Update display (show as percentage)
        console.log('MapDisplayOptions: About to update dialog UI element #opacityValue');
        $('#opacityValue').text(newOpacity + '%');
        console.log('MapDisplayOptions: Updated #opacityValue to:', $('#opacityValue').text());

        // Track pending change
        this.state.pendingChanges.opacity = this.state.opacity;
        console.log('MapDisplayOptions: Added to pendingChanges:', this.state.pendingChanges);

        console.log('MapDisplayOptions: Opacity change tracked, will apply on Apply button');
        console.log('MapDisplayOptions: ===== changeOpacity COMPLETED =====');

        // IMPORTANT: This function should NOT call any server functions or immediate map updates
        // Server functions should only be called from applyServerSideChanges()
    },

    /**
     * Increment opacity (by 10%)
     */
    incrementOpacity: function() {
        var currentPercent = Math.round(this.state.opacity * 100);
        this.changeOpacity(currentPercent + 10);
    },

    /**
     * Decrement opacity (by 10%)
     */
    decrementOpacity: function() {
        var currentPercent = Math.round(this.state.opacity * 100);
        this.changeOpacity(currentPercent - 10);
    },

    /**
     * Handle outline checkbox changes
     */
    toggleOutline: function(enabled) {
        console.log('MapDisplayOptions: Outline toggled:', enabled);

        // Update state (will be applied when Apply is clicked)
        this.state.outline = enabled;

        // Track pending change
        this.state.pendingChanges.outline = enabled;

        console.log('MapDisplayOptions: Outline change tracked, will apply on Apply button');
    },

    /**
     * Apply all changes - Phase 4 Implementation following Timeline pattern
     */
    applyChanges: function() {
        console.log('MapDisplayOptions: Apply changes requested');

        if (this.state.isApplying) {
            console.log('MapDisplayOptions: Apply already in progress, ignoring');
            return;
        }

                try {
            this.state.isApplying = true;

            // 1. Validate changes first
            if (!this.validateChanges()) {
                this.state.isApplying = false;
                return;
            }

            // 2. Store original state if not already stored (like Timeline does)
            if (!this.state.originalParams) {
                this.state.originalParams = this.getCurrentMapParams();
                console.log('MapDisplayOptions: Original params stored:', this.state.originalParams);
            }

            // 3. Apply server-side changes first (following Timeline pattern)
            console.log('MapDisplayOptions: Applying server-side changes');
            this.applyServerSideChanges();

            // 4. Apply client-side changes
            console.log('MapDisplayOptions: Applying client-side changes');
            this.applyClientSideChanges();

            // 5. Success - show message and close dialog
            this.showMessage('success', 'Map display settings applied successfully');

            // Clear pending changes since they're now applied
            this.state.pendingChanges = {};

            // Close dialog on success (like Timeline)
            this.closePanel();

        } catch (error) {
            console.error('MapDisplayOptions: Apply failed:', error);
            this.showMessage('error', 'Failed to apply changes: ' + error.message);
            // Keep dialog open for retry (like Timeline)
        } finally {
            this.state.isApplying = false;
        }
    },

    /**
     * Validate changes before applying (following Timeline pattern)
     */
    validateChanges: function() {
        console.log('MapDisplayOptions: Validating changes');

        // Check if we have any changes to apply
        if (Object.keys(this.state.pendingChanges).length === 0) {
            this.showMessage('info', 'No changes to apply');
            return false;
        }

        // Validate basemap selection
        if (this.state.pendingChanges.basemap) {
            var validBasemaps = ['Minimal', 'Road', 'Terrain', 'Satellite'];
            if (!validBasemaps.includes(this.state.basemap)) {
                this.showMessage('error', 'Invalid basemap selection: ' + this.state.basemap);
                return false;
            }
        }

        // Validate occurrence display
        if (this.state.pendingChanges.occurrenceDisplay) {
            var validDisplayTypes = ['variablegrid', 'singlegrid', '10kgrid', 'coordinate_uncertainty'];
            if (!validDisplayTypes.includes(this.state.occurrenceDisplay)) {
                this.showMessage('error', 'Invalid occurrence display type: ' + this.state.occurrenceDisplay);
                return false;
            }
        }

        // Validate grid size
        if (this.state.pendingChanges.gridSize) {
            if (this.state.gridSize < 1 || this.state.gridSize > 10) {
                this.showMessage('error', 'Grid size must be between 1 and 10');
                return false;
            }
        }

        // Validate opacity
        if (this.state.pendingChanges.opacity) {
            if (this.state.opacity < 0 || this.state.opacity > 1) {
                this.showMessage('error', 'Opacity must be between 0% and 100%');
                return false;
            }
        }

        // Check if required functions are available for server-side changes
        var hasServerSideChanges = this.state.pendingChanges.occurrenceDisplay ||
                                   this.state.pendingChanges.gridSize ||
                                   this.state.pendingChanges.opacity !== undefined ||
                                   this.state.pendingChanges.outline !== undefined;

        if (hasServerSideChanges) {
            if (typeof changeFacetColours !== 'function') {
                this.showMessage('error', 'Map update function not available. Please refresh the page.');
                return false;
            }
        }

        console.log('MapDisplayOptions: Validation passed');
        return true;
    },

    /**
     * Get current map parameters for state storage (like Timeline)
     */
    getCurrentMapParams: function() {
        var params = {};

        try {
            // Get current values from existing map controls
            params.colourByFacet = $('#colourBySelect').val() || 'variablegrid';
            params.pointSize = $('#sizeslider-val').html() || '4';
            params.opacity = $('#opacityslider-val').html() || '0.6';
            params.outlineDots = $('#outlineDots').is(':checked') || false;

            // Get current basemap (if available in MAP_VAR)
            if (typeof MAP_VAR !== 'undefined' && MAP_VAR.currentBasemap) {
                params.basemap = MAP_VAR.currentBasemap;
            }

            console.log('MapDisplayOptions: Current map params extracted:', params);
        } catch (error) {
            console.warn('MapDisplayOptions: Could not extract current params:', error);
            // Use defaults if extraction fails
            params = {
                colourByFacet: 'variablegrid',
                pointSize: '4',
                opacity: '0.6',
                outlineDots: false,
                basemap: 'Minimal'
            };
        }

        return params;
    },

    /**
     * Apply server-side changes using existing functionality (following Timeline pattern)
     */
    applyServerSideChanges: function() {
        console.log('MapDisplayOptions: ===== STARTING applyServerSideChanges =====');
        console.log('MapDisplayOptions: Applying server-side changes using existing functions');

        var hasServerSideChanges = false;

        // Update occurrence display using existing dropdown
        if (this.state.pendingChanges.occurrenceDisplay) {
            console.log('MapDisplayOptions: BEFORE updating colourBySelect');
            $('#colourBySelect').val(this.state.occurrenceDisplay);
            console.log('MapDisplayOptions: AFTER updating colourBySelect to:', this.state.occurrenceDisplay);
            hasServerSideChanges = true;
        }

        // Update size using existing slider value
        if (this.state.pendingChanges.gridSize) {
            console.log('MapDisplayOptions: BEFORE updating sizeslider-val, current value:', $('#sizeslider-val').html());
            console.log('MapDisplayOptions: About to set sizeslider-val to:', this.state.gridSize);
            $('#sizeslider-val').html(this.state.gridSize);
            console.log('MapDisplayOptions: AFTER updating sizeslider-val to:', $('#sizeslider-val').html());
            hasServerSideChanges = true;
        }

        // Update opacity using existing slider value
        if (this.state.pendingChanges.opacity !== undefined) {
            console.log('MapDisplayOptions: BEFORE updating opacityslider-val, current value:', $('#opacityslider-val').html());
            console.log('MapDisplayOptions: About to set opacityslider-val to:', this.state.opacity);
            $('#opacityslider-val').html(this.state.opacity);
            console.log('MapDisplayOptions: AFTER updating opacityslider-val to:', $('#opacityslider-val').html());
            hasServerSideChanges = true;
        }

        // Update outline using existing checkbox
        if (this.state.pendingChanges.outline !== undefined) {
            console.log('MapDisplayOptions: BEFORE updating outlineDots');
            $('#outlineDots').prop('checked', this.state.outline);
            console.log('MapDisplayOptions: AFTER updating outlineDots to:', this.state.outline);
            hasServerSideChanges = true;
        }

        // Apply server-side changes using existing function
        if (hasServerSideChanges) {
            console.log('MapDisplayOptions: ===== CALLING changeFacetColours() =====');
            console.log('MapDisplayOptions: This should trigger addQueryLayer(true)');
            changeFacetColours(); // This calls addQueryLayer(true) - existing working function!
            console.log('MapDisplayOptions: ===== changeFacetColours() COMPLETED =====');
        }

        console.log('MapDisplayOptions: ===== applyServerSideChanges COMPLETED =====');
    },

    /**
     * Apply client-side changes using existing functionality
     */
    applyClientSideChanges: function() {
        console.log('MapDisplayOptions: Applying client-side changes using existing functions');

        // Apply opacity changes using existing logic - ONLY when Apply is pressed
        if (this.state.pendingChanges.opacity !== undefined) {
            var opacityValue = parseFloat(this.state.opacity).toFixed(1);
            console.log('MapDisplayOptions: Applying opacity change on Apply:', opacityValue);

            // Update the DOM element that the server-side code reads from
            $('#opacityslider-val').html(opacityValue);

            // Opacity will be applied via server-side refresh in applyServerSideChanges
            // DO NOT apply immediately to avoid dual updates
            console.log('MapDisplayOptions: Opacity value updated in DOM for server-side application');
        }

        // Apply basemap changes using existing baseLayers (immediate effect is OK for basemap)
        if (this.state.pendingChanges.basemap) {
            this.switchBasemap(this.state.basemap);
        }

        console.log('MapDisplayOptions: Client-side changes applied');
    },

    // Legacy helper functions removed - we now work directly with pendingChanges object

    // updateControlValues function removed - we now update DOM elements directly in applyServerSideChanges

    /**
     * Switch basemap (client-side immediate effect)
     */
    switchBasemap: function(basemapName) {
        console.log('MapDisplayOptions: Switching basemap to:', basemapName);

        try {
            if (typeof MAP_VAR !== 'undefined' && MAP_VAR.baseLayers && MAP_VAR.map) {
                // Check if the requested basemap exists
                if (!MAP_VAR.baseLayers[basemapName]) {
                    console.warn('MapDisplayOptions: Basemap not found:', basemapName);
                    this.showMessage('warning', 'Basemap "' + basemapName + '" not available');
                    return;
                }

                // Remove all current base layers
                for (var layerName in MAP_VAR.baseLayers) {
                    if (MAP_VAR.baseLayers.hasOwnProperty(layerName)) {
                        var layer = MAP_VAR.baseLayers[layerName];
                        if (MAP_VAR.map.hasLayer(layer)) {
                            MAP_VAR.map.removeLayer(layer);
                            console.log('MapDisplayOptions: Removed basemap layer:', layerName);
                        }
                    }
                }

                // Add the new basemap layer
                var newBaseLayer = MAP_VAR.baseLayers[basemapName];
                MAP_VAR.map.addLayer(newBaseLayer);

                // Update the layer control if it exists
                if (MAP_VAR.layerControl) {
                    // The layer control should automatically update, but we can trigger an event
                    MAP_VAR.map.fire('baselayerchange', {name: basemapName, layer: newBaseLayer});
                }

                // Store current basemap
                MAP_VAR.currentBasemap = basemapName;

                console.log('MapDisplayOptions: Successfully switched to basemap:', basemapName);

            } else {
                console.warn('MapDisplayOptions: MAP_VAR or required properties not available');
                this.showMessage('error', 'Map layers not available. Please refresh the page.');
            }
        } catch (error) {
            console.error('MapDisplayOptions: Error switching basemap:', error);

            // Handle specific Google Maps API error
            if (error.message && error.message.includes('Google')) {
                this.showMessage('warning', 'Google Maps basemap unavailable in development mode. Try "Minimal" basemap instead.');
            } else {
                this.showMessage('error', 'Failed to switch basemap: ' + error.message);
            }
        }
    },

    /**
     * Update layer opacity (client-side immediate effect)
     */
    updateLayerOpacity: function(opacity) {
        console.log('MapDisplayOptions: Updating layer opacity to:', opacity);

        try {
            // Update the opacity slider value
            $('#opacityslider-val').html(opacity);

            // Update actual map layers if they exist
            if (typeof MAP_VAR !== 'undefined' && MAP_VAR.currentLayers) {
                MAP_VAR.currentLayers.forEach(function(layer) {
                    if (layer.setOpacity) {
                        layer.setOpacity(opacity);
                    }
                });
                console.log('MapDisplayOptions: Layer opacity updated successfully');
            } else {
                console.warn('MapDisplayOptions: MAP_VAR.currentLayers not available');
            }
        } catch (error) {
            console.error('MapDisplayOptions: Error updating opacity:', error);
        }
    },

    /**
     * Show a message to the user (following Timeline pattern)
     */
    showMessage: function(type, message) {
        console.log('MapDisplayOptions: Message (' + type + '):', message);

        // Create or update message area in the dialog (like Timeline)
        var $messageArea = $('#mapDisplayMessages');
        if ($messageArea.length === 0) {
            // Create message area if it doesn't exist
            var messageHtml = '<div id="mapDisplayMessages" style="margin-bottom: 15px;"></div>';
            $('#mapDisplayContent .panel-body').prepend(messageHtml);
            $messageArea = $('#mapDisplayMessages');
        }

        // Create message based on type
        var alertClass = '';
        var icon = '';

        switch(type) {
            case 'success':
                alertClass = 'alert-success';
                icon = 'fa-check';
                break;
            case 'error':
                alertClass = 'alert-danger';
                icon = 'fa-exclamation-circle';
                break;
            case 'warning':
                alertClass = 'alert-warning';
                icon = 'fa-exclamation-triangle';
                break;
            default:
                alertClass = 'alert-info';
                icon = 'fa-info-circle';
        }

        var messageHtml = '<div class="alert ' + alertClass + ' alert-dismissible" style="margin-bottom: 10px; padding: 8px 12px; font-size: 12px;">' +
                         '<i class="fa ' + icon + '"></i> ' + message +
                         '<button type="button" class="close" data-dismiss="alert" aria-label="Close" style="padding: 0; margin-left: 10px;">' +
                         '<span aria-hidden="true">&times;</span>' +
                         '</button>' +
                         '</div>';

        $messageArea.html(messageHtml);

        // Auto-hide success messages after 4 seconds (like Timeline)
        if (type === 'success') {
            setTimeout(function() {
                $messageArea.fadeOut(300, function() {
                    $(this).html('').show();
                });
            }, 4000);
        }
    },

    /**
     * Bind all event handlers
     */
    bindEvents: function() {
        var self = this;

        // Toggle dialog
        $('#mapDisplayToggle').on('click', function(e) {
            e.preventDefault();
            self.togglePanel();
        });

        // Close dialog
        $('#mapDisplayCloseBtn').on('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            self.closePanel();
        });

        // Basemap selection
        $('.basemap-btn').on('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            var basemap = $(this).data('basemap');
            self.selectBasemap(basemap);
        });

        // Occurrence display change
        $('#mapDisplayOccurrenceType').on('change', function(e) {
            e.stopPropagation();
            self.changeOccurrenceDisplay($(this).val());
        });

        // Outline checkbox
        $('#mapDisplayOutline').on('change', function(e) {
            e.stopPropagation();
            self.toggleOutline($(this).is(':checked'));
        });

        // Grid size increment/decrement buttons
        $('#gridSizeIncrementBtn').on('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            self.incrementGridSize();
        });

        $('#gridSizeDecrementBtn').on('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            self.decrementGridSize();
        });

        // Opacity increment/decrement buttons
        $('#opacityIncrementBtn').on('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            self.incrementOpacity();
        });

        $('#opacityDecrementBtn').on('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            self.decrementOpacity();
        });

        // Apply button
        $('#applyMapDisplayBtn').on('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            self.applyChanges();
        });

        // Prevent all clicks within the dialog from propagating to the map
        $('#mapDisplayContent').on('click', function(e) {
            e.stopPropagation();
        });

        // Additional comprehensive event blocking for the entire dialog container
        $('#mapDisplayControl').on('click mousedown mouseup dblclick', function(e) {
            // Stop ALL events from propagating to prevent map interactions
            e.stopPropagation();
            e.stopImmediatePropagation();
            console.log('MapDisplayOptions: Blocked event:', e.type, 'on', e.target);
        });

        console.log('MapDisplayOptions: Event handlers bound');
    }
};

// Initialize when document is ready (following timeline pattern)
$(document).ready(function() {
    // Initialize map display options
    if (typeof MapDisplayOptions !== 'undefined') {
        MapDisplayOptions.initialize();
    }

    console.log('MapDisplayOptions: Document ready initialization complete');
});
