# NBN Atlas Timeline Feature

## Overview

The NBN Atlas Timeline feature adds temporal data visualization and filtering capabilities to the occurrence map view. Users can explore species observations across time using an interactive timeline control with playback functionality.

## Features

### 🕒 **Timeline Control**
- Interactive slider for selecting date ranges
- Manual year input fields for precise control
- Real-time map updates as temporal filters are applied

### ▶️ **Playback Mode**
- Play/Pause controls for animated timeline progression
- Adjustable playback speed (Slow/Normal/Fast)
- Visual progression through time periods

### 📊 **Temporal Granularity**
- **Yearly**: View data year by year
- **5-Year**: Aggregate data into 5-year periods
- **Decade**: View data by decades

### 💾 **Performance Optimizations**
- Intelligent caching of temporal queries
- Debounced API calls to prevent request flooding
- Efficient Solr facet queries using existing year field

## User Journey

### 1. **Timeline Availability**
- Timeline automatically appears when temporal data is available for the current search
- Requires minimum of 2 years of data to activate
- Hidden for searches without sufficient temporal coverage

### 2. **Timeline Interaction**
```
Map Page → Timeline Control Appears → User Interactions:
├── Toggle timeline panel visibility
├── Adjust date range via slider or inputs
├── Select temporal granularity
├── Use playback controls
└── Reset to view all data
```

### 3. **Map Updates**
- Map automatically refreshes with temporal filters applied
- Occurrence count updates in real-time
- Visual feedback during loading states

## Technical Implementation

### Backend Components

#### **TimelineService.groovy**
```groovy
// Core service handling temporal data operations
- getTemporalBounds(): Determine min/max years for search
- getTemporalDistribution(): Get occurrence counts by time period
- getTemporalOccurrenceCount(): Count records for specific date range
- hasTimelineData(): Check if timeline should be available
```

#### **OccurrenceController Endpoints**
```
GET /occurrence/timelineBounds - Get temporal bounds for search
GET /occurrence/timelineDistribution - Get temporal distribution data
GET /occurrence/timelineCount - Get count for specific period
```

#### **Caching Strategy**
```yaml
temporalBoundsCache: 15 min TTL, 100 entries
temporalDistributionCache: 15 min TTL, 200 entries
temporalCountCache: 10 min TTL, 500 entries
```

### Frontend Components

#### **HTML Structure**
- Timeline control panel with collapsible content
- Date range inputs and jQuery UI slider
- Playback controls and granularity selector
- Status indicators and loading states

#### **JavaScript Functionality**
- `TIMELINE_VAR`: Global state management
- Debounced filter updates (300ms delay)
- AJAX integration with backend endpoints
- Automatic map layer refresh

#### **CSS Styling**
- Responsive design for desktop and mobile
- Integration with existing Leaflet map controls
- Accessibility-focused interaction design

## API Integration

### Solr Query Enhancement
```
Original: ?q=lsid:NHMSYS0000503827
With Timeline: ?q=lsid:NHMSYS0000503827&fq=year:[1990 TO 2000]
```

### Biocache Integration
- Leverages existing `year` field in Solr index
- Uses standard facet queries for temporal distribution
- Compatible with existing WMS layer rendering

## Configuration

### Cache Settings
```yaml
grails:
  cache:
    enabled: true
    caches:
      temporalBoundsCache:
        timeToLiveSeconds: 900  # 15 minutes
      temporalDistributionCache:
        timeToLiveSeconds: 900  # 15 minutes
      temporalCountCache:
        timeToLiveSeconds: 600  # 10 minutes
```

### Dependencies
```gradle
// Already included in existing NBN Atlas setup:
compile "org.grails.plugins:cache:4.0.0"
compile "org.grails.plugins:cache-ehcache:3.0.0"
```

## Performance Considerations

### **Caching Benefits**
- Repeated temporal queries cached for 10-15 minutes
- Reduces Solr query load during user interactions
- Improves response times for common date ranges

### **Debouncing**
- 300ms delay prevents excessive API calls during slider movement
- Immediate updates only on final user actions
- Balances responsiveness with performance

### **Query Optimization**
- Uses efficient Solr facet queries on indexed `year` field
- Minimal additional load on existing biocache infrastructure
- Leverages existing WMS caching mechanisms

## Browser Compatibility

- **Modern Browsers**: Full functionality with ES5+ support
- **Mobile**: Responsive design with touch-friendly controls
- **Accessibility**: Keyboard navigation and screen reader support

## Testing

### Unit Tests
```bash
./gradlew test --tests "*TimelineServiceSpec"
```

### Integration Testing
1. Search for species with temporal data
2. Verify timeline control appears
3. Test slider interactions and playback
4. Confirm map updates correctly
5. Validate performance under load

## Troubleshooting

### Timeline Not Appearing
- Check if search results contain `year` field data
- Verify minimum 2 years of data available
- Check browser console for JavaScript errors

### Slow Performance
- Monitor cache hit rates in logs
- Check Solr query performance
- Verify network latency to biocache services

### Map Not Updating
- Verify temporal filter parameters in network tab
- Check WMS layer refresh functionality
- Confirm JavaScript event handlers are attached

## Future Enhancements

### Potential Improvements
- **Month-level granularity** for detailed temporal analysis
- **Temporal heatmaps** showing intensity over time
- **Seasonal patterns** visualization
- **Species comparison** across multiple taxa
- **Export functionality** for temporal data

### Data Enhancements
- Integration with `month` field for finer temporal resolution
- Support for date ranges (e.g., breeding seasons)
- Historical data quality indicators

## Security Considerations

- All temporal queries inherit existing search permissions
- No additional authentication required
- Cached data respects original query constraints
- XSS protection through parameterized queries

---

## Developer Notes

### Adding New Temporal Granularities
```groovy
// In TimelineService.processTemporalData()
case 'month':
    // Implementation for monthly aggregation
```

### Customizing Cache TTL
```yaml
# Adjust based on data update frequency and server capacity
temporalBoundsCache:
  timeToLiveSeconds: 1800  # 30 minutes for slower-changing bounds
```

### Frontend Customization
```javascript
// Modify TIMELINE_VAR defaults for different behaviors
TIMELINE_VAR.playbackSpeed = 500;  // Faster default playback
```
