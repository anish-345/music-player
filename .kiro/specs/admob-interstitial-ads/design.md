# Design Document: AdMob Interstitial Ads

## Overview

This design implements a robust AdMob interstitial ad system for the Flutter music player app. The system manages the complete lifecycle of interstitial ads including loading, caching, displaying, and frequency control. Ads are strategically placed at natural transition points (screen navigation) while respecting user experience by enforcing minimum display intervals.

The implementation follows AdMob best practices:
- Always use test ad unit IDs during development
- Pre-load ads to ensure quick display
- Implement proper error handling and resilience
- Respect ad frequency limits to avoid user frustration
- Dispose ads properly to prevent memory leaks

## Architecture

The ad system uses a service-based architecture with the following components:

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App                             │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │  HomeScreen      │         │  PlayerScreen    │          │
│  │  (Navigation)    │────────▶│  (Navigation)    │          │
│  └──────────────────┘         └──────────────────┘          │
│           │                            │                     │
│           └────────────┬───────────────┘                     │
│                        │                                      │
│                        ▼                                      │
│           ┌────────────────────────┐                         │
│           │   MusicProvider        │                         │
│           │  (Navigation Events)   │                         │
│           └────────────┬───────────┘                         │
│                        │                                      │
│                        ▼                                      │
│           ┌────────────────────────┐                         │
│           │    AdService           │                         │
│           │  (Ad Management)       │                         │
│           └────────────┬───────────┘                         │
│                        │                                      │
│        ┌───────────────┼───────────────┐                     │
│        │               │               │                     │
│        ▼               ▼               ▼                      │
│   ┌─────────┐  ┌──────────────┐  ┌──────────────┐           │
│   │ Loading │  │  Caching     │  │  Frequency   │           │
│   │ Manager │  │  Manager     │  │  Control     │           │
│   └─────────┘  └──────────────┘  └──────────────┘           │
│        │               │               │                     │
│        └───────────────┼───────────────┘                     │
│                        │                                      │
│                        ▼                                      │
│           ┌────────────────────────┐                         │
│           │  Google Mobile Ads SDK │                         │
│           │  (InterstitialAd)      │                         │
│           └────────────────────────┘                         │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### AdService

The main service responsible for managing interstitial ads.

**Key Responsibilities:**
- Initialize Google Mobile Ads SDK
- Load and cache interstitial ads
- Display ads at appropriate times
- Manage ad frequency and cooldown periods
- Handle ad lifecycle events
- Dispose resources properly

**Public Interface:**

```dart
class AdService {
  // Initialization
  Future<void> initialize();
  
  // Ad Management
  Future<void> loadInterstitialAd();
  Future<void> showInterstitialAd();
  
  // Frequency Control
  bool canShowAd();
  void recordAdShown();
  
  // Lifecycle
  void dispose();
  
  // Configuration
  String getAdUnitId();
  void setAdUnitId(String adUnitId);
}
```

**Key Methods:**

1. **initialize()**: Initializes the Google Mobile Ads SDK (called once at app startup)
2. **loadInterstitialAd()**: Loads an interstitial ad asynchronously
3. **showInterstitialAd()**: Displays the loaded ad if available and frequency rules allow
4. **canShowAd()**: Checks if enough time has passed since the last ad display
5. **recordAdShown()**: Records the timestamp of the last shown ad
6. **dispose()**: Cleans up resources and disposes the current ad

### Ad Unit ID Configuration

**Test Ad Unit IDs** (for development):
- Android: `ca-app-pub-3940256099942544/1033173712`
- iOS: `ca-app-pub-3940256099942544/4411468910`

