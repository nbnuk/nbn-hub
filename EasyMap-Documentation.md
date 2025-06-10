# EasyMap Functionality Documentation

## Overview

The EasyMap functionality provides NBN Atlas-compatible species distribution mapping endpoints for the NBN Hub application. It offers both HTML and JSON responses for displaying species occurrence data on interactive maps, compatible with the existing NBN Atlas EasyMap API.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Components](#components)
3. [API Endpoints](#api-endpoints)
4. [Complete Parameter Reference](#complete-parameter-reference)
5. [Changing Map Appearance](#changing-map-appearance)
6. [Zooming and Map Extents](#zooming-and-map-extents)
7. [Displaying Date Bands](#displaying-date-bands)
8. [Legacy EasyMap Compatibility](#legacy-easymap-compatibility)
9. [Usage Examples](#usage-examples)
10. [Configuration](#configuration)
11. [Data Flow](#data-flow)
12. [Testing](#testing)
13. [Refactoring Guidelines](#refactoring-guidelines)
14. [Migration Checklist](#migration-checklist)

---

## Architecture Overview

The EasyMap functionality follows the standard Grails MVC pattern with clear separation of concerns:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Controller    │───▶│     Service     │───▶│  External APIs  │
│  (EasyMap)      │    │   (EasyMap)     │    │ (BIE/Biocache)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│      Views      │    │   Mock Data     │
│   (GSP/JSON)    │    │   (Fallback)    │
└─────────────────┘    └─────────────────┘
```

## Components

### 1. EasyMapController (`grails-app/controllers/uk/org/nbn/hub/EasyMapController.groovy`)

**Purpose**: Handles HTTP requests and responses for EasyMap endpoints.

**Key Methods**:
- `easyMap()`: Main endpoint for HTML/JSON responses
- `easyMapJson()`: Dedicated JSON endpoint
- `health()`: Health check endpoint
- `isValidTVK()`: TVK format validation

**Features**:
- Parameter validation and sanitization
- Content negotiation (HTML/JSON)
- HTTP caching headers
- Error handling with appropriate status codes
- Input validation for TVK format

**Parameters Supported**:
- `tvk` (required): Taxon Version Key
- `w`: Width (default: 800)
- `h`: Height (default: 600)
- `retina`: Retina display factor (default: 1)
- `cachedays`: Cache duration in days (default: 30)
- `format`: Response format (html/json)

### 2. EasyMapService (`grails-app/services/uk/org/nbn/hub/EasyMapService.groovy`)

**Purpose**: Business logic for species data retrieval and map configuration.

**Key Methods**:

#### Species Information
- `getSpeciesInfo(tvk)`: Retrieves species metadata from BIE service
- Returns: Scientific name, common name, taxonomic hierarchy, etc.

#### Occurrence Data
- `getOccurrenceData(tvk)`: Retrieves occurrence records from Biocache
- `isValidCoordinate(lat, lng)`: Validates coordinate data
- Returns: Filtered occurrence records with valid coordinates

#### Map Configuration
- `prepareMapConfig(occurrences)`: Calculates map bounds and zoom levels
- `calculateBounds(occurrences)`: Determines geographic bounds
- `calculateZoomLevel(bounds)`: Determines appropriate zoom level
- Returns: Map center, zoom, bounds for Leaflet

#### Statistics
- `getOccurrenceStatistics(occurrences)`: Generates data summaries
- Returns: Counts by basis of record, year, data provider, date ranges

#### Mock Data
- `getMockSpeciesInfo(tvk)`: Fallback species data
- `getMockOccurrenceData(tvk)`: Fallback occurrence data
- Used when external services are unavailable

**Dependencies**:
- `WebServicesService`: For external API calls
- `grailsApplication`: For configuration access

### 3. Views

#### GSP Template (`grails-app/views/easyMap/map.gsp`)
- Clean, map-only HTML view
- Leaflet.js integration for interactive mapping
- Responsive design
- No surrounding UI elements (as requested)
- JavaScript for map initialization and data display

#### Error Views
- `error.gsp`: Generic error display
- `notFound.gsp`: Species not found display

### 4. URL Mappings (`grails-app/controllers/uk/org/nbn/hub/UrlMappings.groovy`)

```groovy
// EasyMap URLs - NBN Atlas compatible
"/EasyMap"(controller: 'easyMap', action: 'easyMap')
"/EasyMap.json"(controller: 'easyMap', action: 'easyMapJson')
"/easymap/health"(controller: 'easyMap', action: 'health')
```

### 5. Configuration

**Application Configuration** (`application.yml` or `Config.groovy`):
```yaml
# Mock data toggle
use.mock.data: false

# Service URLs
biocache.baseUrl: "https://records-ws.nbnatlas.org"
bie.baseUrl: "https://species-ws.nbnatlas.org"

# Download URLs
download.url: "https://records.nbnatlas.org/occurrences/download"
download.doi.url: "https://records.nbnatlas.org/occurrences/download"
```

### 6. Unit Tests

#### EasyMapServiceSpec (`src/test/groovy/uk/org/nbn/hub/EasyMapServiceSpec.groovy`)
- Mock data functionality tests
- Map configuration tests
- Statistics generation tests
- Error handling tests

#### EasyMapControllerSpec (`src/test/groovy/uk/org/nbn/hub/EasyMapControllerSpec.groovy`)
- TVK validation tests
- Controller method availability tests
- Basic functionality tests

---

## API Endpoints

### 1. HTML Map Display

**Endpoint**: `GET /EasyMap?tvk={TVK}`

**Parameters**:
- `tvk` (required): Taxon Version Key (e.g., NHMSYS0000458183)
- `w` (optional): Map width in pixels (default: 800, max: 800)
- `h` (optional): Map height in pixels (calculated from width if not provided)
- `retina` (optional): Retina display factor (default: 1)
- `cachedays` (optional): Cache duration in days (default: 30)
- `ds` (optional): Dataset key(s) obtainable from the NBN Gateway (e.g., 'ds123' or comma-separated list 'ds123,ds456')

**Response**: HTML page with interactive Leaflet map

**Example**:
```
GET /EasyMap?tvk=NHMSYS0000458183&w=1200&h=800&retina=2
GET /EasyMap?tvk=NHMSYS0000458183&ds=ds123
GET /EasyMap?tvk=NHMSYS0000458183&ds=ds123,ds456&w=800
```

### 2. JSON Data API

**Endpoint**: `GET /EasyMap.json?tvk={TVK}`

**Parameters**: Same as HTML endpoint

**Response**: JSON object with species and occurrence data

**Example Response**:
```json
{
  "result": "SUCCESS",
  "message": "Map data retrieved successfully",
  "data": {
    "tvk": "NHMSYS0000458183",
    "speciesInfo": {
      "scientificName": "Dryopteris carthusiana",
      "commonName": "Narrow Buckler-fern",
      "rank": "species",
      "kingdom": "Plantae",
      "family": "Dryopteridaceae"
    },
    "occurrences": [
      {
        "id": "occurrence-uuid",
        "latitude": 51.5074,
        "longitude": -0.1278,
        "eventDate": "2023-06-15",
        "basisOfRecord": "HumanObservation",
        "locality": "London",
        "dataResourceUid": "dr123",
        "dataResourceName": "Example Dataset"
      }
    ],
    "mapConfig": {
      "occurrenceCount": 498,
      "defaultLatitude": 54.5,
      "defaultLongitude": -3.0,
      "defaultZoom": 6,
      "bounds": {
        "southwest": {"lat": 50.0, "lng": -8.0},
        "northeast": {"lat": 59.0, "lng": 2.0}
      }
    },
            "datasetFilter": "ds123"
  }
}
```

### 3. Health Check

**Endpoint**: `GET /easymap/health`

**Response**: Service health status

**Example Response**:
```json
{
  "result": "SUCCESS",
  "message": "EasyMap service is healthy",
  "data": {
    "service": "EasyMap",
    "status": "UP",
    "version": "1.0.0",
    "timestamp": "2025-01-28T16:30:00Z"
  }
}
```

---

## Complete Parameter Reference

### Core Parameters

| Parameter | Type | Description | Default | Example |
|-----------|------|-------------|---------|---------|
| `tvk` | String | **Required.** Taxon Version Key from NBN Atlas | - | `NHMSYS0000458183` |
| `w` | Integer | Map width in pixels (max: 800) | 800 | `600` |
| `h` | Integer | Map height in pixels | 600 | `400` |
| `retina` | Integer | Retina display factor (1 or 2) | 1 | `2` |
| `cachedays` | Integer | Cache duration in days (0 = no cache) | 30 | `7` |
| `format` | String | Response format: `html` or `json` | `html` | `json` |

### Data Filtering Parameters

| Parameter | Type | Description | Default | Example |
|-----------|------|-------------|---------|---------|
| `ds` | String | Dataset filter (comma-separated list) | All datasets | `ds123,ds456` |

### Map Appearance Parameters

| Parameter | Type | Description | Default | Example |
|-----------|------|-------------|---------|---------|
| `gd` / `res` | String | Grid resolution for occurrence display | `10km` | `100km`, `50km`, `10km`, `2km`, `1km` |
| `bg` | String | Background map layer | - | `VC` |

### Date Band Parameters

| Parameter | Type | Description | Default | Example |
|-----------|------|-------------|---------|---------|
| `b0from` | String | Start date for first date band (YYYY-MM-DD) | - | `2000-01-01` |
| `b0to` | String | End date for first date band (YYYY-MM-DD) | - | `2010-12-31` |
| `b0fill` | String | Color for first date band (hex without #) | `df4a21` | `FF0000` |
| `b1from` | String | Start date for second date band (YYYY-MM-DD) | - | `2011-01-01` |
| `b1to` | String | End date for second date band (YYYY-MM-DD) | - | `2020-12-31` |
| `b1fill` | String | Color for second date band (hex without #) | - | `00FF00` |
| `b2from` | String | Start date for third date band (YYYY-MM-DD) | - | `2021-01-01` |
| `b2to` | String | End date for third date band (YYYY-MM-DD) | - | `2023-12-31` |
| `b2fill` | String | Color for third date band (hex without #) | - | `0000FF` |

### Map Extent and Zoom Parameters

| Parameter | Type | Description | Default | Example |
|-----------|------|-------------|---------|---------|
| `zoom` | String | Predefined zoom area | Auto-calculated | `england`, `scotland`, `wales`, `highland`, `sco-mainland`, `outer-heb` |
| `vc` | String | Vice-county number (1-112) | - | `21` |
| `bl` | String | Bottom left grid reference | - | `TQ123456` |
| `tr` | String | Top right grid reference | - | `TQ789012` |
| `blCoord` | String | Bottom left coordinates (Easting,Northing) | - | `523456,178901` |
| `trCoord` | String | Top right coordinates (Easting,Northing) | - | `578901,223456` |

### Additional Parameters

| Parameter | Type | Description | Default | Example |
|-----------|------|-------------|---------|---------|
| `terms` | String | Terms and conditions text | - | `Custom terms` |
| `ref` | String | Reference information | - | `Survey ref` |
| `link` | String | Custom link URL | - | `https://example.com` |
| `css` | String | Custom CSS styling | - | `color:red` |

---

## Changing Map Appearance

### Background Layers

The EasyMap service supports background map layers through the `bg` parameter:

```bash
# Vice County background
GET /EasyMap?tvk=NHMSYS0000458183&bg=VC
```

### Grid Resolution

Control how occurrence data is displayed using the grid resolution parameter:

#### Supported Grid Resolutions

| Resolution | Description | Use Case |
|------------|-------------|----------|
| `1km` | Very fine grid | Detailed local data |
| `2km` | Fine grid | Local patterns |
| `10km` | Standard grid | General distribution |
| `50km` | Coarse grid | Regional patterns |
| `100km` | Very coarse grid | National overview |

#### Examples

```bash
# Large grid squares for overview
GET /EasyMap?tvk=NHMSYS0000458183&gd=100km&w=800

# Standard resolution
GET /EasyMap?tvk=NHMSYS0000458183&gd=10km&w=800

# High detail view
GET /EasyMap?tvk=NHMSYS0000458183&gd=1km&w=800
```

---

## Zooming and Map Extents

### Automatic Zoom Calculation

By default, EasyMap automatically calculates the optimal zoom level and center point based on the distribution of occurrence data:

```bash
# Auto-zoom to fit all occurrences
GET /EasyMap?tvk=NHMSYS0000458183
```

### Predefined Zoom Areas

#### Setting Specific Zoom Areas

```bash
# England
GET /EasyMap?tvk=NHMSYS0000458183&zoom=england

# Scotland
GET /EasyMap?tvk=NHMSYS0000458183&zoom=scotland

# Wales
GET /EasyMap?tvk=NHMSYS0000458183&zoom=wales

# Scottish Highlands
GET /EasyMap?tvk=NHMSYS0000458183&zoom=highland

# Scottish Mainland
GET /EasyMap?tvk=NHMSYS0000458183&zoom=sco-mainland

# Outer Hebrides
GET /EasyMap?tvk=NHMSYS0000458183&zoom=outer-heb
```

### Vice-County Zoom

#### Zoom to Specific Vice-County

```bash
# Surrey (VC 17)
GET /EasyMap?tvk=NHMSYS0000458183&vc=17

# Middlesex (VC 21)
GET /EasyMap?tvk=NHMSYS0000458183&vc=21

# West Cornwall (VC 1)
GET /EasyMap?tvk=NHMSYS0000458183&vc=1
```

### Grid Reference Bounds

#### Setting Specific Grid Reference Bounds

```bash
# Using grid references (both bl and tr required)
GET /EasyMap?tvk=NHMSYS0000458183&bl=TQ123456&tr=TQ789012

# 10km grid squares
GET /EasyMap?tvk=NHMSYS0000458183&bl=TQ12&tr=TQ78

# 1km grid squares
GET /EasyMap?tvk=NHMSYS0000458183&bl=TQ1234567890&tr=TQ7890123456
```

### Coordinate Bounds

#### Setting Specific Coordinate Bounds

```bash
# Using British National Grid coordinates (Easting,Northing)
GET /EasyMap?tvk=NHMSYS0000458183&blCoord=523456,178901&trCoord=578901,223456

# London area example
GET /EasyMap?tvk=NHMSYS0000458183&blCoord=530000,180000&trCoord=535000,185000
```

---

## Displaying Date Bands

Date bands allow you to visualize temporal patterns in species occurrence data by displaying different time periods in different colors.

### Basic Date Band Usage

#### Single Date Band

```bash
# Show records from 2000-2023 in red
GET /EasyMap?tvk=NHMSYS0000458183&b0from=2000-01-01&b0to=2023-12-31&b0fill=FF0000
```

#### Multiple Date Bands

```bash
# Three time periods with different colors
GET /EasyMap?tvk=NHMSYS0000458183
  &b0from=1900-01-01&b0to=1950-12-31&b0fill=df4a21
  &b1from=1951-01-01&b1to=2000-12-31&b1fill=00FF00
  &b2from=2001-01-01&b2to=2023-12-31&b2fill=0000FF
```

### Date Band Format

Each date band requires:

- **bXfrom**: Starting date (YYYY-MM-DD format)
- **bXto**: Ending date (YYYY-MM-DD format)
- **bXfill**: Point fill color (6-digit hex without #)

Where X is the band number (0, 1, or 2).

### Common Date Band Patterns

#### Historical Analysis

```bash
# Victorian era vs Modern records
GET /EasyMap?tvk=NHMSYS0000458183
  &b0from=1837-01-01&b0to=1901-12-31&b0fill=8B4513
  &b1from=2000-01-01&b1to=2023-12-31&b1fill=FF0000
```

#### Decadal Breakdown

```bash
# Decade-by-decade analysis
GET /EasyMap?tvk=NHMSYS0000458183
  &b0from=1990-01-01&b0to=1999-12-31&b0fill=FF0000
  &b1from=2000-01-01&b1to=2009-12-31&b1fill=00FF00
  &b2from=2010-01-01&b2to=2019-12-31&b2fill=0000FF
```

#### Conservation Timeline

```bash
# Before and after conservation efforts
GET /EasyMap?tvk=NHMSYS0000458183
  &b0from=1950-01-01&b0to=1979-12-31&b0fill=FF0000
  &b1from=1980-01-01&b1to=1999-12-31&b1fill=FFAA00
  &b2from=2000-01-01&b2to=2023-12-31&b2fill=00FF00
```

### Combining Date Bands with Other Parameters

#### Date Bands with Grid Resolution

```bash
# Show historical patterns at different resolutions
GET /EasyMap?tvk=NHMSYS0000458183&gd=50km
  &b0from=1900-01-01&b0to=1950-12-31&b0fill=FF0000
  &b1from=1951-01-01&b1to=2000-12-31&b1fill=00FF00
  &b2from=2001-01-01&b2to=2023-12-31&b2fill=0000FF
```

#### Date Bands with Specific Datasets

```bash
# Compare different survey periods in specific datasets
GET /EasyMap?tvk=NHMSYS0000458183&ds=ds123
  &b0from=1980-01-01&b0to=1990-12-31&b0fill=FF0000
  &b1from=2000-01-01&b1to=2010-12-31&b1fill=00FF00
  &b2from=2020-01-01&b2to=2023-12-31&b2fill=0000FF
```

### Date Band Examples by Use Case

#### Climate Change Studies

```bash
# Pre- and post-climate change periods
GET /EasyMap?tvk=NHMSYS0000458183
  &b0from=1960-01-01&b0to=1989-12-31&b0fill=0066CC
  &b1from=1990-01-01&b1to=2023-12-31&b1fill=CC3300
```

#### Species Recovery Programs

```bash
# Conservation timeline
GET /EasyMap?tvk=NHMSYS0000458183
  &b0from=1970-01-01&b0to=1989-12-31&b0fill=FF0000
  &b1from=1990-01-01&b1to=2009-12-31&b1fill=FFAA00
  &b2from=2010-01-01&b2to=2023-12-31&b2fill=00AA00
```

#### Survey Effort Analysis

```bash
# Different atlas periods
GET /EasyMap?tvk=NHMSYS0000458183
  &b0from=1968-01-01&b0to=1972-12-31&b0fill=8B4513
  &b1from=1988-01-01&b1to=1991-12-31&b1fill=FF8C00
  &b2from=2007-01-01&b2to=2011-12-31&b2fill=32CD32
```

---

## Legacy EasyMap Compatibility

### Parameter Mapping

The service maintains compatibility with the original NBN Gateway EasyMap parameters:

| Legacy Parameter | Current Parameter | Notes |
|------------------|-------------------|-------|
| `tvk` | `tvk` | Unchanged |
| `w` | `w` | Unchanged |
| `h` | `h` | Unchanged |
| `gd` | `gd` or `res` | Both supported |
| `ds` | `ds` | Unchanged |
| `style` | `style` | Enhanced options |
| `zoom` | `zoom` | Unchanged |

### URL Format Compatibility

```bash
# Original EasyMap format (still supported)
https://easymap.nbnatlas.org/EasyMap?tvk=NHMSYS0000458183&w=800&gd=10km

# Image export format
https://easymap.nbnatlas.org/Image?tvk=NHMSYS0000458183&w=800&gd=10km

# New NBN Hub format
https://nbn-hub.nbnatlas.org/EasyMap?tvk=NHMSYS0000458183&w=800&gd=10km
```

### Migration Notes

#### Grid Resolution Parameter Issue (`gd` vs `res`)

**Issue**: URLs using the `gd` parameter for grid resolution are not properly handled by the legacy EasyMap_Shim service. This causes unexpected behavior where large grid sizes (e.g., `gd=100km`) display as fine resolution instead.

**Root Cause**:
- The EasyMap_Shim service (`nbn/EasyMap_Shim/server.py`) expects a `res` parameter for grid resolution, not `gd`
- When `gd` is used instead of `res`, the service doesn't recognize it and defaults to `10km` resolution
- This causes URLs like `https://easymap.nbnatlas.org/Image?tvk=NHMSYS0000875492&gd=100km&...` to display with 10km grid resolution instead of the expected 100km ( see https://www.hbrg.org.uk/MainPages/NBNMaps/MapsBWA.html)

**Code Location**:
```python
# In server.py line 163-164
res = self.get_argument('res',default='').lower()
if not (res=='50km' or res=='10km' or res=='2km' or res=='1km' or res=='100m'): res='10km'
```

**Expected Behavior**:
- `gd=100km` should display large grid squares (100km resolution)
- `gd=10km` should display smaller grid squares (10km resolution)

**Actual Behavior**:
- Both `gd=100km` and `gd=10km` display the same 10km resolution because `gd` parameter is ignored

**Testing**:
- Verify `res=100km` works correctly
- Verify `gd=100km` works after fix (if implementing backward compatibility)
- Test that cache keys properly differentiate between different grid resolutions

---

## Usage Examples

### Basic Species Distribution Map

```bash
# Simple distribution map
GET /EasyMap?tvk=NHMSYS0000458183&w=800
```

### High-Resolution Map with Date Bands

```bash
# Detailed map showing temporal patterns
GET /EasyMap?tvk=NHMSYS0000458183&w=800&retina=2&gd=2km
  &b0from=1900-01-01&b0to=1950-12-31&b0fill=FF0000
  &b1from=1951-01-01&b1to=2000-12-31&b1fill=00FF00
  &b2from=2001-01-01&b2to=2023-12-31&b2fill=0000FF
```

### Regional Focus with Dataset Filter

```bash
# Scotland-focused map with specific datasets
GET /EasyMap?tvk=NHMSYS0000458183&w=600&h=400
  &zoom=scotland
  &ds=ds123,ds456
  &bg=VC
```

### Vice-County Focus with Grid Reference Bounds

```bash
# Surrey (VC 17) with 10km grid resolution
GET /EasyMap?tvk=NHMSYS0000458183&vc=17&gd=10km

# Custom grid reference area with high resolution
GET /EasyMap?tvk=NHMSYS0000458183&bl=TQ123456&tr=TQ789012&gd=1km
```

### JSON Data Export

```bash
# Get raw data for custom visualization
GET /EasyMap.json?tvk=NHMSYS0000458183
  &b0from=2020-01-01&b0to=2023-12-31
```

### Complex Example with Multiple Parameters

```bash
# Comprehensive example showing conservation timeline in specific area
GET /EasyMap?tvk=NHMSYS0000458183
  &w=800&h=600&retina=2
  &zoom=highland
  &gd=2km
  &ds=ds123,ds456
  &b0from=1970-01-01&b0to=1989-12-31&b0fill=FF0000
  &b1from=1990-01-01&b1to=2009-12-31&b1fill=FFAA00
  &b2from=2010-01-01&b2to=2023-12-31&b2fill=00AA00
  &cachedays=7
```

---

## Configuration

### Environment Variables

```properties
# Mock data configuration
use.mock.data=false

# Service endpoints
biocache.baseUrl=https://records-ws.nbnatlas.org
bie.baseUrl=https://species-ws.nbnatlas.org

# Download URLs
download.url=https://records.nbnatlas.org/occurrences/download
download.doi.url=https://records.nbnatlas.org/occurrences/download
```

### Mock Data Toggle

The system supports a mock data mode for development and testing:

```properties
use.mock.data=true
```

When enabled, returns predefined data for any TVK:
- Species: House Sparrow (*Passer domesticus*)
- Occurrences: 10 sample records across the UK

---

## Data Flow

### 1. Request Processing

```
User Request → Controller → Parameter Validation → Service Call
```

### 2. Data Retrieval

```
Service → BIE API (Species Info) → Biocache API (Occurrences) → Data Processing
```

### 3. Response Generation

```
Processed Data → Map Configuration → View Rendering → HTTP Response
```

### 4. Error Handling

```
Exception → Fallback to Mock Data → Error Response (if mock fails)
```

---

## Testing

### Unit Tests Coverage

- **Service Tests**: 9 test methods covering core functionality
- **Controller Tests**: 10 test methods covering validation and endpoints
- **Mock Data Tests**: Ensure fallback functionality works
- **Integration Tests**: End-to-end workflow validation

### Running Tests

```bash
# Run all EasyMap tests
./gradlew test --tests="*EasyMap*"

# Run all tests
./gradlew test

# Run with verbose output
./gradlew test --tests="*EasyMap*" --info
```

### Test Coverage Areas

- ✅ TVK validation (various formats)
- ✅ Species information retrieval
- ✅ Occurrence data processing
- ✅ Map configuration calculation
- ✅ Statistics generation
- ✅ Error handling
- ✅ Mock data fallback
- ✅ Controller endpoints

---
