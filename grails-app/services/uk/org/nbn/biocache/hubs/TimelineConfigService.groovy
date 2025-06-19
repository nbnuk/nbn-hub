package uk.org.nbn.biocache.hubs

import grails.core.GrailsApplication
import groovy.util.logging.Slf4j
import org.yaml.snakeyaml.Yaml

/**
 * Service for managing timeline configuration
 * Reads from timeline-config.yml and provides configuration values
 * This was introduced to retain functionality of the advanced timeline
 * but it is not used in the new simple timeline component.
 */
@Slf4j
class TimelineConfigService {

    GrailsApplication grailsApplication

    // Cache the parsed configuration
    private Map cachedConfig = null
    private long lastModified = 0

    /**
     * Get the complete timeline configuration
     * @return Map containing all timeline configuration
     */
    Map getTimelineConfig() {
        loadConfigIfNeeded()
        return cachedConfig ?: getDefaultConfig()
    }

    /**
     * Get the UI mode (simple or advanced)
     * @return String indicating the UI mode
     */
    String getUiMode() {
        def config = getTimelineConfig()
        def environment = grailsApplication.config.grails.env ?: 'production'

        // Check environment-specific override first
        def envConfig = config.timeline?.environments?."${environment}"
        if (envConfig?.ui?.mode) {
            return envConfig.ui.mode
        }

        // Fall back to general UI mode
        return config.timeline?.ui?.mode ?: 'simple'
    }

    /**
     * Get simple timeline configuration
     * @return Map containing simple timeline config
     */
    Map getSimpleConfig() {
        def config = getTimelineConfig()
        return config.timeline?.simple ?: getDefaultSimpleConfig()
    }

    /**
     * Get advanced timeline configuration
     * @return Map containing advanced timeline config
     */
    Map getAdvancedConfig() {
        def config = getTimelineConfig()
        return config.timeline?.advanced ?: getDefaultAdvancedConfig()
    }

    /**
     * Get default values configuration
     * @return Map containing default values
     */
    Map getDefaults() {
        def config = getTimelineConfig()
        return config.timeline?.defaults ?: getDefaultDefaults()
    }

    /**
     * Get the default timeline type (year or month)
     * @return String indicating the default timeline type
     */
    String getDefaultTimelineType() {
        def defaults = getDefaults()
        return defaults.timelineType ?: 'month'  // Default to month-based as requested
    }

    /**
     * Get month-based timeline configuration
     * @return Map containing month-based configuration
     */
    Map getMonthBasedConfig() {
        def config = getTimelineConfig()
        def advanced = getAdvancedConfig()
        return advanced.monthBased ?: getDefaultMonthBasedConfig()
    }

    /**
     * Check if month-based timeline is enabled
     * @return Boolean indicating if month-based timeline is enabled
     */
    boolean isMonthBasedEnabled() {
        def features = getFeatures()
        return features.enableMonthBasedTimeline ?: true
    }

    /**
     * Check if the system should default to month-based timeline
     * @return Boolean indicating if month-based should be default
     */
    boolean shouldDefaultToMonthBased() {
        def features = getFeatures()
        return features.defaultToMonthBased ?: true
    }

    /**
     * Check if timeline type switching is enabled
     * @return Boolean indicating if users can switch between year/month modes
     */
    boolean isTimelineTypeSwitchingEnabled() {
        def features = getFeatures()
        return features.enableMonthTypeSwitching ?: true
    }

    /**
     * Get feature flags
     * @return Map containing feature flags
     */
    Map getFeatures() {
        def config = getTimelineConfig()
        def environment = grailsApplication.config.grails.env ?: 'production'

        // Check environment-specific override first
        def envConfig = config.timeline?.environments?."${environment}"
        if (envConfig?.features) {
            return envConfig.features
        }

        // Fall back to general features
        return config.timeline?.features ?: getDefaultFeatures()
    }

    /**
     * Get styling configuration
     * @return Map containing styling config
     */
    Map getStyling() {
        def config = getTimelineConfig()
        return config.timeline?.styling ?: getDefaultStyling()
    }

    /**
     * Check if simple mode is enabled
     * @return Boolean indicating if simple mode is enabled
     */
    boolean isSimpleModeEnabled() {
        def features = getFeatures()
        return features.enableSimpleMode ?: true
    }

