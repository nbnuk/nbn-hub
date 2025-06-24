// Map Display Options JavaScript - Phase 1: Basic Dialog Structure
// Following timeline-simple.js pattern for consistency

var MapDisplayOptions = {
    // Configuration
    config: {
        ajaxTimeout: 30000,
        animationDuration: 200
    },

    // Current state - will be populated with actual map values in later phases
    state: {
        basemap: 'Minimal',
        occurrenceDisplay: 'variablegrid',
        gridSize: 4,
        opacity: 0.6, // 60% to match Figma design
        outline: false,
        isOpen: false
    },

    /**
     * Initialize the map display options dialog
     */
    initialize: function() {
        console.log('MapDisplayOptions: Initializing dialog');
        this.bindEvents();
        this.initializeUIState();
        console.log('MapDisplayOptions: Dialog initialized');
    },

    /**
     * Initialize UI state
     */
    initializeUIState: function() {
        // Make sure the dialog starts in the correct state
        $('#mapDisplayToggle').removeClass('active');
        $('#mapDisplayContent').removeClass('show').hide();

        // Set initial values in the UI (placeholder values for Phase 1)
        this.updateUIFromState();

        console.log('MapDisplayOptions: UI state initialized');
    },

    /**
     * Update UI elements from current state
     */
    updateUIFromState: function() {
        // Update basemap buttons
        $('.basemap-btn').removeClass('active');
        $('.basemap-btn[data-basemap="' + this.state.basemap + '"]').addClass('active');

        // Update occurrence display select
        $('#mapDisplayOccurrenceType').val(this.state.occurrenceDisplay);

        // Update grid size value display
        $('#gridSizeValue').text(this.state.gridSize);

        // Update opacity value display (convert to percentage for display)
        var opacityPercent = Math.round(this.state.opacity * 100);
        $('#opacityValue').text(opacityPercent + '%');

        // Update outline checkbox
        $('#mapDisplayOutline').prop('checked', this.state.outline);

        // Show/hide grid options based on occurrence display type
        this.toggleGridOptions(this.state.occurrenceDisplay);

        console.log('MapDisplayOptions: UI updated from state', this.state);
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

        content.addClass('show').slideDown(this.config.animationDuration);
        container.addClass('show');
        toggle.addClass('active');
        this.state.isOpen = true;

        console.log('MapDisplayOptions: Panel opened');
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

        // Update state
        this.state.basemap = basemapType;

        // Update UI
        $('.basemap-btn').removeClass('active');
        $('.basemap-btn[data-basemap="' + basemapType + '"]').addClass('active');

        // In Phase 1, we just log the change
        // In later phases, this will trigger the actual basemap change
        console.log('MapDisplayOptions: Basemap change logged for Phase 2 implementation');
    },

    /**
     * Handle occurrence display type changes
     */
    changeOccurrenceDisplay: function(displayType) {
        console.log('MapDisplayOptions: Occurrence display changed:', displayType);

        // Update state
        this.state.occurrenceDisplay = displayType;

        // Show/hide grid options
        this.toggleGridOptions(displayType);

        // In Phase 1, we just log the change
        console.log('MapDisplayOptions: Occurrence display change logged for Phase 2 implementation');
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
        console.log('MapDisplayOptions: Grid size changed:', newSize);

        // Ensure size stays within bounds
        newSize = Math.max(1, Math.min(10, newSize));

        // Update state
        this.state.gridSize = newSize;

        // Update display
        $('#gridSizeValue').text(newSize);

        console.log('MapDisplayOptions: Grid size updated to:', newSize);
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
        console.log('MapDisplayOptions: Opacity changed:', newOpacity);

        // Ensure opacity stays within bounds (0-100 for percentage display)
        newOpacity = Math.max(0, Math.min(100, newOpacity));

        // Update state (convert to decimal for internal state)
        this.state.opacity = newOpacity / 100;

        // Update display (show as percentage)
        $('#opacityValue').text(newOpacity + '%');

        console.log('MapDisplayOptions: Opacity updated to:', newOpacity + '%');
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

        // Update state
        this.state.outline = enabled;

        // In Phase 1, we just log the change
        console.log('MapDisplayOptions: Outline change logged for Phase 2 implementation');
    },

    /**
     * Apply all changes (placeholder for Phase 2)
     */
    applyChanges: function() {
        console.log('MapDisplayOptions: Apply changes requested');
        console.log('MapDisplayOptions: Current state:', this.state);

        // In Phase 1, we just show a message
        this.showMessage('info', 'Map display options ready for Phase 2 implementation');

        // Close the dialog after applying
        this.closePanel();
    },

    /**
     * Show a message to the user (simple implementation for Phase 1)
     */
    showMessage: function(type, message) {
        console.log('MapDisplayOptions: Message (' + type + '):', message);

        // For Phase 1, just use console and alert
        // In later phases, this could be integrated with existing notification system
        if (type === 'error') {
            alert('Error: ' + message);
        } else {
            console.log('Info: ' + message);
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
            var basemap = $(this).data('basemap');
            self.selectBasemap(basemap);
        });

        // Occurrence display change
        $('#mapDisplayOccurrenceType').on('change', function() {
            self.changeOccurrenceDisplay($(this).val());
        });

        // Outline checkbox
        $('#mapDisplayOutline').on('change', function() {
            self.toggleOutline($(this).is(':checked'));
        });

        // Grid size increment/decrement buttons
        $('#gridSizeIncrementBtn').on('click', function(e) {
            e.preventDefault();
            self.incrementGridSize();
        });

        $('#gridSizeDecrementBtn').on('click', function(e) {
            e.preventDefault();
            self.decrementGridSize();
        });

        // Opacity increment/decrement buttons
        $('#opacityIncrementBtn').on('click', function(e) {
            e.preventDefault();
            self.incrementOpacity();
        });

        $('#opacityDecrementBtn').on('click', function(e) {
            e.preventDefault();
            self.decrementOpacity();
        });

        // Apply button
        $('#applyMapDisplayBtn').on('click', function(e) {
            e.preventDefault();
            self.applyChanges();
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