**Production Ad Unit IDs** (to be configured):
- Android: [User's production ad unit ID]
- iOS: [User's production ad unit ID]

**Configuration Strategy:**
- Use test IDs by default in debug builds
- Allow switching to production IDs via environment variables or build configuration
- Validate ad unit IDs before use

## Data Models

### Ad State

```dart
class AdState {
  InterstitialAd? currentAd;
  DateTime? lastAdShownTime;
  bool isLoading;
  bool isReady;
  String? lastError;
}
```

### Ad Configuration

```dart
class AdConfig {
  final String androidAdUnitId;
  final String iosAdUnitId;
  final Duration minFrequencyInterval; // Minimum time between ads
  final bool useTestAds; // Use test ad unit IDs
}
```

## Ad Lifecycle

The interstitial ad follows this lifecycle:

```
┌─────────────┐
│   Initial   │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│  Loading Ad         │
│  (InterstitialAd    │
│   .load called)     │
└──────┬──────────────┘
       │
       ├─────────────────────────┐
       │                         │
       ▼                         ▼
┌──────────────┐         ┌──────────────┐
│ Ad Loaded    │         │ Load Failed  │
│ (Ready)      │         │ (Retry)      │
└──────┬───────┘         └──────┬───────┘
       │                        │
       ▼                        ▼
┌──────────────────────────────────────┐
│  Waiting for Show Request            │
│  (canShowAd() check)                 │
└──────┬───────────────────────────────┘
       │
       ├─────────────────────────┐
       │                         │
       ▼                         ▼
┌──────────────┐         ┌──────────────┐
│ Show Ad      │         │ Skip Ad      │
│ (show())     │         │ (Frequency   │
└──────┬───────┘         │  limit)      │
       │                 └──────┬───────┘
       ▼                        │
┌──────────────────────┐        │
│ Ad Displayed         │        │
│ (Full Screen)        │        │
└──────┬───────────────┘        │
       │                        │
       ├─────────────────────────┐
       │                         │
       ▼                         ▼
┌──────────────┐         ┌──────────────┐
│ Ad Dismissed │         │ Ad Failed    │
│ (User closes)│         │ (Show error) │
└──────┬───────┘         └──────┬───────┘
       │                        │
       └────────────┬───────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │ Dispose Ad           │
         │ (Free Resources)     │
         └──────────┬───────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │ Load Next Ad         │
         │ (Cycle Repeats)      │
         └──────────────────────┘
```

## Frequency Control

**Minimum Ad Interval:** 60 seconds between consecutive ad displays

**Algorithm:**
1. When an ad is shown, record the current timestamp
2. When a new ad show request arrives, check if 60+ seconds have passed
3. If yes, allow the ad to be shown and update the timestamp
4. If no, skip the ad display
5. Reset the counter when the app is closed and reopened

**Implementation:**
```dart
bool canShowAd() {
  if (lastAdShownTime == null) return true;
  
  final timeSinceLastAd = DateTime.now().difference(lastAdShownTime!);
  return timeSinceLastAd.inSeconds >= minFrequencyInterval.inSeconds;
}
```

## Error Handling

**Error Scenarios:**

1. **Ad Load Failure**
   - Log error with details
   - Retry loading after 5 seconds
   - Continue app operation normally

2. **Ad Show Failure**
   - Log error with details
   - Dispose the failed ad
   - Load the next ad
   - Continue app operation normally

3. **Invalid Ad Unit ID**
   - Log warning
   - Fall back to test ad unit ID
   - Continue app operation

4. **Google Mobile Ads SDK Unavailable**
   - Log error
   - Gracefully degrade (no ads shown)
   - Continue app operation normally

**Error Logging:**
- Use `debugPrint()` for development
- Include error code, message, and context
- Never throw unhandled exceptions

## Integration Points

### With MusicProvider

The AdService integrates with MusicProvider to receive navigation events:

```dart
// In MusicProvider or navigation logic
void navigateToPlayer() {
  // Show ad when navigating to player
  adService.showInterstitialAd();
  // Navigate to player screen
}

void navigateToHome() {
  // Show ad when returning to home
  adService.showInterstitialAd();
  // Navigate to home screen
}
```

### With App Lifecycle

The AdService respects app lifecycle:

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.detached) {
    // Dispose ads when app is destroyed
    adService.dispose();
  }
}
```

## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: Ad Loading Idempotence

**For any** AdService instance, calling `loadInterstitialAd()` multiple times in succession should result in at most one ad being loaded and cached at a time.

**Validates: Requirements 3.5**

### Property 2: Frequency Control Enforcement

**For any** sequence of ad show requests, if two requests occur within 60 seconds of each other, the second request should not result in an ad being displayed.

**Validates: Requirements 2.4, 6.2, 6.3**

### Property 3: Ad Disposal and Cleanup

**For any** displayed ad, after the ad is dismissed or fails to show, the ad should be disposed and the next ad should begin loading automatically.

**Validates: Requirements 1.2, 1.3**

### Property 4: Error Resilience

**For any** ad loading or display failure, the app should continue operating normally without throwing unhandled exceptions.

**Validates: Requirements 1.4, 7.1, 7.2, 7.3, 7.4**

### Property 5: Ad Availability

**For any** show request that passes frequency control checks, an ad should be available to display within 500ms (or the request should be queued for the next available ad).

**Validates: Requirements 3.4**

### Property 6: Timestamp Recording

**For any** displayed ad, the timestamp of display should be recorded such that subsequent frequency checks use the updated timestamp.

**Validates: Requirements 6.1, 6.2**

## Testing Strategy

### Unit Tests

Unit tests verify specific examples and edge cases:

1. **Ad Loading Tests**
   - Test successful ad load
   - Test ad load failure and retry
   - Test multiple load requests

2. **Frequency Control Tests**
   - Test ad shown within interval (should skip)
   - Test ad shown after interval (should display)
   - Test timestamp recording

3. **Error Handling Tests**
   - Test invalid ad unit ID handling
   - Test ad show failure handling
   - Test graceful degradation

4. **Lifecycle Tests**
   - Test ad disposal
   - Test resource cleanup
   - Test app lifecycle integration

### Property-Based Tests

Property-based tests verify universal properties across many generated inputs:

1. **Property 1: Ad Loading Idempotence**
   - Generate multiple rapid load requests
   - Verify only one ad is cached
   - Verify no duplicate ads in memory

2. **Property 2: Frequency Control Enforcement**
   - Generate random sequences of show requests with varying time intervals
   - Verify ads are only shown when 60+ seconds have passed
   - Verify timestamps are correctly updated

3. **Property 3: Ad Disposal and Cleanup**
   - Generate ad display and dismissal sequences
   - Verify ads are disposed after display
   - Verify next ad loading begins automatically

4. **Property 4: Error Resilience**
   - Generate various error conditions
   - Verify app continues operating
   - Verify no unhandled exceptions

5. **Property 5: Ad Availability**
   - Generate show requests at various times
   - Verify ads are available within 500ms
   - Verify queuing works correctly

6. **Property 6: Timestamp Recording**
   - Generate ad display sequences
   - Verify timestamps are recorded correctly
   - Verify frequency checks use updated timestamps

### Test Configuration

- Minimum 100 iterations per property test
- Use mock Google Mobile Ads SDK for testing
- Test both success and failure paths
- Verify resource cleanup in all scenarios

## Error Handling

**Ad Load Errors:**
- Log error with AdLoadCallback details
- Retry loading after 5 seconds
- Continue app operation

**Ad Show Errors:**
- Log error with FullScreenContentCallback details
- Dispose the failed ad
- Load the next ad
- Continue app operation

**Configuration Errors:**
- Log warning for invalid ad unit IDs
- Fall back to test ad unit IDs
- Continue app operation

**SDK Errors:**
- Log error if Google Mobile Ads SDK is unavailable
- Gracefully degrade (no ads shown)
- Continue app operation

## Implementation Notes

1. **Test Ad Unit IDs**: Always use test IDs during development to avoid account suspension
2. **Ad Disposal**: Always dispose ads in callbacks to prevent memory leaks
3. **Frequency Control**: Enforce minimum 60-second interval between ads
4. **Error Handling**: Never throw unhandled exceptions; always log and continue
5. **Resource Management**: Load ads asynchronously to avoid blocking UI
6. **Lifecycle Integration**: Respect app lifecycle and music playback state