    /**
     * Check if advanced mode is enabled
     * @return Boolean indicating if advanced mode is enabled
     */
    boolean isAdvancedModeEnabled() {
        def features = getFeatures()
        return features.enableAdvancedMode ?: false
    }

    /**
     * Get configuration as JSON for frontend
     * @return String JSON representation of frontend config
     */
    String getConfigAsJson() {
        def frontendConfig = [
            ui: [
                mode: getUiMode()
            ],
            simple: getSimpleConfig(),
            advanced: getAdvancedConfig(),
            defaults: getDefaults(),
            features: getFeatures(),
            styling: getStyling()
        ]

        return groovy.json.JsonBuilder(frontendConfig).toString()
    }

    // Private methods

        private void loadConfigIfNeeded() {
        try {
            def configResource = grailsApplication.mainContext.getResource('classpath:timeline-config.yml')
            if (!configResource.exists()) {
                log.debug("Timeline config file not found, using defaults")
                cachedConfig = null
                return
            }

            def configFile = configResource.file
            if (cachedConfig == null || configFile.lastModified() > lastModified) {
                log.info("Loading timeline configuration from: ${configFile.path}")
                def yaml = new Yaml()
                cachedConfig = yaml.load(configFile.text)
                lastModified = configFile.lastModified()
                log.debug("Timeline configuration loaded successfully")
            }
        } catch (Exception e) {
            log.warn("Error loading timeline configuration, using defaults: ${e.message}")
            cachedConfig = null
        }
    }

    private Map getDefaultConfig() {
        return [
            timeline: [
                ui: [
                    mode: 'simple',
                    theme: 'nbn'
                ],
                simple: getDefaultSimpleConfig(),
                advanced: getDefaultAdvancedConfig(),
                defaults: getDefaultDefaults(),
                features: getDefaultFeatures(),
                styling: getDefaultStyling()
            ]
        ]
    }

    private Map getDefaultSimpleConfig() {
        return [
            title: 'Explore changes over time',
            subtitle: 'Enter a time period to view changes on the map. Press play to view a timeframe to present day.',
            labels: [
                from: 'From',
                to: 'To',
                button: 'View on map'
            ],
            placeholders: [
                startYear: '1977',
                endYear: '2024'
            ],
            validation: [
                minYear: 1800,
                maxYear: 2024,
                showValidationMessages: true
            ]
        ]
    }

    private Map getDefaultAdvancedConfig() {
        return [
            showPlaybackControls: true,
            showSpeedControl: true,
            showGranularityControl: true,
            showSlider: true,
            showTimeline: true
        ]
    }

    private Map getDefaultDefaults() {
        return [
            playbackSpeed: 1000,
            granularity: 'month',        // Default to month-based
            timelineType: 'month',       // Default to month-based timeline
            autoPlay: false,
            minYear: 1800,
            maxYear: 2024,
            monthStepSize: 1,            // Default month step size
            yearStepSize: 1,             // Default year step size
            monthRange: [1, 12]          // Default month range (Jan-Dec)
        ]
    }

    private Map getDefaultFeatures() {
        return [
            enableSimpleMode: true,
            enableAdvancedMode: false,
            enablePlayback: false,
            enableSpeedControl: false,
            enableGranularity: false,
            enableMonthBasedTimeline: true,    // Enable month-based timeline
            enableMonthTypeSwitching: true,    // Allow switching between year/month
            defaultToMonthBased: true          // Default to month-based behavior
        ]
    }

    private Map getDefaultStyling() {
        return [
            colors: [
                primary: '#3b82f6',
                secondary: '#111827',
                success: '#16a34a',
                error: '#dc2626',
                text: '#111827',
                textSecondary: '#6b7280'
            ],
            fonts: [
                family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
                sizes: [
                    title: '16px',
                    subtitle: '13px',
                    label: '12px',
                    input: '14px',
                    button: '14px'
                ]
            ],
            spacing: [
                panel: '20px',
                inputs: '12px',
                elements: '8px'
            ],
            borders: [
                radius: '6px',
                width: '1px',
                color: '#e1e5e9'
            ]
        ]
    }

    private Map getDefaultMonthBasedConfig() {
        return [
            enabled: true,
            defaultType: 'month',
            allowTypeSwitching: true,
            monthStepSize: 1,
            maxMonthStepSize: 12
        ]
    }
}
