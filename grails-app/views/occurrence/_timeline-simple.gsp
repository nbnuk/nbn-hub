<%@ page contentType="text/html;charset=UTF-8" %>
<asset:stylesheet src="timeline-simple.css"/>
<asset:javascript src="timeline-simple.js"/>

<!-- Simple Timeline Toggle Button -->
<div id="timelineSimpleToggleContainer" class="timeline-toggle-container" style="display:none;">
    <button id="timelineSimpleToggle" class="btn timeline-black-toggle-btn" title="Timeline">
        <i class="fa fa-clock-o"></i>
        <span>Timeline</span>
    </button>
</div>

<!-- Simple Timeline Dialog Content  -->
<div id="timelineSimpleControl" class="timeline-simple-container" style="display:none;">
    <div class="timeline-simple-content" id="timelineSimpleContent" style="display:none !important;">
        <div class="panel panel-default timeline-simple-panel">
            <!-- Figma Header with Icons -->
            <div class="panel-heading timeline-figma-header">
                <div class="timeline-header-left">
                    <i class="fa fa-th timeline-menu-icon"></i>
                    <h4 class="panel-title timeline-figma-title">Explore changes over time</h4>
                </div>
                <div class="timeline-header-right">
                    <button class="btn btn-link btn-xs timeline-header-btn" title="Expand">
                        <i class="fa fa-expand"></i>
                    </button>
                    <button class="btn btn-link btn-xs timeline-close-btn" id="timelineCloseBtn" title="Close">
                        <i class="fa fa-times"></i>
                    </button>
                </div>
            </div>

            <div class="panel-body">
                <!-- Timeline Type Selection -->
                <div class="timeline-type-selection" style="margin-bottom: 15px;">
                    <label class="control-label timeline-input-label">Timeline Type</label>
                    <div class="btn-group" data-toggle="buttons">
                        <label class="btn btn-default btn-sm" id="timelineTypeYear">
                            <input type="radio" name="timelineType" value="year" autocomplete="off">
                            <span>By Year</span>
                        </label>
                        <label class="btn btn-default btn-sm active" id="timelineTypeMonth">
                            <input type="radio" name="timelineType" value="month" autocomplete="off" checked>
                            <span>By Month (Seasonal)</span>
                        </label>
                    </div>
                </div>


                <!-- Year-based Timeline UI -->
                <div class="timeline-type-year" style="display: none;">
                    <!-- Figma-style Timeline Controls -->
                    <div class="timeline-figma-container" style="margin-top: 20px;">
                        <!-- Header text -->
                        <p style="color: #666; margin-bottom: 20px; font-size: 14px;">
                            Enter a time period to view changes on the map. Press play to view a timelapse to present day.
                        </p>

                        <!-- Main control row -->
                        <div style="display: flex; align-items: flex-end; gap: 15px; margin-bottom: 20px;">
                            <!-- FROM input -->
                            <div style="flex: 1;">
                                <label style="display: block; margin-bottom: 5px; font-size: 12px; color: #666; text-transform: uppercase; font-weight: 500;">FROM</label>
                                <input type="number" id="simpleStartYear" placeholder="Year"
                                       style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px;"
                                       min="1800" max="2024">
                            </div>

                            <!-- TO input -->
                            <div style="flex: 1;">
                                <label style="display: block; margin-bottom: 5px; font-size: 12px; color: #666; text-transform: uppercase; font-weight: 500;">TO</label>
                                <input type="number" id="simpleEndYear" placeholder="Year"
                                       style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px;"
                                       min="1800" max="2024">
                            </div>

                            <!-- View on map button -->
                            <div>
                                <button id="viewOnMapBtn"
                                        style="background: #000; color: white; border: none; padding: 12px 24px; border-radius: 6px; font-size: 14px; font-weight: 500; cursor: pointer;">
                                    View on map
                                </button>
                            </div>
                        </div>

                        <!-- Playback controls row -->
                        <div style="display: flex; align-items: center; justify-content: space-between; border-top: 1px solid #eee; padding-top: 20px;">
                            <!-- Play button -->
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <button id="timelineYearPlayBtn"
                                        style="background: #000; color: white; border: none; border-radius: 50%; width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; cursor: pointer;">
                                    <i class="fa fa-play" style="margin-left: 2px;"></i>
                                </button>
                                <button id="timelineYearStopBtn"
                                        style="background: #666; color: white; border: none; border-radius: 4px; padding: 8px 12px; font-size: 12px; cursor: pointer;" disabled>
                                    Stop
                                </button>
                            </div>

                            <!-- Current year display -->
                            <div id="currentYearDisplay" style="display: flex; align-items: center; padding: 6px 12px; background: #f8f9fa; border-radius: 6px; color: #666; font-size: 12px;">
                                <i class="fa fa-calendar" style="margin-right: 5px;"></i>
                                <span>Ready to explore temporal changes</span>
                            </div>

                            <!-- Speed control -->
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <select id="timelineYearSpeed"
                                        style="border: 1px solid #ddd; border-radius: 20px; padding: 6px 12px; font-size: 12px; background: white;">
                                    <option value="2000">2x</option>
                                    <option value="3000">1.5x</option>
                                    <option value="5000" selected>1x</option>
                                    <option value="7000">0.5x</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Month-based Timeline UI -->
                <div class="timeline-type-month">
                    <!-- Figma-style Timeline Controls -->
                    <div class="timeline-figma-container" style="margin-top: 20px;">
                        <!-- Header text -->
                        <p style="color: #666; margin-bottom: 20px; font-size: 14px;">
                            Explore seasonal patterns across all years. Press play to view monthly changes.
                        </p>

                        <!-- Playback controls row -->
                        <div style="display: flex; align-items: center; justify-content: space-between; border-top: 1px solid #eee; padding-top: 20px; margin-bottom: 20px;">
                            <!-- Play button -->
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <button id="timelineMonthPlayBtn"
                                        style="background: #000; color: white; border: none; border-radius: 50%; width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; cursor: pointer;">
                                    <i class="fa fa-play" style="margin-left: 2px;"></i>
                                </button>
                                <button id="timelineMonthStopBtn"
                                        style="background: #666; color: white; border: none; border-radius: 4px; padding: 8px 12px; font-size: 12px; cursor: pointer;" disabled>
                                    Stop
                                </button>
                            </div>

                            <!-- Current month display -->
                            <div id="currentMonthDisplay" style="display: flex; align-items: center; padding: 6px 12px; background: #f8f9fa; border-radius: 6px; color: #666; font-size: 12px;">
                                <i class="fa fa-calendar" style="margin-right: 5px;"></i>
                                <span>Ready to explore seasonal patterns</span>
                            </div>

                            <!-- Speed control -->
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <select id="timelineMonthSpeed"
                                        style="border: 1px solid #ddd; border-radius: 20px; padding: 6px 12px; font-size: 12px; background: white;">
                                    <option value="2000">2x</option>
                                    <option value="3000">1.5x</option>
                                    <option value="5000" selected>1x</option>
                                    <option value="7000">0.5x</option>
                                </select>
                            </div>
                        </div>

                        <!-- Month Selection -->
                        <div class="timeline-month-selection" style="border-top: 1px solid #eee; padding-top: 20px;">
                            <label style="display: block; margin-bottom: 10px; font-size: 12px; color: #666; text-transform: uppercase; font-weight: 500;">Select Months to Include</label>

                            <!-- Quick Selection Buttons -->
                            <div style="margin-bottom: 15px;">
                                <div class="btn-group btn-group-sm">
                                    <button type="button" class="btn btn-default" id="selectAllMonths">All</button>
                                    <button type="button" class="btn btn-default" id="selectSpringMonths">Spring</button>
                                    <button type="button" class="btn btn-default" id="selectSummerMonths">Summer</button>
                                    <button type="button" class="btn btn-default" id="selectAutumnMonths">Autumn</button>
                                    <button type="button" class="btn btn-default" id="selectWinterMonths">Winter</button>
                                    <button type="button" class="btn btn-default" id="clearAllMonths">None</button>
                                </div>
                            </div>

                            <div class="timeline-month-checkboxes" style="margin-bottom: 15px;">
                                <div class="row">
                                    <div class="col-sm-4">
                                        <div class="checkbox">
                                            <label><input type="checkbox" value="1" class="month-checkbox" checked> January</label>
                                        </div>
                                        <div class="checkbox">
                                            <label><input type="checkbox" value="2" class="month-checkbox" checked> February</label>
                                        </div>
                                        <div class="checkbox">
                                            <label><input type="checkbox" value="3" class="month-checkbox" checked> March</label>
                                        </div>
                                        <div class="checkbox">
                                            <label><input type="checkbox" value="4" class="month-checkbox" checked> April</label>
                                        </div>
                                    </div>
                                    <div class="col-sm-4">
                                        <div class="checkbox">
                                            <label><input type="checkbox" value="5" class="month-checkbox" checked> May</label>
                                        </div>
                                        <div class="checkbox">
                                            <label><input type="checkbox" value="6" class="month-checkbox" checked> June</label>
                                        </div>
                                        <div class="checkbox">
                                            <label><input type="checkbox" value="7" class="month-checkbox" checked> July</label>
                                        </div>
                                        <div class="checkbox">
                                            <label><input type="checkbox" value="8" class="month-checkbox" checked> August</label>
                                        </div>
                                    </div>
                                    <div class="col-sm-4">
                                        <div class="checkbox">
                                            <label><input type="checkbox" value="9" class="month-checkbox" checked> September</label>
                                        </div>
                                        <div class="checkbox">
                                            <label><input type="checkbox" value="10" class="month-checkbox" checked> October</label>
                                        </div>
                                        <div class="checkbox">
                                            <label><input type="checkbox" value="11" class="month-checkbox" checked> November</label>
                                        </div>
                                        <div class="checkbox">
                                            <label><input type="checkbox" value="12" class="month-checkbox" checked> December</label>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Jump to Single Month -->
                            <div style="display: flex; gap: 10px; align-items: flex-end;">
                                <div style="flex: 1;">
                                    <select id="jumpToMonth" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px;">
                                        <option value="">Jump to specific month...</option>
                                        <option value="1">January</option>
                                        <option value="2">February</option>
                                        <option value="3">March</option>
                                        <option value="4">April</option>
                                        <option value="5">May</option>
                                        <option value="6">June</option>
                                        <option value="7">July</option>
                                        <option value="8">August</option>
                                        <option value="9">September</option>
                                        <option value="10">October</option>
                                        <option value="11">November</option>
                                        <option value="12">December</option>
                                    </select>
                                </div>
                                <div>
                                    <button id="jumpToMonthBtn" style="background: #000; color: white; border: none; padding: 8px 16px; border-radius: 6px; font-size: 14px; cursor: pointer;">
                                        Show Month
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Status Messages -->
                <div class="timeline-simple-status">
                    <div id="timelineSimpleLoading" class="alert alert-info timeline-status-msg" style="display:none;">
                        <i class="fa fa-spinner fa-spin"></i> Loading timeline data...
                    </div>
                    <div id="timelineSimpleError" class="alert alert-danger timeline-status-msg" style="display:none;">
                        <i class="fa fa-exclamation-triangle"></i>
                        <span id="timelineSimpleErrorMessage"></span>
                    </div>
                    <div id="timelineSimpleSuccess" class="alert alert-success timeline-status-msg" style="display:none;">
                        <i class="fa fa-check-circle"></i>
                        <span id="timelineSimpleSuccessMessage"></span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<asset:script type="text/javascript">
