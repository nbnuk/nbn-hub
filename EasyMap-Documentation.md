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
8. [Display Controls](#display-controls)
9. [Legacy EasyMap Compatibility](#legacy-easymap-compatibility)
10. [Usage Examples](#usage-examples)
11. [Configuration](#configuration)
12. [Data Flow](#data-flow)
13. [Testing](#testing)
14. [Refactoring Guidelines](#refactoring-guidelines)
15. [Migration Checklist](#migration-checklist)

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

### Display Control Parameters

Along with the map the service returns a title containing the species name and link to terms and conditions, acknowledgement list of data providers, link to NBN Gateway interactive map and NBN Gateway logo. You can supress or show these using the following:


| Parameter | Type | Description | Default | Example |
|-----------|------|-------------|---------|---------|
| `title` | String | Title display mode: `sci` (scientific name), `com` (common name), or `0` (no title) | `sci` | `com`, `0` |
| `terms` | String | Set to `0` to disable terms and conditions link and text | Shows terms | `0` |
| `link` | String | Set to `0` to disable link to NBN Gateway interactive map | Shows link | `0` |
| `ref` | String | Set to `0` to disable list of datasets | Shows dataset list | `0` |
| `logo` | String | Set to `0` to disable NBN Gateway logo | Shows logo | `0` |
| `maponly` | String | Set to `1` to display map only without any surrounding content | Shows full layout | `1` |
| `css` | String | Custom CSS file URL for styling | Default styling | `https://example.com/custom.css` |

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

## Display Controls

The EasyMap service provides comprehensive display control parameters that allow you to customize which elements appear on the species occurrence map. These parameters give you precise control over the map's appearance and comply with the [NBN Atlas EasyMap specification](https://easymap.nbnatlas.org/easymap.html).

### Overview of Display Elements

By default, the EasyMap service returns:
- **Title** with species name (scientific or common)
- **Terms and conditions** link and explanatory text
- **Interactive map** with occurrence data visualization
- **Link** to NBN Gateway interactive map
- **Dataset acknowledgement list** (when dataset filtering is applied)
- **NBN Gateway logo**

### Title Display Control

#### Controlling Title Display

```bash
# Show scientific name (default)
GET /EasyMap?tvk=NHMSYS0000458183&title=sci

# Show common name
GET /EasyMap?tvk=NHMSYS0000458183&title=com

# Hide title completely
GET /EasyMap?tvk=NHMSYS0000458183&title=0
```

#### Title Behavior
- **`title=sci`**: Displays the scientific name (default behavior)
- **`title=com`**: Displays the common name if available, otherwise falls back to scientific name
- **`title=0`**: Hides the title completely

### Terms and Conditions Control

#### Usage

```bash
# Show terms and conditions (default)
GET /EasyMap?tvk=NHMSYS0000458183

# Hide terms and conditions
GET /EasyMap?tvk=NHMSYS0000458183&terms=0
```

#### Default Terms Text
When displayed, the terms section shows:
> "The National Biodiversity Network records are shown on the map below. (See [terms and conditions](https://nbnatlas.org/help/nbn-atlas-terms-use/))"

### Interactive Map Link Control

#### Usage

```bash
# Show link to interactive map (default)
GET /EasyMap?tvk=NHMSYS0000458183

# Hide interactive map link
GET /EasyMap?tvk=NHMSYS0000458183&link=0
```

#### Link Behavior
The interactive map link opens in a new window and preserves:
- Species filter (TVK)
- Dataset filters (if specified)
- Direct link to NBN Atlas occurrence search

### Dataset Reference List Control

#### Usage

```bash
# Show dataset list when filtering (default)
GET /EasyMap?tvk=NHMSYS0000458183&ds=ds123,ds456

# Hide dataset list even when filtering
GET /EasyMap?tvk=NHMSYS0000458183&ds=ds123,ds456&ref=0
```

#### Behavior
- **Shows by default** when dataset filtering (`ds` parameter) is applied
- **Hidden by default** when no dataset filtering is specified
- **`ref=0`** always hides the list regardless of dataset filtering

### NBN Gateway Logo Control

#### Usage

```bash
# Show NBN Gateway logo (default)
GET /EasyMap?tvk=NHMSYS0000458183

# Hide NBN Gateway logo
GET /EasyMap?tvk=NHMSYS0000458183&logo=0
```

#### Logo Specifications
- Links to https://nbnatlas.org/
- Opens in a new window
- Uses NBN Atlas branding
- Maximum height: 40px

### Map-Only Display Mode

#### Usage

```bash
# Show full layout with surrounding content (default)
GET /EasyMap?tvk=NHMSYS0000458183

# Show only the map
GET /EasyMap?tvk=NHMSYS0000458183&maponly=1
```

#### Map-Only Mode Features
- **Removes all surrounding content**: title, terms, links, logos, dataset lists
- **Optimizes layout**: body dimensions match map dimensions
- **Removes overflow**: sets `overflow: hidden` for clean embedding
- **Maintains interactivity**: map functionality remains fully functional

### Compliance Requirements

#### Terms of Use Compliance
According to the [NBN Atlas EasyMap specification](https://easymap.nbnatlas.org/easymap.html):

> "To comply with the terms of use of this service the link to the terms and conditions, acknowledgement list of data providers and NBN Gateway logo must be displayed on your site. However they can be turned off if you prefer to include them elsewhere on your site or are restricting the map to just your datasets and do not wish to include the acknowledgement list of data providers."

#### Recommended Compliance Approaches

1. **Default Usage** (fully compliant):
```bash
GET /EasyMap?tvk=NHMSYS0000458183
```

2. **Custom site integration** (compliant if terms are shown elsewhere):
```bash
GET /EasyMap?tvk=NHMSYS0000458183&terms=0&logo=0&ref=0
# Terms, logo, and attribution must be displayed elsewhere on your site
```

3. **Private/restricted datasets** (compliant for own data):
```bash
GET /EasyMap?tvk=NHMSYS0000458183&ds=your-dataset&ref=0
# For maps restricted to your own datasets only
```

### Combining Display Parameters

#### Common Combinations

```bash
# Minimal embedded map (requires compliance elsewhere)
GET /EasyMap?tvk=NHMSYS0000458183&terms=0&link=0&ref=0&logo=0

# Map-only for iframe embedding
GET /EasyMap?tvk=NHMSYS0000458183&maponly=1&w=800&h=600

# Custom title with selective elements
GET /EasyMap?tvk=NHMSYS0000458183&title=com&terms=0&logo=0

# Clean map with just essential elements
GET /EasyMap?tvk=NHMSYS0000458183&title=com&ref=0&logo=0
```

#### Complex Example

```bash
# Comprehensive customization for conservation report
GET /EasyMap?tvk=NHMSYS0000458183
  &title=com                    # Use common name
  &w=800&h=600                  # Set dimensions
  &ds=conservation-survey       # Filter to specific dataset
  &ref=0                        # Hide dataset list (shown in report text)
  &terms=0                      # Hide terms (included in report footer)
  &logo=0                       # Hide logo (report has NBN branding)
  &b0from=1990-01-01&b0to=2000-12-31&b0fill=FF0000  # Historical data
  &b1from=2010-01-01&b1to=2023-12-31&b1fill=00FF00  # Recent data
```

### Custom CSS Styling

To change the appearance and layout of the text returned by the service, the full path to your Cascading Style Sheet can be included in the query string. For example

#### Usage

```bash
# Apply custom CSS styling
GET /EasyMap?tvk=NHMSYS0000458183&css=https://example.com/custom-easymap.css
```

#### CSS Customization Options
The custom CSS file can override default styles for:
- Title fonts and colors
- Terms and conditions text
- Link appearance
- Logo positioning
- Map container styling
- Background colors

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

### Display Control Examples

```bash
# Map with common name title and no logo
GET /EasyMap?tvk=NHMSYS0000458183&title=com&logo=0

# Map-only view for embedding
GET /EasyMap?tvk=NHMSYS0000458183&maponly=1&w=800&h=600

# Clean map without terms and dataset references
GET /EasyMap?tvk=NHMSYS0000458183&terms=0&ref=0&link=0

# Minimal embedded map (ensure compliance elsewhere on site)
GET /EasyMap?tvk=NHMSYS0000458183&terms=0&link=0&ref=0&logo=0&title=0
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
  &title=com                    # Use common name
  &terms=0                      # Hide terms (included elsewhere)
  &ref=0                        # Hide dataset list (shown in text)
  &b0from=1970-01-01&b0to=1989-12-31&b0fill=FF0000
  &b1from=1990-01-01&b1to=2009-12-31&b1fill=FFAA00
  &b2from=2010-01-01&b2to=2023-12-31&b1fill=00AA00
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

### EasyMap Configuration
4. `easymap.defaultBounds` - Default map bounds
5. `easymap.defaultZoom` - Default zoom level (Integer, default: 6)
6. `easymap.defaultLatitude` - Default map latitude (Double, default: 54.5)
7. `easymap.defaultLongitude` - Default map longitude (Double, default: -3.0)

### Tile Layer Configuration
8. `easymap.tileLayer.minimal.url` - URL for minimal tile layer
9. `easymap.tileLayer.minimal.attribution` - Attribution text for minimal tile layer
10. `easymap.tileLayer.minimal.subdomains` - Subdomains for minimal tile layer
11. `easymap.tileLayer.minimal.maxZoom` - Maximum zoom for minimal tile layer
12. `easymap.tileLayer.osm.url` - URL for OpenStreetMap tile layer
13. `easymap.tileLayer.osm.attribution` - Attribution text for OSM tile layer
14. `easymap.tileLayer.osm.maxZoom` - Maximum zoom for OSM tile layer

### Grid Configuration
15. `easymap.grid.defaultColor` - Default grid color (default: 'df4a21')
16. `easymap.grid.opacity` - Grid opacity (default: '0.8')
17. `easymap.grid.layers` - Grid layers configuration (default: 'ALA:occurrences')
18. `easymap.grid.format` - Grid format (default: 'image/png')
19. `easymap.grid.colourMode` - Grid color mode (default: 'osgrid')
20. `easymap.grid.gridLabels` - Grid labels setting (default: 'false')

### Biocache Configuration
21. `easymap.biocache.fallbackUrl` - Fallback URL for biocache services

### NBN Atlas Layers Service Configuration
22. `nbnatlas.layers.baseUrl` - Base URL for NBN Atlas layers service (default: 'https://layers.nbnatlas.org/ws')

### Layer IDs
23. `layer.uk_countries` - Layer ID for UK countries (default: 'cl2')
24. `layer.vice_county` - Layer ID for vice counties (default: 'cl254')

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
- **Controller Tests**: 25+ test methods covering validation and endpoints
- **Display Parameter Tests**: Comprehensive coverage of all display controls
- **Mock Data Tests**: Ensure fallback functionality works
- **Integration Tests**: End-to-end workflow validation

### Running Tests

```bash
# Run all EasyMap tests
./gradlew test --tests="*EasyMap*"

# Run specific display parameter tests
./gradlew test --tests="*EasyMapControllerSpec*display*"

# Run all tests
./gradlew test

# Run with verbose output
./gradlew test --tests="*EasyMap*" --info
```

### Test Coverage Areas

#### Core Functionality
- ✅ TVK validation (various formats)
- ✅ Species information retrieval
- ✅ Occurrence data processing
- ✅ Map configuration calculation
- ✅ Statistics generation
- ✅ Error handling
- ✅ Mock data fallback
- ✅ Controller endpoints

#### Display Parameter Testing
- ✅ **Title parameter**: `sci`, `com`, `0` values and validation
- ✅ **Boolean parameters**: `terms`, `link`, `ref`, `logo`, `maponly`
  - Valid values: `0`, `1`, `null` (omitted)
  - Invalid values: proper error handling for `yes`, `no`, `true`, `false`, etc.
- ✅ **Combined parameters**: Multiple display controls working together
- ✅ **Map-only mode**: Specific behavior validation for `maponly=1`
- ✅ **CSS parameter**: Custom styling support

#### Parameter Validation Tests
```groovy
// Example test cases covered:
"test easyMap with valid boolean display parameters: terms=0" ✅
"test easyMap with valid boolean display parameters: link=1" ✅
"test easyMap with valid boolean display parameters: ref=null" ✅
"test easyMap with invalid boolean display parameters: logo=true" ✅
"test easyMap with multiple display parameters combined" ✅
```

### Testing Notes

- Tests use Spock framework for behavior-driven testing
- Mock services simulate external API dependencies
- Parameter validation ensures proper error responses (400 status codes)
- Display parameter tests verify controller logic without requiring full service integration
- Tests cover edge cases like null values and invalid parameter combinations

---
