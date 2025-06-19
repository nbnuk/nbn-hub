# Timeline Simplification - Phase 2 COMPLETE + Month-Based Timeline

## Overview
Phase 2 of the timeline simplification project implements full functional integration for the simple timeline component, connecting it to the backend services and providing configuration-driven mode switching between simple and advanced timelines. **Now includes Month-Based Timeline Behavior from ALA Spatial Portal for seasonal pattern analysis.**

## ✅ Phase 2 Implementation Complete

### 🔌 Backend Integration
- **Temporal Bounds Integration**: Simple timeline now fetches real temporal bounds from `/occurrence/timelineBounds`
- **Count Integration**: Shows actual record counts via `/occurrence/timelineCount`
- **Filter Application**: Applies temporal filters using the same mechanism as advanced timeline
- **Map Layer Updates**: Triggers map layer refresh when filters are applied

### ⚙️ Configuration Service
- **File**: `grails-app/services/uk/org/nbn/biocache/hubs/TimelineConfigService.groovy`
- **YAML Support**: Reads configuration from `timeline-config.yml`
- **Environment-specific**: Supports dev/test/prod environment overrides
- **Feature Flags**: Controls which timeline modes are enabled
- **Caching**: Efficient file-based caching with change detection

### 🔄 Mode Switching
- **Conditional Rendering**: Simple and advanced timelines shown based on configuration
- **Feature Flags**: `enableSimpleMode` and `enableAdvancedMode` control visibility
- **Environment Overrides**: Different modes per environment (dev/test/prod)
- **Graceful Fallback**: Defaults to simple mode if configuration is missing

### 🌐 REST API Enhancements
- **New Endpoint**: `/occurrence/timelineConfig` serves configuration to frontend
- **URL Mapping**: Added to UrlMappings.groovy for proper routing
- **JSON Response**: Configuration delivered as JSON for frontend consumption

### 📦 Dependency Management
- **SnakeYAML**: Added `org.yaml:snakeyaml:1.21` for YAML parsing
- **Build Integration**: Added to build.gradle dependencies

## 🆕 NEW: Month-Based Timeline Behavior (ALA Spatial Portal Pattern)

### 🌱 Seasonal Pattern Analysis
Following the ALA Spatial Portal implementation, the month-based timeline provides **seasonal pattern analysis** rather than chronological progression:

#### How It Works:
- **January Frame**: Shows ALL January data across ALL years (1990-2024)
- **February Frame**: Shows ALL February data across ALL years (1990-2024)
- **March Frame**: Shows ALL March data across ALL years (1990-2024)
- ...and so on through December

#### Key Insights:
- **Cross-Year Aggregation**: January shows data from 1990, 2000, 2010, 2020 all combined
- **Seasonal Patterns**: Reveals seasonal migration/occurrence patterns across the entire dataset
- **Not Chronological**: It's NOT showing Jan 1990, Feb 1990, Mar 1990, then Jan 1991, etc.
- **Ecological Analysis**: Excellent for breeding seasons, migration patterns, climate-driven distribution

### 🔧 Technical Implementation

#### Backend Services
```groovy
// New month-based methods in TimelineService
Map getMonthlyDistribution(SpatialSearchRequestParams requestParams)
Map getMonthOccurrenceCount(SpatialSearchRequestParams requestParams, Integer month)
Map getTemporalOccurrenceCount(..., String timelineType = 'year')
```

#### Filter Pattern (ALA Compatible)
```javascript
// Year-based filter
year:[1990 TO 2000]

// Month-based filter (seasonal aggregation)
month:[1 TO 1]    // All January data across all years
month:[6 TO 6]    // All June data across all years
month:[12 TO 12]  // All December data across all years
```

#### Month Playback Logic
```javascript
// Implements ALA Spatial Portal month stepping
case 'month':
    if (12 < s.monthRange[1] + s.monthStepSize) {
        fireEnd = true;
        scope.clearSteps();
        s.monthRange[0] = 1  // Reset to January
    } else {
        s.monthRange[0] += s.monthStepSize  // Move to next month
    }
    s.monthRange[1] = s.monthRange[0] + (s.monthStepSize - 1);
    break;
```