// Configuration for timeline-simple.js
window.timelineSimpleConfig = {
    timelineBoundsUrl: "${createLink(controller:'occurrence', action:'timelineBounds')}",
    timelineCountUrl: "${createLink(controller:'occurrence', action:'timelineCount')}",
    monthlyCountUrl: "${createLink(controller:'occurrence', action:'monthlyCount')}",
    timelineConfigUrl: "${createLink(controller:'occurrence', action:'timelineConfig')}"
};

// Enhanced Timeline Simple with proper map integration
if (typeof TimelineSimple !== 'undefined') {
    // Override the loadConfiguration method to use proper URLs
    TimelineSimple.loadConfiguration = function() {
        var self = this;
        $.ajax({
            url: window.timelineSimpleConfig.timelineConfigUrl,
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
    };

    // Override applyMonthFilter to properly integrate with existing map
    TimelineSimple.applyMonthFilter = function(month) {
        if (month < 1 || month > 12) {
            console.error('Invalid month:', month);
            return;
        }

        // Create month filter: month:[1 TO 1] for January, etc.
        var monthFilter = 'month:[' + month + ' TO ' + month + ']';

        console.log('Applying month filter:', monthFilter);

        // Apply the filter using the existing map integration
        if (typeof MAP_VAR !== 'undefined') {
            // Store original filters if not already stored
            if (typeof TIMELINE_VAR !== 'undefined') {
                if (!TIMELINE_VAR.originalAdditionalFqs && TIMELINE_VAR.originalAdditionalFqs !== '') {
                    TIMELINE_VAR.originalAdditionalFqs = MAP_VAR.additionalFqs || '';
                }

                // Apply month filter to map
                var baseFilters = TIMELINE_VAR.originalAdditionalFqs;
                if (baseFilters && baseFilters.trim() !== '') {
                    MAP_VAR.additionalFqs = baseFilters + '&fq=' + encodeURIComponent(monthFilter);
                } else {
                    MAP_VAR.additionalFqs = '&fq=' + encodeURIComponent(monthFilter);
                }
            } else {
                // Fallback if TIMELINE_VAR not available
                MAP_VAR.additionalFqs = '&fq=' + encodeURIComponent(monthFilter);
            }

            // Refresh the map layer
            if (typeof addQueryLayer === 'function') {
                console.log('Debug: MAP_VAR.query:', MAP_VAR.query);
                console.log('Debug: MAP_VAR.additionalFqs:', MAP_VAR.additionalFqs);
                console.log('Debug: Full URL would be:', MAP_VAR.mappingUrl + "/mapping/wms/reflect" + MAP_VAR.query + MAP_VAR.additionalFqs);
                addQueryLayer(true);
                console.log('Map layer refreshed with month filter');
            } else {
                console.error('addQueryLayer function not available');
            }
        } else {
            console.error('MAP_VAR not available');
        }
    };

    // Override applyYearFilter for better integration
    TimelineSimple.applyYearFilter = function(startYear, endYear) {
        if (!startYear || !endYear) {
            this.showMessage('error', 'Please provide valid start and end years');
            return;
        }

        var yearFilter = 'year:[' + startYear + ' TO ' + endYear + ']';

        console.log('Applying year filter:', yearFilter);

        if (typeof MAP_VAR !== 'undefined') {
            if (typeof TIMELINE_VAR !== 'undefined') {
                if (!TIMELINE_VAR.originalAdditionalFqs && TIMELINE_VAR.originalAdditionalFqs !== '') {
                    TIMELINE_VAR.originalAdditionalFqs = MAP_VAR.additionalFqs || '';
                }

                var baseFilters = TIMELINE_VAR.originalAdditionalFqs;
                if (baseFilters && baseFilters.trim() !== '') {
                    MAP_VAR.additionalFqs = baseFilters + '&fq=' + encodeURIComponent(yearFilter);
                } else {
                    MAP_VAR.additionalFqs = '&fq=' + encodeURIComponent(yearFilter);
                }
            } else {
                MAP_VAR.additionalFqs = '&fq=' + encodeURIComponent(yearFilter);
            }

            if (typeof addQueryLayer === 'function') {
                console.log('Debug: MAP_VAR.query:', MAP_VAR.query);
                console.log('Debug: MAP_VAR.additionalFqs:', MAP_VAR.additionalFqs);
                console.log('Debug: Full URL would be:', MAP_VAR.mappingUrl + "/mapping/wms/reflect" + MAP_VAR.query + MAP_VAR.additionalFqs);
                addQueryLayer(true);
                this.showMessage('success', 'Showing records from ' + startYear + ' to ' + endYear);
                console.log('Map layer refreshed with year filter');
            } else {
                console.error('addQueryLayer function not available');
            }
        } else {
            console.error('MAP_VAR not available');
        }
    };

    // Override clearCurrentFilters for proper cleanup
    TimelineSimple.clearCurrentFilters = function() {
        if (typeof MAP_VAR !== 'undefined' && typeof TIMELINE_VAR !== 'undefined') {
            if (TIMELINE_VAR.originalAdditionalFqs !== null && TIMELINE_VAR.originalAdditionalFqs !== undefined) {
                MAP_VAR.additionalFqs = TIMELINE_VAR.originalAdditionalFqs;
                if (typeof addQueryLayer === 'function') {
                    addQueryLayer(true);
                    console.log('Timeline filters cleared and map refreshed');
                }
            }
        }
    };

    // Override updatePlaybackUI to show current month name
    TimelineSimple.updatePlaybackUI = function() {
        var $playBtn = $('#timelinePlayBtn');
        var $stopBtn = $('#timelineStopBtn');
        var $currentDisplay = $('#currentMonthDisplay');

        if (this.state.isPlaying) {
            $playBtn.text('Pause').addClass('btn-warning');
            $stopBtn.prop('disabled', false);

            // Update current month display
            if (this.state.timelineType === 'month' && this.state.currentMonth) {
                var monthName = this.config.monthNames[this.state.currentMonth - 1];
                $currentDisplay.text('Currently showing: ' + monthName + ' data across all years');
            }
        } else {
            $playBtn.text('Play Months').removeClass('btn-warning');
            $stopBtn.prop('disabled', true);
            $currentDisplay.text('Ready to explore seasonal patterns');
        }
    };
} // End of TimelineSimple enhancement block

// Initialize month-based timeline functionality when page loads
$(document).ready(function() {
    // Initialize TIMELINE_VAR.originalAdditionalFqs if needed
    if (typeof TIMELINE_VAR !== 'undefined' && typeof MAP_VAR !== 'undefined') {
        if (!TIMELINE_VAR.originalAdditionalFqs) {
            TIMELINE_VAR.originalAdditionalFqs = MAP_VAR.additionalFqs || '';
        }
    }

    // Timeline type switching
    $('input[name="timelineType"]').change(function() {
        var newType = $(this).val();
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.switchTimelineType(newType);
        }
    });

    // Month timeline playback controls
    $('#timelineMonthPlayBtn').click(function() {
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.startMonthPlayback();
        }
    });

    $('#timelineMonthStopBtn').click(function() {
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.stopPlayback();
        }
    });

    // Year timeline playback controls
    $('#timelineYearPlayBtn').click(function() {
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.startYearPlayback();
        }
    });

    $('#timelineYearStopBtn').click(function() {
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.stopPlayback();
        }
    });

    // Speed controls for both timelines
    $('#timelineMonthSpeed').change(function() {
        var newSpeed = parseInt($(this).val());
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.state.playbackSpeed = newSpeed;
            console.log('Month timeline speed changed to:', newSpeed + 'ms');
        }
    });

    $('#timelineYearSpeed').change(function() {
        var newSpeed = parseInt($(this).val());
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.state.playbackSpeed = newSpeed;
            console.log('Year timeline speed changed to:', newSpeed + 'ms');
        }
    });

    // Month checkbox change handler
    $('.month-checkbox').change(function() {
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.updateSelectedMonths();
        }
    });

    // Seasonal preset buttons
    $('#selectAllMonths').click(function() {
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.setSelectedMonths([1,2,3,4,5,6,7,8,9,10,11,12]);
        }
    });

    $('#selectSpringMonths').click(function() {
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.setSelectedMonths([3,4,5]); // March, April, May
        }
    });

    $('#selectSummerMonths').click(function() {
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.setSelectedMonths([6,7,8]); // June, July, August
        }
    });

    $('#selectAutumnMonths').click(function() {
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.setSelectedMonths([9,10,11]); // September, October, November
        }
    });

    $('#selectWinterMonths').click(function() {
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.setSelectedMonths([12,1,2]); // December, January, February
        }
    });

    $('#clearAllMonths').click(function() {
        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.setSelectedMonths([]);
        }
    });

    // Jump to month functionality
    $('#jumpToMonthBtn').click(function() {
        var month = parseInt($('#jumpToMonth').val());
        if (month && typeof TimelineSimple !== 'undefined') {
            // Update TimelineSimple state
            TimelineSimple.state.currentMonth = month;
            TimelineSimple.state.isPlaying = false;

            // Apply the filter
            TimelineSimple.applyMonthFilter(month);

            // Update display
            TimelineSimple.updateCurrentMonthDisplay();

            var monthName = $('#jumpToMonth option:selected').text();
            TimelineSimple.showMessage('success', 'Jumped to ' + monthName + ' seasonal data');
        } else {
            if (typeof TimelineSimple !== 'undefined') {
                TimelineSimple.showMessage('error', 'Please select a month');
            }
        }
    });

    // Year-based view on map button
    $('#viewOnMapBtn').click(function() {
        var startYear = $('#simpleStartYear').val();
        var endYear = $('#simpleEndYear').val();

        if (!startYear || !endYear) {
            if (typeof TimelineSimple !== 'undefined') {
                TimelineSimple.showMessage('error', 'Please enter both start and end years');
            }
            return;
        }

        if (typeof TimelineSimple !== 'undefined') {
            TimelineSimple.applyYearFilter(parseInt(startYear), parseInt(endYear));
        }
    });

    // Debug information
    console.log('Timeline Simple integration loaded');
    console.log('MAP_VAR available:', typeof MAP_VAR !== 'undefined');
    console.log('TIMELINE_VAR available:', typeof TIMELINE_VAR !== 'undefined');
    console.log('addQueryLayer available:', typeof addQueryLayer === 'function');
    console.log('TimelineSimple available:', typeof TimelineSimple !== 'undefined');
});
</asset:script>
