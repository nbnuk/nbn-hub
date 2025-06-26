// Map Button Bar JavaScript - Handle button interactions and mutual exclusivity

var MapButtonBar = {

    state: {
        activeDialog: null // Track which dialog is currently open
    },

    /**
     * Initialize the button bar functionality
     */
    initialize: function() {
        console.log('MapButtonBar: Initializing');
        this.bindEvents();
        console.log('MapButtonBar: Initialized');
    },

    /**
     * Bind all event handlers
     */
    bindEvents: function() {
        var self = this;

        // Timeline button click
        $('#mapButtonBarTimeline').on('click', function(e) {
            e.preventDefault();
            self.handleTimelineClick();
        });

        // Map display button click
        $('#mapButtonBarMapDisplay').on('click', function(e) {
            e.preventDefault();
            self.handleMapDisplayClick();
        });

        // Draw polygon button click
        $('#mapButtonBarDrawPolygon').on('click', function(e) {
            e.preventDefault();
            self.handleDrawPolygonClick();
        });

        // Legend button click
        $('#mapButtonBarLegend').on('click', function(e) {
            e.preventDefault();
            self.handleLegendClick();
        });

        console.log('MapButtonBar: Event handlers bound');
    },

    /**
     * Handle timeline button click with mutual exclusivity
     */
    handleTimelineClick: function() {
        console.log('MapButtonBar: Timeline button clicked');

        // Close any other open dialogs first
        this.closeOtherDialogs('timeline');

        // Toggle timeline dialog
        if (typeof TimelineSimple !== 'undefined') {
            if (this.state.activeDialog === 'timeline') {
                // Timeline is currently open, close it
                TimelineSimple.closePanel();
                this.setActiveDialog(null);
            } else {
                // Timeline is closed, open it
                TimelineSimple.openPanel();
                this.setActiveDialog('timeline');
            }
        } else {
            console.warn('MapButtonBar: TimelineSimple not available');
        }
    },

    /**
     * Handle map display button click with mutual exclusivity
     */
    handleMapDisplayClick: function() {
        console.log('MapButtonBar: Map display button clicked');

        // Close any other open dialogs first
        this.closeOtherDialogs('mapdisplay');

        // Toggle map display dialog
        if (typeof MapDisplayOptions !== 'undefined') {
            if (this.state.activeDialog === 'mapdisplay') {
                // Map display is currently open, close it
                MapDisplayOptions.closePanel();
                this.setActiveDialog(null);
            } else {
                // Map display is closed, open it
                MapDisplayOptions.openPanel();
                this.setActiveDialog('mapdisplay');
            }
        } else {
            console.warn('MapButtonBar: MapDisplayOptions not available');
        }
    },

    /**
     * Handle draw polygon button click
     */
    handleDrawPolygonClick: function() {
        console.log('MapButtonBar: Draw polygon button clicked');

        // Close all dialogs when drawing tools are activated
        this.closeAllDialogs();

        // Activate polygon drawing tool if available
        if (typeof MAP_VAR !== 'undefined' && MAP_VAR.drawControl) {
            // This would trigger the polygon drawing tool
            // The actual implementation depends on the drawing library being used
            console.log('MapButtonBar: Activating polygon drawing tool');
        }
    },

    /**
     * Handle legend button click
     */
    handleLegendClick: function() {
        console.log('MapButtonBar: Legend button clicked');

        // Close other dialogs
        this.closeOtherDialogs('legend');

        // This would handle legend display logic
        // Implementation depends on how legends are managed
        console.log('MapButtonBar: Legend functionality to be implemented');
    },

    /**
     * Close all dialogs except the specified one
     */
    closeOtherDialogs: function(exceptDialog) {
        if (exceptDialog !== 'timeline' && this.state.activeDialog === 'timeline') {
            if (typeof TimelineSimple !== 'undefined') {
                TimelineSimple.closePanel();
            }
        }

        if (exceptDialog !== 'mapdisplay' && this.state.activeDialog === 'mapdisplay') {
            if (typeof MapDisplayOptions !== 'undefined') {
                MapDisplayOptions.closePanel();
            }
        }

        // Reset active dialog if we're closing it
        if (this.state.activeDialog !== exceptDialog) {
            this.setActiveDialog(null);
        }
    },

    /**
     * Close all dialogs
     */
    closeAllDialogs: function() {
        this.closeOtherDialogs(null);
    },

    /**
     * Set the active dialog and update button states
     */
    setActiveDialog: function(dialogName) {
        this.state.activeDialog = dialogName;
        this.updateButtonStates();
        console.log('MapButtonBar: Active dialog set to:', dialogName);
    },

    /**
     * Update button visual states based on active dialog
     */
    updateButtonStates: function() {
        // Remove active class from all buttons
        $('.map-button-bar-btn').removeClass('active');

        // Add active class to the current active button
        if (this.state.activeDialog === 'timeline') {
            $('#mapButtonBarTimeline').addClass('active');
        } else if (this.state.activeDialog === 'mapdisplay') {
            $('#mapButtonBarMapDisplay').addClass('active');
        } else if (this.state.activeDialog === 'legend') {
            $('#mapButtonBarLegend').addClass('active');
        }
    },

    /**
     * Handle dialog close events from the dialogs themselves
     */
    onDialogClosed: function(dialogName) {
        if (this.state.activeDialog === dialogName) {
            this.setActiveDialog(null);
        }
    }
};

// Initialize when document is ready
$(document).ready(function() {
    // Initialize the button bar after a short delay to ensure other components are loaded
    setTimeout(function() {
        MapButtonBar.initialize();
    }, 100);
});

// Listen for dialog close events to update button states
$(document).on('timelineDialogClosed', function() {
    MapButtonBar.onDialogClosed('timeline');
});

$(document).on('mapDisplayDialogClosed', function() {
    MapButtonBar.onDialogClosed('mapdisplay');
});