### 🎯 Default Configuration
As requested, **month-based timeline is now the default**:

```yaml
timeline:
  defaults:
    granularity: 'month'     # Default to month-based
    timelineType: 'month'    # Default to month-based timeline
  features:
    defaultToMonthBased: true  # Start with month-based timeline by default
```

### 🖥️ User Interface

#### Timeline Type Switching
```html
<div class="btn-group" data-toggle="buttons">
    <label class="btn btn-default btn-sm" id="timelineTypeYear">
        <input type="radio" name="timelineType" value="year">
        <span>By Year</span>
    </label>
    <label class="btn btn-default btn-sm active" id="timelineTypeMonth">
        <input type="radio" name="timelineType" value="month" checked>
        <span>By Month (Seasonal)</span>
    </label>
</div>
```

#### Month Playback Controls
- **Play/Stop Controls**: Automated progression through months 1-12
- **Speed Control**: Adjustable playback speed (1s - 5s per month)
- **Jump to Month**: Direct navigation to specific months
- **Current Month Display**: Shows which month is currently being displayed

#### Educational Information
```html
<div class="alert alert-info timeline-month-info">
    <i class="fa fa-info-circle"></i>
    <strong>Seasonal Analysis:</strong> Shows aggregated data for each month across all years.
    January shows all January data from all years combined, revealing seasonal patterns.
</div>
```

## 📊 REST API Endpoints

### Existing Endpoints (Enhanced)
```
GET /occurrence/timelineBounds       # Temporal bounds for search
GET /occurrence/timelineDistribution # Now supports month granularity
GET /occurrence/timelineCount        # Now supports month-based queries
GET /occurrence/timelineConfig       # Timeline configuration
```

### New Month-Based Endpoints
```
GET /occurrence/monthlyCount?month=1  # Seasonal count for specific month
```

### API Examples

#### Month-Based Distribution
```javascript
// Request
GET /occurrence/timelineDistribution?granularity=month

// Response
{
  "success": true,
  "granularity": "month",
  "type": "seasonal",
  "data": [
    {"period": "January", "month": 1, "count": 1250, "type": "month"},
    {"period": "February", "month": 2, "count": 980, "type": "month"},
    ...
  ],
  "totalRecords": 15600
}
```

#### Month-Based Count
```javascript
// Request - Get all June data across all years
GET /occurrence/timelineCount?timelineType=month&startPeriod=6&endPeriod=6

// Response
{
  "success": true,
  "startPeriod": 6,
  "endPeriod": 6,
  "timelineType": "month",
  "count": 2340,
  "period": "June"
}
```

## Technical Implementation Details

### Frontend Integration

#### **Month-Based Playback Logic**
```javascript
// Month-based timeline playback implementation
startMonthPlayback: function() {
    this.state.currentMonth = 1;  // Start with January

    function nextMonthStep() {
        // Apply filter for current month (shows ALL data for this month across ALL years)
        self.applyMonthFilter(self.state.currentMonth);

        // Move to next month
        self.state.currentMonth += self.state.monthStepSize;

        // Check if we've reached the end
        if (self.state.currentMonth > 12) {
            if (self.state.repeat) {
                self.state.currentMonth = 1;  // Loop back to January
            } else {
                self.stopPlayback();
            }
        }
    }
}
```

#### **Seasonal Filter Application**
```javascript
// Create month filter: month:[1 TO 1] for January, etc.
applyMonthFilter: function(month) {
    var monthFilter = 'month:[' + month + ' TO ' + month + ']';
    // Apply to map layer and refresh
}
```

### Backend Architecture

#### **TimelineService Enhancements**
```groovy
// Seasonal distribution across all years
Map getMonthlyDistribution(SpatialSearchRequestParams requestParams) {
    // Remove any existing year filters to get data across all years
    tempParams.facets = ['month'] // Facet by month field
    // Process 12 months with human-readable names
    return processMonthlyData(monthData)
}

// Month-based filtering support
Map getTemporalOccurrenceCount(requestParams, startPeriod, endPeriod, timelineType) {
    if (timelineType == 'month') {
        temporalFilter = "month:[${startPeriod} TO ${endPeriod}]"
    } else {
        temporalFilter = "year:[${startPeriod} TO ${endPeriod}]"
    }
}
```

