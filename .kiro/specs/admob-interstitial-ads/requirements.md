# Requirements Document: AdMob Interstitial Ads

## Introduction

This feature implements AdMob interstitial ads in the Flutter music player app. Interstitial ads are full-screen ads that appear at natural transition points in the app (e.g., when navigating between screens, after playing a song). The implementation will use the Google Mobile Ads SDK to load, manage, and display ads with proper error handling and lifecycle management.

## Glossary

- **AdService**: The service responsible for managing ad lifecycle, loading, and displaying interstitial ads
- **Interstitial Ad**: A full-screen advertisement that appears at natural breaks in app usage
- **Ad Unit ID**: A unique identifier provided by AdMob for each ad placement
- **Test Ad Unit ID**: A special AdMob-provided ID used for testing without serving real ads
- **Ad Callback**: Event handlers triggered when ads load, fail, or are dismissed
- **MusicProvider**: The provider managing music playback state and navigation
- **Navigation Event**: When a user navigates between screens (e.g., opening player, returning to home)

## Requirements

### Requirement 1: Ad Service Initialization and Lifecycle Management

**User Story:** As a developer, I want the ad service to properly initialize and manage the ad lifecycle, so that ads are loaded efficiently and don't interfere with app performance.

#### Acceptance Criteria

1. WHEN the app starts, THE AdService SHALL initialize the Google Mobile Ads SDK with proper configuration
2. WHEN an interstitial ad is dismissed or fails to load, THE AdService SHALL automatically load the next ad
3. WHEN the app is destroyed, THE AdService SHALL dispose of any active ads and clean up resources
4. WHEN an ad fails to load, THE AdService SHALL log the error and continue app operation without crashing
5. WHEN multiple ad show requests occur in quick succession, THE AdService SHALL prevent duplicate ad displays

### Requirement 2: Strategic Ad Placement and Frequency

**User Story:** As a user, I want ads to appear at natural transition points without disrupting my music experience, so that the app feels natural and not intrusive.

#### Acceptance Criteria

1. WHEN a user navigates from home screen to player screen, THE AdService MAY show an interstitial ad
2. WHEN a user returns from player screen to home screen, THE AdService MAY show an interstitial ad
3. WHEN a user skips to the next song, THE AdService SHALL NOT show an ad (to avoid disrupting playback)
4. WHEN an ad is shown, THE AdService SHALL enforce a minimum time gap before showing the next ad
5. WHEN the app is in the background, THE AdService SHALL NOT attempt to show ads

### Requirement 3: Ad Loading and Caching

**User Story:** As a developer, I want ads to be pre-loaded and cached, so that they display quickly when needed without delays.

#### Acceptance Criteria

1. WHEN the app initializes, THE AdService SHALL pre-load the first interstitial ad
2. WHEN an ad is displayed, THE AdService SHALL immediately begin loading the next ad
3. WHEN an ad fails to load, THE AdService SHALL retry loading after a reasonable delay
4. WHEN an ad is ready to display, THE AdService SHALL have it available within 500ms of the show request
5. WHEN multiple ads are queued, THE AdService SHALL maintain only one ad in memory at a time

### Requirement 4: Ad Display and User Interaction

**User Story:** As a user, I want to be able to dismiss ads and continue using the app, so that ads don't permanently block my access to features.

#### Acceptance Criteria

1. WHEN an interstitial ad is displayed, THE AdService SHALL show it in full-screen mode
2. WHEN a user dismisses an ad, THE AdService SHALL return control to the app immediately
3. WHEN an ad fails to display, THE AdService SHALL log the error and continue app operation
4. WHEN an ad is displayed, THE AdService SHALL track that an ad was shown for frequency control
5. WHEN an ad completes or is dismissed, THE AdService SHALL trigger a callback to notify listeners

### Requirement 5: Configuration and Ad Unit Management

**User Story:** As a developer, I want to easily configure ad unit IDs and switch between test and production ads, so that I can test safely before deploying.

#### Acceptance Criteria

1. THE AdService SHALL use test ad unit IDs by default for development
2. THE AdService SHALL support switching to production ad unit IDs via configuration
3. WHEN the app is built for production, THE AdService SHALL use production ad unit IDs
4. THE AdService SHALL store ad unit IDs in a centralized configuration
5. WHEN ad unit IDs are invalid, THE AdService SHALL log a warning and use test IDs as fallback

### Requirement 6: Ad Frequency Control

**User Story:** As a user, I want to see ads at reasonable intervals, so that I'm not overwhelmed with too many ads.

#### Acceptance Criteria

1. WHEN an ad is shown, THE AdService SHALL record the timestamp
2. WHEN a new ad show request occurs, THE AdService SHALL check if minimum time has elapsed since the last ad
3. IF less than 60 seconds have passed since the last ad, THEN THE AdService SHALL skip showing the new ad
4. WHEN the minimum time interval has elapsed, THE AdService SHALL allow the next ad to be shown
5. WHEN the app is closed and reopened, THE AdService SHALL reset the ad frequency counter

### Requirement 7: Error Handling and Resilience

**User Story:** As a developer, I want robust error handling, so that ad failures don't crash the app or degrade user experience.

#### Acceptance Criteria

1. IF an ad fails to load, THEN THE AdService SHALL log the error with details
2. IF an ad fails to display, THEN THE AdService SHALL continue app operation normally
3. IF the Google Mobile Ads SDK is unavailable, THEN THE AdService SHALL gracefully degrade
4. WHEN an error occurs, THE AdService SHALL not throw unhandled exceptions
5. WHEN ads are disabled or unavailable, THE AdService SHALL allow the app to function normally

### Requirement 8: Integration with Music Provider

**User Story:** As a developer, I want ads to integrate with the music provider, so that ad display is coordinated with music playback events.

#### Acceptance Criteria

1. WHEN the music provider notifies of screen navigation, THE AdService SHALL receive the event
2. WHEN a user opens the player screen, THE AdService MAY show an ad based on frequency rules
3. WHEN a user returns to home screen, THE AdService MAY show an ad based on frequency rules
4. WHEN music is actively playing, THE AdService SHALL NOT interrupt playback with ads
5. WHEN the app is paused or stopped, THE AdService SHALL still respect ad frequency limits

