import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  // Production AdMob IDs
  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-2743584570741087/1866709499'
      : 'ca-app-pub-3940256099942544/2934735716';

  static String get rewardedInterstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-2743584570741087/7076316877'
      : 'ca-app-pub-3940256099942544/6978759866';


  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isLoadingRewardedInterstitial = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
    _loadRewardedInterstitialAd();
    debugPrint('[AdService] Initialized');
  }

  // --- Rewarded Interstitial Ad ---
  // Used on screen changes. If not ready, callback fires immediately
  // so navigation is never blocked.

  void _loadRewardedInterstitialAd() {
    if (_isLoadingRewardedInterstitial) return;
    _isLoadingRewardedInterstitial = true;

    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          _isLoadingRewardedInterstitial = false;
          debugPrint('[AdService] Rewarded Interstitial Ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint(
              '[AdService] Rewarded Interstitial Ad failed to load: $error');
          _rewardedInterstitialAd = null;
          _isLoadingRewardedInterstitial = false;
          // Retry after a delay
          Future.delayed(
              const Duration(seconds: 30), _loadRewardedInterstitialAd);
        },
      ),
    );
  }

  /// Show a rewarded interstitial ad on screen changes.
  /// If ad is not ready, [onDismissed] is called immediately so
  /// navigation is never blocked by ads.
  void showRewardedInterstitialAd({VoidCallback? onDismissed}) {
    if (_rewardedInterstitialAd == null) {
      // Not ready — navigate immediately, try loading for next time
      debugPrint(
          '[AdService] Rewarded Interstitial Ad not ready, navigating directly');
      _loadRewardedInterstitialAd();
      onDismissed?.call();
      return;
    }

    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        _loadRewardedInterstitialAd(); // preload next
        onDismissed?.call();
        debugPrint('[AdService] Rewarded Interstitial dismissed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Rewarded Interstitial failed to show: $error');
        ad.dispose();
        _rewardedInterstitialAd = null;
        _loadRewardedInterstitialAd();
        onDismissed?.call(); // still navigate
      },
    );

    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint(
            '[AdService] User earned reward: ${reward.amount} ${reward.type}');
      },
    );
  }


  // --- Banner Ad ---

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('[AdService] Banner Ad loaded'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('[AdService] Banner Ad failed to load: $error');
        },
      ),
    )..load();
  }

  void dispose() {
    _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;
  }
}