### Configuration-Driven Behavior

#### **Month-Based Configuration**
```yaml
timeline:
  defaults:
    timelineType: 'month'        # Default to month-based behavior
    monthStepSize: 1             # Default step size in months
    monthRange: [1, 12]          # Default month range (Jan-Dec)
  advanced:
    monthBased:
      enabled: true
      defaultType: 'month'       # Default to month-based behavior
      allowTypeSwitching: true   # Allow switching between year/month
      monthStepSize: 1           # Default months to advance per step
      maxMonthStepSize: 12       # Maximum months per step
  features:
    enableMonthBasedTimeline: true    # Enable month-based timeline
    enableMonthTypeSwitching: true    # Allow switching between year/month
    defaultToMonthBased: true         # Start with month-based timeline by default
```

## Current Feature Set

### ✅ Fully Functional Month-Based Timeline
1. **Seasonal Pattern Analysis**: Shows aggregated data for each month across all years
2. **ALA Spatial Portal Compatibility**: Uses same filter patterns and logic
3. **Default Behavior**: Month-based timeline is now the default as requested
4. **Timeline Type Switching**: Toggle between year-based and month-based modes
5. **Month Playback**: Automated progression through months 1-12
6. **Jump to Month**: Direct navigation to specific months for analysis
7. **Speed Control**: Adjustable playback speed for month progression

### ✅ Enhanced Configuration System
1. **Month-Based Defaults**: Configuration supports month-based as default
2. **Feature Flags**: Granular control over month-based timeline features
3. **Type Switching Control**: Configure whether users can switch between modes
4. **Backend Integration**: Full REST API support for month-based queries

### ✅ Backward Compatibility
1. **Year-Based Support**: Original year-based timeline still works
2. **Legacy Endpoints**: Existing API endpoints enhanced, not replaced
3. **Graceful Fallback**: System falls back to year-based if month data unavailable

## Ecological Use Cases

### 🌍 Practical Applications
1. **Bird Migration Patterns**: See when species migrate through different seasons
2. **Breeding Season Analysis**: Identify when species are most active reproductively
3. **Seasonal Habitat Preferences**: Understand how species use different habitats by season
4. **Climate Impact Studies**: Analyze how seasonal patterns are changing over time
5. **Conservation Planning**: Plan interventions based on seasonal activity patterns

### 📈 Data Insights Available
- **Peak Activity Months**: Which months have highest occurrence records
- **Seasonal Gaps**: Months with low activity (hibernation, migration, etc.)
- **Geographic Seasonality**: How seasonal patterns vary across regions
- **Species Comparisons**: Compare seasonal patterns between different species

## File Structure Updated
```
grails-app/
├── controllers/uk/org/nbn/biocache/hubs/
│   └── OccurrenceController.groovy     # Enhanced with month-based endpoints
├── services/uk/org/nbn/biocache/hubs/
│   ├── TimelineService.groovy          # Enhanced with month-based methods
│   └── TimelineConfigService.groovy    # Enhanced with month-based config
├── views/occurrence/
│   └── _timeline-simple.gsp           # Enhanced with month-based UI
├── assets/javascripts/
│   └── timeline-simple.js             # Enhanced with month-based logic
├── assets/stylesheets/
│   └── timeline-simple.css            # Enhanced styling for month UI
└── conf/
    ├── timeline-config.yml            # Enhanced with month-based config
    └── UrlMappings.groovy             # Added month-based endpoints

src/test/groovy/uk/org/nbn/biocache/hubs/
└── TimelineServiceSpec.groovy         # Enhanced with month-based tests
```

## Summary

The Month-Based Timeline Behavior successfully implements the ALA Spatial Portal pattern for seasonal analysis, providing powerful ecological insights through cross-year month aggregation. This feature defaults to month-based behavior as requested and maintains full backward compatibility with year-based timelines.

**Key Achievement**: Users can now explore seasonal patterns across their entire dataset, revealing migration patterns, breeding seasons, and climate-driven distribution changes that would be impossible to see with traditional chronological timelines.
