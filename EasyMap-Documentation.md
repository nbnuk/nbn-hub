# EasyMap Functionality Documentation

## Overview

The EasyMap functionality provides NBN Atlas-compatible species distribution mapping endpoints for the NBN Hub application. It offers both HTML and JSON responses for displaying species occurrence data on interactive maps, compatible with the existing NBN Atlas EasyMap API.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Components](#components)
3. [API Endpoints](#api-endpoints)
4. [Configuration](#configuration)
5. [Data Flow](#data-flow)
6. [Testing](#testing)
7. [Refactoring Guidelines](#refactoring-guidelines)
8. [Migration Checklist](#migration-checklist)

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

### Design Principles

- **SOLID Principles**: Single responsibility, dependency injection, interface segregation
- **DRY**: Reusable service methods and configuration
- **KISS**: Simple, straightforward implementation
- **YAGNI**: Only implemented required features
- **OWASP**: Input validation, secure parameter handling

---

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

## Refactoring Guidelines

### Creating a New Grails Project

#### 1. Project Setup

```bash
# Create new Grails project
grails create-app easymap-service --profile=web

# Navigate to project
cd easymap-service
```

#### 2. Dependencies

Add to `build.gradle`:

```groovy
dependencies {
    // Core Grails dependencies
    compile "org.springframework.boot:spring-boot-starter-logging"
    compile "org.springframework.boot:spring-boot-autoconfigure"
    compile "org.grails:grails-core"
    compile "org.grails:grails-web-boot"

    // HTTP client for external APIs
    compile "org.apache.httpcomponents:httpclient:4.5.6"

    // JSON processing
    compile "org.grails:grails-plugin-converters"

    // Testing
    testCompile "org.grails:grails-plugin-testing"
    testCompile "org.spockframework:spock-core"
}
```

#### 3. Configuration Structure

**application.yml**:
```yaml
grails:
    profile: web
    codegen:
        defaultPackage: uk.org.nbn.easymap

easymap:
    services:
        biocache:
            baseUrl: "https://records-ws.nbnatlas.org"
        bie:
            baseUrl: "https://species-ws.nbnatlas.org"

    mock:
        enabled: false

    cache:
        defaultDays: 30

    map:
        defaults:
            latitude: 54.5
            longitude: -3.0
            zoom: 6
            width: 800
            height: 600
```

### File Migration Strategy

#### 1. Core Components

**Controllers**:
```
src/
├── grails-app/
│   ├── controllers/
│   │   └── uk/org/nbn/easymap/
│   │       └── EasyMapController.groovy
```

**Services**:
```
src/
├── grails-app/
│   ├── services/
│   │   └── uk/org/nbn/easymap/
│   │       ├── EasyMapService.groovy
│   │       └── WebServicesService.groovy
```

**Views**:
```
src/
├── grails-app/
│   ├── views/
│   │   └── easyMap/
│   │       ├── map.gsp
│   │       ├── error.gsp
│   │       └── notFound.gsp
```

#### 2. Configuration Files

**URL Mappings** (`grails-app/controllers/UrlMappings.groovy`):
```groovy
class UrlMappings {
    static mappings = {
        // EasyMap API endpoints
        "/api/easymap"(controller: 'easyMap', action: 'easyMap')
        "/api/easymap.json"(controller: 'easyMap', action: 'easyMapJson')
        "/api/easymap/health"(controller: 'easyMap', action: 'health')

        // Legacy NBN Atlas compatibility
        "/EasyMap"(controller: 'easyMap', action: 'easyMap')
        "/EasyMap.json"(controller: 'easyMap', action: 'easyMapJson')

        // Error pages
        "500"(view: '/error')
        "404"(view: '/notFound')
    }
}
```

#### 3. Test Migration

**Test Structure**:
```
src/
├── test/
│   └── groovy/
│       └── uk/org/nbn/easymap/
│           ├── EasyMapServiceSpec.groovy
│           ├── EasyMapControllerSpec.groovy
│           └── integration/
│               └── EasyMapIntegrationSpec.groovy
```

### Refactoring Improvements

#### 1. Enhanced Configuration Management

Create a dedicated configuration service:

```groovy
@Service
class EasyMapConfigService {

    @Value('${easymap.services.biocache.baseUrl}')
    String biocacheBaseUrl

    @Value('${easymap.services.bie.baseUrl}')
    String bieBaseUrl

    @Value('${easymap.mock.enabled:false}')
    Boolean mockEnabled

    @Value('${easymap.cache.defaultDays:30}')
    Integer defaultCacheDays

    Map getMapDefaults() {
        return [
            latitude: grailsApplication.config.getProperty('easymap.map.defaults.latitude', Double, 54.5),
            longitude: grailsApplication.config.getProperty('easymap.map.defaults.longitude', Double, -3.0),
            zoom: grailsApplication.config.getProperty('easymap.map.defaults.zoom', Integer, 6),
            width: grailsApplication.config.getProperty('easymap.map.defaults.width', Integer, 800),
            height: grailsApplication.config.getProperty('easymap.map.defaults.height', Integer, 600)
        ]
    }
}
```

#### 2. Enhanced Error Handling

Create custom exception classes:

```groovy
class EasyMapException extends RuntimeException {
    EasyMapException(String message) { super(message) }
    EasyMapException(String message, Throwable cause) { super(message, cause) }
}

class InvalidTVKException extends EasyMapException {
    InvalidTVKException(String tvk) {
        super("Invalid TVK format: ${tvk}")
    }
}

class SpeciesNotFoundException extends EasyMapException {
    SpeciesNotFoundException(String tvk) {
        super("Species not found for TVK: ${tvk}")
    }
}
```

#### 3. Enhanced Caching

Add caching annotations:

```groovy
@Service
class EasyMapService {

    @Cacheable(value = "speciesInfo", key = "#tvk")
    Map getSpeciesInfo(String tvk) {
        // Implementation
    }

    @Cacheable(value = "occurrenceData", key = "#tvk")
    List getOccurrenceData(String tvk) {
        // Implementation
    }
}
```

#### 4. API Versioning

Support multiple API versions:

```groovy
class UrlMappings {
    static mappings = {
        // Version 1 API
        "/api/v1/easymap"(controller: 'easyMap', action: 'easyMap')
        "/api/v1/easymap.json"(controller: 'easyMap', action: 'easyMapJson')

        // Version 2 API (future)
        "/api/v2/easymap"(controller: 'easyMapV2', action: 'easyMap')

        // Default to latest version
        "/api/easymap"(controller: 'easyMap', action: 'easyMap')
    }
}
```

#### 5. Enhanced Validation

Create validation service:

```groovy
@Service
class ValidationService {

    boolean isValidTVK(String tvk) {
        if (!tvk) return false
        return tvk.matches(/^[A-Z0-9]{10,}$/)
    }

    boolean isValidCoordinate(Double lat, Double lng) {
        return lat != null && lng != null &&
               lat >= -90 && lat <= 90 &&
               lng >= -180 && lng <= 180
    }

    Map validateParameters(Map params) {
        Map errors = [:]

        if (!isValidTVK(params.tvk)) {
            errors.tvk = "Invalid TVK format"
        }

        if (params.w && !params.w.isInteger()) {
            errors.width = "Width must be an integer"
        }

        return errors
    }
}
```

---

## Migration Checklist

### Pre-Migration

- [ ] **Backup current implementation**
- [ ] **Document current configuration**
- [ ] **Export test data and expected results**
- [ ] **Review dependencies and versions**

### Project Setup

- [ ] **Create new Grails project**
- [ ] **Configure build.gradle dependencies**
- [ ] **Set up application.yml configuration**
- [ ] **Configure logging**

### Code Migration

- [ ] **Migrate EasyMapController**
  - [ ] Update package declarations
  - [ ] Update dependency injection
  - [ ] Update configuration references

- [ ] **Migrate EasyMapService**
  - [ ] Update package declarations
  - [ ] Update configuration access
  - [ ] Update external service calls

- [ ] **Migrate Views**
  - [ ] Copy GSP templates
  - [ ] Update asset references
  - [ ] Update JavaScript/CSS paths

- [ ] **Migrate URL Mappings**
  - [ ] Update controller references
  - [ ] Add API versioning if needed

- [ ] **Migrate Configuration**
  - [ ] Convert to application.yml format
  - [ ] Update property names if needed
  - [ ] Add environment-specific configs

### Testing Migration

- [ ] **Migrate Unit Tests**
  - [ ] Update package references
  - [ ] Update mock configurations
  - [ ] Verify test coverage

- [ ] **Create Integration Tests**
  - [ ] End-to-end API testing
  - [ ] External service integration
  - [ ] Performance testing

- [ ] **Validate Test Results**
  - [ ] Compare with original test results
  - [ ] Verify mock data functionality
  - [ ] Test error scenarios

### Deployment Preparation

- [ ] **Environment Configuration**
  - [ ] Development environment setup
  - [ ] Staging environment setup
  - [ ] Production environment setup

- [ ] **Documentation**
  - [ ] API documentation
  - [ ] Deployment guide
  - [ ] Configuration guide

- [ ] **Monitoring Setup**
  - [ ] Health check endpoints
  - [ ] Logging configuration
  - [ ] Performance monitoring

### Post-Migration

- [ ] **Functional Testing**
  - [ ] Test all endpoints
  - [ ] Verify data accuracy
  - [ ] Test error handling

- [ ] **Performance Testing**
  - [ ] Load testing
  - [ ] Response time validation
  - [ ] Memory usage monitoring

- [ ] **Security Testing**
  - [ ] Input validation
  - [ ] XSS prevention
  - [ ] CSRF protection

- [ ] **Documentation Updates**
  - [ ] Update API documentation
  - [ ] Update deployment procedures
  - [ ] Update troubleshooting guides

### Rollback Plan

- [ ] **Backup Strategy**
  - [ ] Database backup procedures
  - [ ] Configuration backup
  - [ ] Code rollback procedures

- [ ] **Rollback Testing**
  - [ ] Test rollback procedures
  - [ ] Verify data integrity
  - [ ] Test service restoration

---

## Best Practices for New Project

### 1. **Separation of Concerns**
- Keep controllers thin (only request/response handling)
- Put business logic in services
- Use separate classes for validation
- Create dedicated configuration services

### 2. **Error Handling**
- Use custom exception classes
- Implement global exception handlers
- Provide meaningful error messages
- Log errors appropriately

### 3. **Testing Strategy**
- Maintain >80% test coverage
- Use integration tests for external APIs
- Mock external dependencies
- Test error scenarios

### 4. **Configuration Management**
- Use environment-specific configurations
- Externalize all configurable values
- Use type-safe configuration access
- Document all configuration options

### 5. **Security**
- Validate all inputs
- Use parameterized queries
- Implement rate limiting
- Add CORS headers if needed

### 6. **Performance**
- Implement caching where appropriate
- Use connection pooling for external APIs
- Monitor response times
- Optimize database queries

### 7. **Monitoring**
- Add health check endpoints
- Implement structured logging
- Add metrics collection
- Set up alerting

This documentation provides a comprehensive guide for understanding the current EasyMap implementation and successfully refactoring it into a new, standalone Grails project with improved architecture and maintainability.
