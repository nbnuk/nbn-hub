/**
 * Simple Timeline JavaScript - Phase 2 Implementation with Month-Based Support
 * Handles timeline UI interactions and backend integration
 * Now supports both year-based and month-based (seasonal) timelines
 */

// Timeline Simple namespace
var TimelineSimple = {
    // Configuration
    config: {
        debounceDelay: 300,
        successMessageTimeout: 4000,
        ajaxTimeout: 10000,
        monthNames: [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        ]
    },

    // State management
    state: {
        isInitialized: false,
        bounds: null,
        originalAdditionalFqs: null,
        timelineType: 'month',  // Default to month-based as requested
        currentMonth: 1,        // Current month for month-based timeline
        currentYear: null,      // Current year for year-based timeline
        yearStepSize: 1,        // Step by 1 year
        playbackStartYear: null, // Start year for current playback session
        playbackEndYear: null,  // End year for current playback session
        playbackSpeed: 5000,    // 5 seconds per month for better map loading
        isPlaying: false,
        playbackTimer: null,
        monthStepSize: 1,       // Step by 1 month
        repeat: true,           // Loop through months/years
        selectedMonths: [1,2,3,4,5,6,7,8,9,10,11,12], // All months selected by default
        currentMonthIndex: 0    // Index in selectedMonths array
    },

    /**
     * Initialize the simple timeline functionality
     */
    init: function() {
        if (this.state.isInitialized) {
            console.log('Timeline Simple already initialized');
            return;
        }

        console.log('Simple Timeline component loaded with month-based support');
        this.loadConfiguration();
        this.bindEvents();
        this.initializeTimeline();
        this.state.isInitialized = true;
    },

    /**
     * Load timeline configuration from backend
     */
    loadConfiguration: function() {
        var self = this;
        $.ajax({
            url: "${createLink(controller:'occurrence', action:'timelineConfig')}",
            method: 'GET',
            timeout: this.config.ajaxTimeout,
            success: function(config) {
                console.log('Timeline configuration loaded:', config);

                // Set default timeline type from configuration
                if (config.defaults && config.defaults.timelineType) {
                    self.state.timelineType = config.defaults.timelineType;
                }

                // Update UI based on configuration
                self.updateTimelineTypeUI();
            },
            error: function(xhr, status, error) {
                console.warn('Failed to load timeline configuration, using defaults:', error);
                // Use defaults
            }
        });
    },

    /**
     * Update UI based on timeline type
     */
    updateTimelineTypeUI: function() {
        var $container = $('#timelineSimpleContent');

        if (this.state.timelineType === 'month') {
            // Show month-based UI
            $container.find('.timeline-type-year').hide();
            $container.find('.timeline-type-month').show();
            $container.find('.timeline-subtitle').text('Explore seasonal patterns across all years');
        } else {
            // Show year-based UI
            $container.find('.timeline-type-year').show();
            $container.find('.timeline-type-month').hide();
            // $container.find('.timeline-subtitle').text('Enter a time period to view changes on the map');
        }
    },

    /**
     * Switch timeline type between year and month
     */
    switchTimelineType: function(newType) {
        if (this.state.timelineType !== newType) {
            this.state.timelineType = newType;
            this.stopPlayback();  // Stop any current playback
            this.updateTimelineTypeUI();
            this.clearCurrentFilters();
            console.log('Switched timeline type to:', newType);
        }
    },

    /**
     * Get currently selected months from checkboxes
     */
    getSelectedMonths: function() {
        var selectedMonths = [];
        $('.month-checkbox:checked').each(function() {
            selectedMonths.push(parseInt($(this).val()));
        });
        return selectedMonths.sort(function(a, b) { return a - b; });
    },

    /**
     * Update the selected months state
     */
    updateSelectedMonths: function() {
        this.state.selectedMonths = this.getSelectedMonths();
        this.state.currentMonthIndex = 0;

        if (this.state.selectedMonths.length === 0) {
            this.showMessage('warning', 'Please select at least one month');
            return false;
        }

        console.log('Selected months updated:', this.state.selectedMonths);
        return true;
    },

    /**
     * Set month selection (for preset buttons)
     */
    setSelectedMonths: function(months) {
        // Uncheck all first
        $('.month-checkbox').prop('checked', false);

        // Check the specified months
        months.forEach(function(month) {
            $('.month-checkbox[value="' + month + '"]').prop('checked', true);
        });

        this.updateSelectedMonths();
    },

    /**
     * Month-based timeline playback implementation
     * Steps through selected months showing seasonal patterns
     */
    startMonthPlayback: function() {
        if (this.state.isPlaying) {
            // Pause functionality
            this.state.isPlaying = false;
            if (this.state.playbackTimer) {
                clearTimeout(this.state.playbackTimer);
                this.state.playbackTimer = null;
            }
            this.updatePlaybackUI();
            this.showMessage('info', 'Timeline playback paused');
            return;
        }

        // Update selected months from UI
        if (!this.updateSelectedMonths()) {
            return; // Exit if no months selected
        }

        this.state.isPlaying = true;
        this.state.currentMonthIndex = 0; // Start with first selected month
        this.state.currentMonth = this.state.selectedMonths[0];
        this.updatePlaybackUI();

        // Force enable stop button as backup
        setTimeout(function() {
            $('#timelineMonthStopBtn').prop('disabled', false).removeClass('disabled');
            console.log('Force-enabled month stop button as backup');
        }, 100);

        var self = this;
        function nextMonthStep() {
            if (!self.state.isPlaying) return;

            // Get current month from selected months array
            var currentMonth = self.state.selectedMonths[self.state.currentMonthIndex];
            self.state.currentMonth = currentMonth;

            // Apply filter for current month (shows ALL data for this month across ALL years)
            self.applyMonthFilter(currentMonth);

            // Update display elements
            self.updateCurrentMonthDisplay();
            self.updatePlaybackUI(); // Ensure buttons stay in correct state during playback
            var monthName = self.config.monthNames[currentMonth - 1];
            var monthInfo = 'Showing ' + monthName + ' data (' + (self.state.currentMonthIndex + 1) + ' of ' + self.state.selectedMonths.length + ' selected months)';
            self.showMessage('info', monthInfo);

            // Move to next selected month
            self.state.currentMonthIndex++;

            // Check if we've reached the end of selected months
            if (self.state.currentMonthIndex >= self.state.selectedMonths.length) {
                if (self.state.repeat) {
                    self.state.currentMonthIndex = 0;  // Loop back to first selected month
                } else {
                    self.stopPlayback();
                    return;
                }
            }

            // Schedule next step
            self.state.playbackTimer = setTimeout(nextMonthStep, self.state.playbackSpeed);
        }

        nextMonthStep();
    },

    /**
     * Year-based timeline playback implementation
     * Steps through years showing temporal changes
     */
    startYearPlayback: function() {
        if (this.state.isPlaying) {
            // Pause functionality
            this.state.isPlaying = false;
            if (this.state.playbackTimer) {
                clearTimeout(this.state.playbackTimer);
                this.state.playbackTimer = null;
            }
            this.updatePlaybackUI();
            this.showMessage('info', 'Timeline playback paused');
            return;
        }

        // Check if we have bounds
        if (!this.state.bounds || !this.state.bounds.minYear || !this.state.bounds.maxYear) {
            console.error('Year playback bounds check failed:', {
                hasBounds: !!this.state.bounds,
                bounds: this.state.bounds,
                hasMinYear: this.state.bounds ? !!this.state.bounds.minYear : false,
                hasMaxYear: this.state.bounds ? !!this.state.bounds.maxYear : false
            });

            // Try to fetch bounds if they're missing
            var self = this;
            this.fetchTemporalBounds().then(function(bounds) {
                console.log('Fetched bounds for year playback:', bounds);
                self.state.bounds = bounds;
                if (bounds && bounds.minYear && bounds.maxYear) {
                    // Retry year playback now that we have bounds
                    self.startYearPlayback();
                } else {
                    self.showMessage('error', 'No temporal data available for year playback');
                }
            }).catch(function(error) {
                console.error('Failed to fetch temporal bounds:', error);
                self.showMessage('error', 'Unable to load temporal bounds for year playback');
            });
            return;
        }

        this.state.isPlaying = true;

        // Check if user has specified a custom year range in the form
        var startYear = parseInt($('#simpleStartYear').val());
        var endYear = parseInt($('#simpleEndYear').val());

        // Use form values if provided, otherwise use full bounds
        var playbackStartYear = startYear || this.state.bounds.minYear;
        var playbackEndYear = endYear || this.state.bounds.maxYear;

        // Validate the range
        if (startYear && endYear && startYear > endYear) {
            this.showMessage('error', 'Start year must be before end year');
            this.state.isPlaying = false;
            return;
        }

        // Store the playback range for this session
        this.state.playbackStartYear = playbackStartYear;
        this.state.playbackEndYear = playbackEndYear;

        // Initialize current year if not set or outside the playback range
        if (!this.state.currentYear || this.state.currentYear < playbackStartYear || this.state.currentYear > playbackEndYear) {
            this.state.currentYear = playbackStartYear;
        }

        console.log('Year playback range:', playbackStartYear, 'to', playbackEndYear);

        this.updatePlaybackUI();

        // Force enable stop button as backup
        setTimeout(function() {
            $('#timelineYearStopBtn').prop('disabled', false).removeClass('disabled');
            console.log('Force-enabled year stop button as backup');
        }, 100);

        var self = this;
        function nextYearStep() {
            if (!self.state.isPlaying) return;

            // Apply filter for current year
            self.applyYearFilter(self.state.currentYear, self.state.currentYear);

            // Update display elements
            self.updateCurrentYearDisplay();
            self.updatePlaybackUI(); // Ensure buttons stay in correct state during playback
            var yearInfo = 'Showing ' + self.state.currentYear + ' data (' +
                          (self.state.currentYear - self.state.playbackStartYear + 1) + ' of ' +
                          (self.state.playbackEndYear - self.state.playbackStartYear + 1) + ' years)';
            self.showMessage('info', yearInfo);

            // Move to next year
            self.state.currentYear += self.state.yearStepSize;

            // Check if we've reached the end of the playback range
            if (self.state.currentYear > self.state.playbackEndYear) {
                if (self.state.repeat) {
                    self.state.currentYear = self.state.playbackStartYear;  // Loop back to first year in range
                } else {
                    self.stopPlayback();
                    return;
                }
            }

            // Schedule next step
            self.state.playbackTimer = setTimeout(nextYearStep, self.state.playbackSpeed);
        }

        nextYearStep();
    },

    /**
     * Apply month-based filter for seasonal analysis
     * This shows ALL data for the specified month across ALL years
     */
    applyMonthFilter: function(month) {
        if (month < 1 || month > 12) {
            console.error('Invalid month:', month);
            return;
        }

        // Create month filter: month:[1 TO 1] for January, etc.
        var monthFilter = 'month:[' + month + ' TO ' + month + ']';

        // Apply the filter
        if (typeof MAP_VAR !== 'undefined') {
            // Store original filters if not already stored
            if (TIMELINE_VAR.originalAdditionalFqs === null || TIMELINE_VAR.originalAdditionalFqs === '') {
                TIMELINE_VAR.originalAdditionalFqs = MAP_VAR.additionalFqs || '';
            }

            // Apply month filter
            var baseFilters = TIMELINE_VAR.originalAdditionalFqs;
            if (baseFilters && baseFilters.trim() !== '') {
                MAP_VAR.additionalFqs = baseFilters + '&fq=' + encodeURIComponent(monthFilter);
            } else {
                MAP_VAR.additionalFqs = '&fq=' + encodeURIComponent(monthFilter);
            }

            // Refresh the map with a small delay to ensure proper loading
            if (typeof addQueryLayer === 'function') {
                addQueryLayer(true);
                // Give the map layer time to load before showing success
                setTimeout(function() {
                    console.log('Applied month filter:', monthFilter);
                }, 500);
            } else {
                console.log('Applied month filter:', monthFilter);
            }
        }
    },

    /**
     * Stop timeline playback
     */
    stopPlayback: function() {
        console.log('stopPlayback called, current state:', {
            isPlaying: this.state.isPlaying,
            timelineType: this.state.timelineType,
            hasTimer: !!this.state.playbackTimer
        });

        this.state.isPlaying = false;
        if (this.state.playbackTimer) {
            clearTimeout(this.state.playbackTimer);
            this.state.playbackTimer = null;
            console.log('Playback timer cleared');
        }

        if (this.state.timelineType === 'month') {
            this.state.currentMonthIndex = 0; // Reset to first selected month
            if (this.state.selectedMonths.length > 0) {
                this.state.currentMonth = this.state.selectedMonths[0];
            } else {
                this.state.currentMonth = 1; // Fallback to January
            }
            console.log('Month timeline stopped, reset to month:', this.state.currentMonth);
        } else {
            // Reset to first year for year-based timeline
            if (this.state.playbackStartYear) {
                this.state.currentYear = this.state.playbackStartYear;
            } else if (this.state.bounds && this.state.bounds.minYear) {
                this.state.currentYear = this.state.bounds.minYear;
            }
            console.log('Year timeline stopped, reset to year:', this.state.currentYear);
        }

        this.updatePlaybackUI();
        this.clearCurrentFilters();
        this.showMessage('success', 'Timeline playback stopped');
    },

    /**
     * Clear current temporal filters and restore original state
     */
    clearCurrentFilters: function() {
        if (typeof MAP_VAR !== 'undefined' && TIMELINE_VAR.originalAdditionalFqs !== null) {
            MAP_VAR.additionalFqs = TIMELINE_VAR.originalAdditionalFqs;
            if (typeof addQueryLayer === 'function') {
                addQueryLayer(true);
            }
        }
    },

    /**
     * Update current month display during playback
     */
    updateCurrentMonthDisplay: function() {
        var $currentDisplay = $('#currentMonthDisplay');

        if (this.state.isPlaying && this.state.currentMonth && this.state.currentMonth >= 1 && this.state.currentMonth <= 12) {
            var monthName = this.config.monthNames[this.state.currentMonth - 1];
            $currentDisplay.html('<i class="fa fa-calendar"></i> Currently showing: <strong>' + monthName + '</strong> data across all years');
        } else if (this.state.currentMonth && this.state.currentMonth >= 1 && this.state.currentMonth <= 12) {
            var monthName = this.config.monthNames[this.state.currentMonth - 1];
            $currentDisplay.html('<i class="fa fa-pause"></i> Paused on: <strong>' + monthName + '</strong>');
        } else {
            $currentDisplay.html('<i class="fa fa-info-circle"></i> Ready to explore seasonal patterns');
        }
    },

    /**
     * Update current year display during playback
     */
    updateCurrentYearDisplay: function() {
        var $currentDisplay = $('#currentYearDisplay');

        if (this.state.isPlaying && this.state.currentYear) {
            $currentDisplay.html('<i class="fa fa-calendar"></i> Currently showing: <strong>' + this.state.currentYear + '</strong> data');
        } else if (this.state.currentYear) {
            $currentDisplay.html('<i class="fa fa-pause"></i> Paused on: <strong>' + this.state.currentYear + '</strong>');
        } else {
            $currentDisplay.html('<i class="fa fa-info-circle"></i> Ready to explore temporal changes');
        }
    },

    /**
     * Update playback UI controls
     */
    updatePlaybackUI: function() {
        console.log('updatePlaybackUI called, state:', {
            isPlaying: this.state.isPlaying,
            timelineType: this.state.timelineType,
            currentMonth: this.state.currentMonth,
            currentYear: this.state.currentYear
        });

        if (this.state.timelineType === 'month') {
            var $playBtn = $('#timelineMonthPlayBtn');
            var $stopBtn = $('#timelineMonthStopBtn');

            // Check if buttons exist
            if ($playBtn.length === 0 || $stopBtn.length === 0) {
                console.warn('Month timeline buttons not found in DOM');
                return;
            }

            if (this.state.isPlaying || this.state.playbackTimer) {
                $playBtn.html('<i class="fa fa-pause"></i> Pause').addClass('btn-warning');
                $stopBtn.prop('disabled', false).removeClass('disabled');
                console.log('Month timeline: PLAYING - Stop button ENABLED, isPlaying:', this.state.isPlaying, 'hasTimer:', !!this.state.playbackTimer);
            } else {
                if (this.state.currentMonth && this.state.currentMonth > 1 && this.state.currentMonth <= 12) {
                    $playBtn.html('<i class="fa fa-play"></i> Resume').removeClass('btn-warning');
                } else {
                    $playBtn.html('<i class="fa fa-play"></i> Play Months').removeClass('btn-warning');
                }
                $stopBtn.prop('disabled', true).addClass('disabled');
                console.log('Month timeline: STOPPED - Stop button DISABLED, isPlaying:', this.state.isPlaying, 'hasTimer:', !!this.state.playbackTimer);
            }
            // Update the current month display
            this.updateCurrentMonthDisplay();
        } else {
            var $playBtn = $('#timelineYearPlayBtn');
            var $stopBtn = $('#timelineYearStopBtn');

            // Check if buttons exist
            if ($playBtn.length === 0 || $stopBtn.length === 0) {
                console.warn('Year timeline buttons not found in DOM');
                return;
            }

            if (this.state.isPlaying || this.state.playbackTimer) {
                $playBtn.html('<i class="fa fa-pause"></i> Pause').addClass('btn-warning');
                $stopBtn.prop('disabled', false).removeClass('disabled');
                console.log('Year timeline: PLAYING - Stop button ENABLED, isPlaying:', this.state.isPlaying, 'hasTimer:', !!this.state.playbackTimer);
            } else {
                if (this.state.currentYear) {
                    $playBtn.html('<i class="fa fa-play"></i> Resume').removeClass('btn-warning');
                } else {
                    $playBtn.html('<i class="fa fa-play"></i> Play Years').removeClass('btn-warning');
                }
                $stopBtn.prop('disabled', true).addClass('disabled');
                console.log('Year timeline: STOPPED - Stop button DISABLED, isPlaying:', this.state.isPlaying, 'hasTimer:', !!this.state.playbackTimer);
            }
            // Update the current year display
            this.updateCurrentYearDisplay();
        }
    },

    /**
     * Handle legacy year-based timeline for backward compatibility
     */
    applyYearFilter: function(startYear, endYear) {
        if (!startYear || !endYear) {
            this.showMessage('error', 'Please provide valid start and end years');
            return;
        }

        var yearFilter = 'year:[' + startYear + ' TO ' + endYear + ']';

        if (typeof MAP_VAR !== 'undefined') {
            if (TIMELINE_VAR.originalAdditionalFqs === null || TIMELINE_VAR.originalAdditionalFqs === '') {
                TIMELINE_VAR.originalAdditionalFqs = MAP_VAR.additionalFqs || '';
            }

            var baseFilters = TIMELINE_VAR.originalAdditionalFqs;
            if (baseFilters && baseFilters.trim() !== '') {
                MAP_VAR.additionalFqs = baseFilters + '&fq=' + encodeURIComponent(yearFilter);
            } else {
                MAP_VAR.additionalFqs = '&fq=' + encodeURIComponent(yearFilter);
            }

            if (typeof addQueryLayer === 'function') {
                addQueryLayer(true);
            }

            this.showMessage('success', 'Showing records from ' + startYear + ' to ' + endYear);
            console.log('Applied year filter:', yearFilter);
        }
    },

    /**
     * Bind all event handlers
     */
    bindEvents: function() {
        var self = this;

        // Toggle timeline panel
        $('#timelineSimpleToggle').on('click', function(e) {
            e.preventDefault();
            self.togglePanel();
        });

        // Close timeline panel - delegated event handler
        $(document).on('click', '#timelineCloseBtn', function(e) {
            e.preventDefault();
            e.stopPropagation();
            console.log('Close button clicked - event triggered');
            self.closePanel();
        });

        // Direct close button handler (fallback)
        $('#timelineCloseBtn').on('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            console.log('Direct close button clicked');
            self.closePanel();
        });

        // Play timeline functionality
        $('#timelinePlayBtn').on('click', function(e) {
            e.preventDefault();
            self.playTimeline();
        });

        // View on map button
        $('#viewOnMapBtn').on('click', function(e) {
            e.preventDefault();
            self.viewOnMap();
        });

        // Input validation
        $('.timeline-figma-input').on('blur', function() {
            self.validateInput($(this));
        });
    },

    /**
     * Toggle the timeline panel visibility
     */
    togglePanel: function() {
        var content = $('#timelineSimpleContent');
        var container = $('#timelineSimpleControl');
        var toggle = $('#timelineSimpleToggle');
        var isVisible = content.hasClass('show');

        if (isVisible) {
            content.removeClass('show').slideUp(200);
            container.removeClass('show');
            toggle.removeClass('active');
        } else {
            content.addClass('show').slideDown(200, function() {
                TimelineSimple.attachCloseButtonHandler();
            });
            container.addClass('show');
            toggle.addClass('active');
        }
    },

    /**
     * Close the timeline panel
     */
    closePanel: function() {
        var content = $('#timelineSimpleContent');
        var container = $('#timelineSimpleControl');
        var toggle = $('#timelineSimpleToggle');

        this.stopPlayback();  // Stop any playing timeline
        content.removeClass('show').slideUp(200);
        container.removeClass('show');
        toggle.removeClass('active');
        console.log('Timeline closed');
    },

    /**
     * Play timeline functionality
     */
    playTimeline: function() {
        var startYear = $('#simpleStartYear').val();
        var endYear = $('#simpleEndYear').val();

        if (!startYear) {
            this.showMessage('error', 'Please enter a start year to play timeline');
            return;
        }

        // For now, just apply the filter like the view button
        // Future enhancement could add actual timeline animation
        var actualEndYear = endYear || new Date().getFullYear();
        this.applyTemporalFilter(startYear, actualEndYear);

        this.showMessage('success', 'Timeline played from ' + startYear + ' to ' + actualEndYear);
    },

    /**
     * View on map button handler
     */
    viewOnMap: function() {
        console.log('View on map clicked - Phase 2 functional implementation');

        var startYear = $('#simpleStartYear').val();
        var endYear = $('#simpleEndYear').val();

        // Validation
        if (!startYear && !endYear) {
            this.showMessage('error', 'Please enter at least one year to filter by');
            return;
        }

        if (startYear && endYear && parseInt(startYear) > parseInt(endYear)) {
            this.showMessage('error', 'Start year must be before end year');
            return;
        }

        // Show loading
        this.showMessage('loading', 'Applying timeline filter...');

        // Apply temporal filter to map
        this.applyTemporalFilter(startYear, endYear);
    },

    /**
     * Validate input field
     */
    validateInput: function($input) {
        var value = parseInt($input.val());
        var min = parseInt($input.attr('min'));
        var max = parseInt($input.attr('max'));

        if (value && (value < min || value > max)) {
            $input.closest('.form-group').addClass('has-error');
            this.showMessage('error', 'Year must be between ' + min + ' and ' + max);
        } else {
            $input.closest('.form-group').removeClass('has-error');
            this.hideMessages();
        }
    },

    /**
     * Attach close button handler (fallback method)
     */
    attachCloseButtonHandler: function() {
        var self = this;
        console.log('Attaching close button handler');

        // Remove any existing handlers to prevent duplicates
        $('#timelineCloseBtn').off('click.closeHandler');

        // Attach new handler with namespace
        $('#timelineCloseBtn').on('click.closeHandler', function(e) {
            e.preventDefault();
            e.stopPropagation();
            console.log('Close button clicked via attached handler');
            self.closePanel();
        });
    },

    /**
     * Show status message
     */
    showMessage: function(type, message) {
        var self = this;
        this.hideMessages();

        if (type === 'loading') {
            $('#timelineSimpleLoading').show().find('i').next().text(message);
        } else {
            var messageEl = $('#timelineSimple' + type.charAt(0).toUpperCase() + type.slice(1));
            messageEl.show().find('span').text(message);

            if (type === 'success') {
                setTimeout(function() {
                    self.hideMessages();
                }, this.config.successMessageTimeout);
            }
        }
    },

    /**
     * Hide all status messages
     */
    hideMessages: function() {
        $('.timeline-status-msg').hide();
    },

    /**
     * Initialize simple timeline with bounds from backend
     */
    initializeTimeline: function() {
        var self = this;

        // Fetch temporal bounds to set proper min/max values
        this.fetchTemporalBounds().then(function(bounds) {
            if (bounds && bounds.hasTemporalData) {
                console.log('Simple timeline initialized with bounds:', bounds);
                self.state.bounds = bounds;

                // Update input constraints
                $('#simpleStartYear').attr('min', bounds.min).attr('max', bounds.max);
                $('#simpleEndYear').attr('min', bounds.min).attr('max', bounds.max);

                // Set default values
                $('#simpleStartYear').attr('placeholder', bounds.min);
                $('#simpleEndYear').attr('placeholder', bounds.max);

                console.log('Simple timeline bounds configured');
            } else {
                console.log('No temporal data available for simple timeline');
                console.log('Simple timeline ready without temporal data');
            }
        }).catch(function(error) {
            console.error('Error initializing simple timeline:', error);
            console.log('Simple timeline ready despite error');
        });

        // Initialize UI state
        this.initializeUIState();
    },

    /**
     * Initialize UI state
     */
    initializeUIState: function() {
        // Make sure the timeline starts in the correct state
        $('#timelineSimpleToggle').removeClass('active');
        $('#timelineSimpleContent').removeClass('show').hide();

        // Debug: Check if close button exists
        setTimeout(function() {
            var closeBtn = $('#timelineCloseBtn');
            console.log('Close button found:', closeBtn.length > 0);

            if (closeBtn.length > 0) {
                console.log('Close button is visible:', closeBtn.is(':visible'));
            }
        }, 1000);

        console.log('Simple timeline ready for map integration');
    },

    /**
     * Fetch temporal bounds from backend
     */
    fetchTemporalBounds: function() {
        // Note: This URL construction assumes MAP_VAR.query is available globally
        // This maintains compatibility with the existing GSP structure
        var url = window.timelineSimpleConfig.timelineBoundsUrl + (window.MAP_VAR ? window.MAP_VAR.query : '');
        console.log('Simple timeline fetching bounds from:', url);

        return $.ajax({
            url: url,
            type: 'GET',
            dataType: 'json',
            timeout: this.config.ajaxTimeout
        }).then(function(data) {
            console.log('Simple timeline bounds response:', data);
            if (data.success && data.hasTemporalData) {
                return {
                    min: data.minYear,
                    max: data.maxYear,
                    minYear: data.minYear,  // Add for year playback compatibility
                    maxYear: data.maxYear,  // Add for year playback compatibility
                    totalYears: data.totalYears,
                    hasTemporalData: data.hasTemporalData
                };
            } else {
                return {
                    min: 1800,
                    max: 2024,
                    minYear: 1800,         // Add for year playback compatibility
                    maxYear: 2024,         // Add for year playback compatibility
                    totalYears: 0,
                    hasTemporalData: false
                };
            }
        });
    },

    /**
     * Apply temporal filter to map - Phase 2 Implementation
     */
    applyTemporalFilter: function(startYear, endYear) {
        var self = this;

        try {
            // Default to bounds if not specified
            var actualStartYear = startYear || 1800;
            var actualEndYear = endYear || 2024;

            console.log('Applying simple temporal filter:', actualStartYear, '-', actualEndYear);

            // Check if we're showing all data (no filter)
            var isFullRange = (!startYear && !endYear);

            if (isFullRange) {
                // Reset to original query without temporal filter
                if (window.MAP_VAR && window.TIMELINE_VAR) {
                    window.MAP_VAR.additionalFqs = window.TIMELINE_VAR.originalAdditionalFqs || '';
                }
                console.log('Simple timeline: Removed temporal filter');
                this.showMessage('success', 'Showing all records');
            } else {
                // Apply temporal filter using the same mechanism as advanced timeline
                var temporalFilter = 'year:[' + actualStartYear + ' TO ' + actualEndYear + ']';

                if (window.MAP_VAR && window.TIMELINE_VAR) {
                    // Ensure we have the original fqs stored
                    if (typeof window.TIMELINE_VAR.originalAdditionalFqs === 'undefined') {
                        window.TIMELINE_VAR.originalAdditionalFqs = window.MAP_VAR.additionalFqs || '';
                    }

                    // Apply the filter
                    var baseFilters = window.TIMELINE_VAR.originalAdditionalFqs || '';
                    if (baseFilters && baseFilters.trim() !== '') {
                        window.MAP_VAR.additionalFqs = baseFilters + '&fq=' + encodeURIComponent(temporalFilter);
                    } else {
                        window.MAP_VAR.additionalFqs = '&fq=' + encodeURIComponent(temporalFilter);
                    }

                    console.log('Simple timeline: Applied temporal filter:', temporalFilter);
                    console.log('Simple timeline: Updated additionalFqs:', window.MAP_VAR.additionalFqs);
                }

                // Fetch count for this period to show in success message
                this.fetchTemporalCount(actualStartYear, actualEndYear).then(function(result) {
                    var countText = result.count ? result.count.toLocaleString() + ' records' : 'records';
                    var periodText = startYear && endYear ? actualStartYear + '-' + actualEndYear :
                                    startYear ? 'from ' + actualStartYear : 'up to ' + actualEndYear;
                    self.showMessage('success', 'Showing ' + countText + ' for ' + periodText);
                }).catch(function(error) {
                    console.error('Error fetching count:', error);
                    var periodText = startYear && endYear ? actualStartYear + '-' + actualEndYear :
                                    startYear ? 'from ' + actualStartYear : 'up to ' + actualEndYear;
                    self.showMessage('success', 'Timeline filter applied for ' + periodText);
                });
            }

            // Update the map layer with new filters
            if (window.addQueryLayer) {
                window.addQueryLayer(true);
            }

        } catch (error) {
            console.error('Error applying simple temporal filter:', error);
            this.showMessage('error', 'Failed to apply timeline filter');
        }
    },

    /**
     * Fetch occurrence count for specific period
     */
    fetchTemporalCount: function(startYear, endYear) {
        var url = window.timelineSimpleConfig.timelineCountUrl + (window.MAP_VAR ? window.MAP_VAR.query : '') +
                  '&startYear=' + startYear + '&endYear=' + endYear;

        return $.ajax({
            url: url,
            type: 'GET',
            dataType: 'json',
            timeout: this.config.ajaxTimeout
        });
    }
};

// Initialize when document is ready
$(document).ready(function() {
    // Wait for configuration to be available
    if (window.timelineSimpleConfig) {
        TimelineSimple.init();
    } else {
        // Fallback: wait a bit for configuration to load
        setTimeout(function() {
            TimelineSimple.init();
        }, 100);
    }
});

// Export for global access if needed
window.TimelineSimple = TimelineSimple;
