# NBN Atlas Timeline Feature

## Overview

The NBN Atlas Timeline feature provides a simple, intuitive way for users to explore temporal patterns in species occurrence data. The feature emphasizes ease of use with a clean, modern interface that allows users to filter occurrence data by time periods and discover seasonal patterns.

## Key Features

### 🎯 **Simple Timeline Interface**
- **Clean, modern design** following Figma specifications
- **Two timeline modes**: Year-based chronological filtering and Month-based seasonal analysis
- **One-click filtering** with "View on map" button
- **Real-time map updates** when temporal filters are applied

### 📅 **Timeline Modes**

#### **Year-Based Timeline**
- Filter occurrences by date ranges (e.g., 1990-2010)
- Simple from/to year inputs
- Optional playback to animate through time periods
- Perfect for studying long-term trends and changes

#### **Month-Based Seasonal Timeline**
- **Seasonal pattern analysis** - aggregates data across all years by month
- **Cross-year aggregation**: January shows ALL January data from all years combined
- **Ecological insights**: Reveals breeding seasons, migration patterns, and climate effects
- **Month selection**: Choose specific months or seasonal ranges (Spring, Summer, etc.)
- **Educational value**: Helps understand seasonal behaviors across species

## User Experience

### 1. **Accessing the Timeline**
- Timeline button appears on the map when temporal data is available
- Clean, minimal interface that doesn't overwhelm the user
- Automatically hidden for searches without sufficient temporal data

### 2. **Basic Usage**
```
Map Page → Timeline Button → Choose Mode:
├── Year Mode: Enter start/end years → "View on map"
├── Month Mode: Select months → Play seasonal patterns
└── Close: Return to normal map view
```

### 3. **Year-Based Filtering**
1. **Select Year Mode** (if not already selected)
2. **Enter dates**: Input start year (e.g., 1990) and end year (e.g., 2010)
3. **View results**: Click "View on map" to filter occurrences
4. **Optional playback**: Use play button for animated progression through years

### 4. **Seasonal Analysis (Month Mode)**
1. **Select Month Mode** (default setting)
2. **Choose months**:
   - Select individual months using checkboxes
   - Use quick buttons: All, Spring, Summer, Autumn, Winter, None
3. **Play seasonal patterns**: Click play to cycle through selected months
4. **Jump to specific month**: Use dropdown to view a particular month
5. **Understand the data**: Each month shows aggregated data across all years

## What Makes It Simple

### **Intuitive Design**
- **Minimal inputs**: Only essential controls are visible
- **Clear labeling**: Obvious field labels and button text
- **Visual feedback**: Loading states and success messages
- **Progressive disclosure**: Advanced options hidden by default

### **Smart Defaults**
- **Month-based mode**: Default to seasonal analysis (most educational)
- **All months selected**: Start with complete seasonal view
- **Reasonable year ranges**: 1800-2024 boundaries with sensible defaults

### **No Complex Configuration**
- **No granularity controls**: System automatically chooses appropriate level
- **No speed adjustments**: Sensible playback speed pre-configured
- **No slider complexity**: Simple input fields and buttons only

## Technical Integration

### **Backend Services**
- **Temporal bounds detection**: Automatically determines available date ranges
- **Fast filtering**: Efficient Solr queries using existing indexed fields
- **Smart caching**: Reduces server load for repeated queries

### **Map Integration**
- **Seamless filtering**: Uses existing biocache WMS infrastructure
- **Instant updates**: Map refreshes automatically with new temporal filters
- **Filter preservation**: Timeline filters work alongside other search criteria

### **Performance Optimized**
- **Lightweight queries**: Uses existing `year` and `month` fields in Solr
- **Debounced updates**: Prevents excessive requests during user interaction
- **Cached responses**: Common temporal queries cached for faster response

## Browser Support

- **Modern browsers**: Full functionality on Chrome, Firefox, Safari, Edge
- **Mobile responsive**: Touch-friendly controls on tablets and phones
- **Accessibility**: Keyboard navigation and screen reader support

## Configuration

The timeline feature is configured through `timeline-config.yml`:

```yaml
timeline:
  ui:
    mode: 'simple'  # Clean, Figma-designed interface
  defaults:
    timelineType: 'month'  # Start with seasonal analysis
  features:
    enableSimpleMode: true
    enableAdvancedMode: false  # Hide complex controls
```

## When Timeline Appears

The timeline automatically appears when:
- ✅ Search results contain temporal data (year or month fields)
- ✅ Minimum 2 years of data available
- ✅ Current search has sufficient occurrence records

The timeline is hidden when:
- ❌ No temporal data in search results
- ❌ Insufficient data for meaningful temporal analysis
- ❌ User explicitly closes the timeline panel


---

## Summary

The NBN Atlas Timeline feature transforms complex temporal data into an intuitive, educational tool. By focusing on simplicity and clear user experience, it makes temporal analysis accessible to both expert researchers and curious nature enthusiasts. The dual-mode approach—seasonal patterns and temporal trends—provides comprehensive insights into species behavior and population changes over time.
