# Implementation Plan: AdMob Interstitial Ads

## Overview

This implementation plan breaks down the AdMob interstitial ads feature into discrete Dart/Flutter coding tasks. Each task builds on previous steps, starting with the core AdService implementation, then integrating with the app, and finally adding comprehensive testing. The implementation follows the design document and ensures all correctness properties are validated through property-based tests.

## Tasks

- [x] 1. Enhance AdService with frequency control and lifecycle management
  - Refactor existing AdService to add frequency control logic
  - Implement `canShowAd()` method to check 60-second minimum interval
  - Implement `recordAdShown()` method to track ad display timestamps
  - Add `lastAdShownTime` field to track when ads were last displayed
  - Add `minFrequencyInterval` configuration (default 60 seconds)
  - Implement proper error handling with try-catch blocks
  - Add debug logging for ad lifecycle events
  - _Requirements: 1.1, 1.2, 1.4, 6.1, 6.2, 6.3, 6.4, 7.1, 7.2, 7.4_

- [x] 1.1 Write property test for ad loading idempotence
  - **Property 1: Ad Loading Idempotence**
  - **Validates: Requirements 3.5**
  - Generate multiple rapid load requests
  - Verify only one ad is cached at a time
  - Verify no duplicate ads in memory

- [x] 1.2 Write property test for frequency control enforcement
  - **Property 2: Frequency Control Enforcement**
  - **Validates: Requirements 2.4, 6.2, 6.3**
  - Generate random sequences of show requests with varying time intervals
  - Verify ads are only shown when 60+ seconds have passed
  - Verify timestamps are correctly updated after each display

- [x] 2. Implement ad pre-loading and caching strategy
  - Modify `loadInterstitialAd()` to be called automatically after app initialization
  - Implement automatic loading of next ad after current ad is dismissed
  - Add retry logic for failed ad loads (retry after 5 seconds)
  - Ensure only one ad is cached in memory at a time
  - Add state tracking for ad loading status
  - _Requirements: 3.1, 3.2, 3.3, 3.5_

- [x] 2.1 Write property test for ad disposal and cleanup
  - **Property 3: Ad Disposal and Cleanup**
  - **Validates: Requirements 1.2, 1.3**
  - Generate ad display and dismissal sequences
  - Verify ads are disposed after display
  - Verify next ad loading begins automatically

- [x] 3. Integrate AdService with app lifecycle
  - Update `main.dart` to initialize AdService at app startup
  - Call `adService.loadInterstitialAd()` during app initialization
  - Implement app lifecycle observer in MyApp to handle app state changes
  - Call `adService.dispose()` when app is detached
  - Ensure AdService is provided to all screens via Provider
  - _Requirements: 1.1, 1.3, 2.5_

- [x] 3.1 Write unit test for app lifecycle integration
  - Test that AdService is initialized at app startup
  - Test that ads are disposed when app is destroyed
  - Test that frequency counter is reset on app restart

- [x] 4. Add ad display triggers at navigation points
  - Update HomeScreen to call `adService.showInterstitialAd()` when navigating to PlayerScreen
  - Update PlayerScreen to call `adService.showInterstitialAd()` when navigating back to HomeScreen
  - Ensure ads are only shown if `canShowAd()` returns true
  - Verify ads don't interrupt active music playback
  - _Requirements: 2.1, 2.2, 2.3, 8.1, 8.2, 8.3, 8.4_

- [x] 4.1 Write unit test for navigation-triggered ads
  - Test that ads are shown when navigating to player
  - Test that ads are shown when returning to home
  - Test that ads respect frequency control during navigation
  - Test that ads don't show during active playback

- [x] 5. Implement error handling and resilience
  - Add try-catch blocks around all ad operations
  - Implement error logging with descriptive messages
  - Add fallback to test ad unit IDs if production IDs are invalid
  - Ensure app continues operating even if ads fail
  - Add graceful degradation if Google Mobile Ads SDK is unavailable
  - _Requirements: 1.4, 5.5, 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 5.1 Write property test for error resilience
  - **Property 4: Error Resilience**
  - **Validates: Requirements 1.4, 7.1, 7.2, 7.3, 7.4**
  - Generate various error conditions (load failures, show failures, SDK unavailable)
  - Verify app continues operating without throwing unhandled exceptions
  - Verify errors are logged appropriately

- [x] 6. Implement ad unit ID configuration
  - Create AdConfig class to store test and production ad unit IDs
  - Set test ad unit IDs as defaults (Android: ca-app-pub-3940256099942544/1033173712, iOS: ca-app-pub-3940256099942544/4411468910)
  - Add method to switch between test and production ad unit IDs
  - Add validation for ad unit IDs
  - Document how to configure production ad unit IDs
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 6.1 Write unit test for ad unit ID configuration
  - Test that test ad unit IDs are used by default
  - Test that production ad unit IDs can be configured
  - Test that invalid ad unit IDs fall back to test IDs
  - Test that ad unit IDs are stored in centralized configuration

- [x] 7. Implement duplicate ad prevention
  - Add flag to track if ad is currently being shown
  - Prevent multiple simultaneous ad displays
  - Queue show requests if ad is already displaying
  - _Requirements: 1.5_

- [x] 7.1 Write property test for duplicate ad prevention
  - **Property 5: Ad Availability**
  - **Validates: Requirements 3.4**
  - Generate rapid show requests
  - Verify only one ad displays at a time
  - Verify queued requests are handled correctly

- [x] 8. Implement timestamp recording and frequency tracking
  - Ensure `recordAdShown()` is called every time an ad is displayed
  - Verify timestamps are used correctly in `canShowAd()` checks
  - Test frequency control with various time intervals
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 8.1 Write property test for timestamp recording
  - **Property 6: Timestamp Recording**
  - **Validates: Requirements 6.1, 6.2**
  - Generate ad display sequences
  - Verify timestamps are recorded correctly
  - Verify frequency checks use updated timestamps

- [x] 9. Add comprehensive logging and debugging
  - Add debug logging for all ad lifecycle events (load, show, dismiss, error)
  - Log timestamps for frequency control debugging
  - Log error details with context
  - Use `debugPrint()` for development logging
  - _Requirements: 1.4, 7.1, 7.2_

- [x] 10. Checkpoint - Ensure all tests pass
  - Run all unit tests and verify they pass
  - Run all property-based tests with minimum 100 iterations
  - Verify no unhandled exceptions occur
  - Check that all requirements are covered by tests
  - Ask the user if questions arise

- [ ] 11. Integration testing and validation
  - Test ad display during normal app usage
  - Verify ads appear at navigation points
  - Verify frequency control works correctly
  - Test error scenarios (network failure, invalid ad unit ID, etc.)
  - Verify app continues operating after ad errors
  - _Requirements: All_

- [x] 11.1 Write integration tests
  - Test end-to-end ad display flow
  - Test navigation-triggered ads
  - Test frequency control across multiple ad displays
  - Test error recovery

- [x] 12. Final checkpoint - Ensure all tests pass and documentation is complete
  - Run all tests one final time
  - Verify all requirements are met
  - Verify all properties are validated
  - Ask the user if questions arise

## Notes

- Each task references specific requirements for traceability
- Property tests should run with minimum 100 iterations
- Use test ad unit IDs during development to avoid account suspension
- Always dispose ads properly to prevent memory leaks
- Frequency control minimum interval is 60 seconds
- Ads should only be shown at natural transition points (navigation)
- Never interrupt active music playback with ads

