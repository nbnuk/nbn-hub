# EasyMap Unit Tests

This directory contains unit tests for the EasyMap functionality in the NBN Hub application.

## Test Files

### EasyMapServiceSpec.groovy
Unit tests for the `EasyMapService` class, covering:

- **Mock Data Tests**: Tests that verify mock data functionality when external services are unavailable
  - `getSpeciesInfo()` with mock data returns House Sparrow data
  - `getOccurrenceData()` with mock data returns 10 sample occurrences across the UK

- **Map Configuration Tests**: Tests for map bounds and zoom level calculation
  - Calculates correct bounds from occurrence coordinates
  - Returns UK defaults when no occurrences are provided
  - Calculates appropriate zoom levels based on coordinate spread

- **Statistics Tests**: Tests for occurrence data statistics
  - Groups occurrences by basis of record, year, and data provider
  - Handles empty and null data gracefully

### EasyMapControllerSpec.groovy
Unit tests for the `EasyMapController` class, covering:

- **TVK Validation Tests**: Tests for the `isValidTVK()` method
  - Accepts valid NHMSYS and NBNSYS format TVKs
  - Accepts long alphanumeric TVKs (10+ characters)
  - Rejects short, lowercase, or invalid format TVKs
  - Handles null and empty string inputs

- **Basic Controller Tests**: Verifies controller instantiation and method availability
  - Controller exists and is properly instantiated
  - Required action methods (`easyMap`, `easyMapJson`, `health`) are available

## Running the Tests

To run all EasyMap tests:
```bash
./gradlew test --tests="*EasyMap*"
```

To run all tests:
```bash
./gradlew test
```

## Test Framework

These tests use:
- **Spock Framework**: For BDD-style test specifications
- **Grails Test Mixins**: `@TestFor` annotation for unit testing
- **Mock Objects**: Spock's built-in mocking capabilities for dependencies

## Test Coverage

The tests cover:
- ✅ Core service functionality (species info, occurrence data, map config)
- ✅ Input validation (TVK format validation)
- ✅ Error handling (null/empty inputs)
- ✅ Mock data fallback functionality
- ✅ Map bounds and zoom calculation
- ✅ Statistics generation

## Notes

- Tests are designed to work with mock data to avoid dependencies on external services
- Controller tests are kept minimal due to Grails 3.x testing framework limitations
- Service tests provide comprehensive coverage of business logic
- All tests pass and are compatible with the existing Grails 3.x test infrastructure
