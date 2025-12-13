import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service for managing AdMob advertisements.
/// Supports banner ads, interstitial ads, and rewarded video ads.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Test Ad Unit IDs (replace with your real Ad Unit IDs for production)
  // These are Google's official test IDs for development
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android test banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS test banner
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Android test interstitial
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS test interstitial
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android test rewarded
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS test rewarded
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Ad instances
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // State tracking
  bool _isInitialized = false;
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  // Callbacks
  VoidCallback? _onInterstitialAdClosed;
  void Function(int bonusPoints)? _onRewardEarned;

  // Getters for ad state
  bool get isInitialized => _isInitialized;
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  BannerAd? get bannerAd => _bannerAd;

  // Game counter for ad frequency control
  int _gamesPlayed = 0;
  static const int _gamesBeforeInterstitial = 2; // Show interstitial every 2 games

  /// Initialize the Mobile Ads SDK.
  /// Call this in main() before runApp().
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdMob initialized successfully');

      // Preload ads
      await loadBannerAd();
      await loadInterstitialAd();
      await loadRewardedAd();
    } catch (e) {
      debugPrint('AdMob initialization failed: $e');
    }
  }

  /// Load a banner ad for display on screens.
  Future<void> loadBannerAd() async {
    if (!_isInitialized) return;

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          debugPrint('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          ad.dispose();
          debugPrint('Banner ad failed to load: ${error.message}');
        },
        onAdOpened: (ad) => debugPrint('Banner ad opened'),
        onAdClosed: (ad) => debugPrint('Banner ad closed'),
      ),
    );

    await _bannerAd?.load();
  }

  /// Load an interstitial ad for showing between game sessions.
  Future<void> loadInterstitialAd() async {
    if (!_isInitialized) return;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          debugPrint('Interstitial ad loaded');

          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _isInterstitialAdLoaded = false;
              ad.dispose();
              _onInterstitialAdClosed?.call();
              loadInterstitialAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _isInterstitialAdLoaded = false;
              ad.dispose();
              _onInterstitialAdClosed?.call();
              loadInterstitialAd();
              debugPrint('Interstitial ad failed to show: ${error.message}');
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          debugPrint('Interstitial ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Load a rewarded video ad for bonus points.
  Future<void> loadRewardedAd() async {
    if (!_isInitialized) return;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          debugPrint('Rewarded ad loaded');

          _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _isRewardedAdLoaded = false;
              ad.dispose();
              loadRewardedAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _isRewardedAdLoaded = false;
              ad.dispose();
              loadRewardedAd();
              debugPrint('Rewarded ad failed to show: ${error.message}');
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          debugPrint('Rewarded ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Show an interstitial ad if one is loaded and frequency allows.
  /// [onClosed] callback is called when the ad is dismissed.
  void showInterstitialAd({VoidCallback? onClosed}) {
    _gamesPlayed++;
    _onInterstitialAdClosed = onClosed;

    // Only show interstitial every N games
    if (_gamesPlayed >= _gamesBeforeInterstitial && _isInterstitialAdLoaded && _interstitialAd != null) {
      _gamesPlayed = 0;
      _interstitialAd?.show();
    } else {
      // No ad to show, call callback immediately
      onClosed?.call();
    }
  }

  /// Show a rewarded video ad for bonus points.
  /// [onRewardEarned] callback is called with bonus points when the user
  /// completes watching the ad.
  void showRewardedAd({
    required void Function(int bonusPoints) onRewardEarned,
    VoidCallback? onAdNotAvailable,
  }) {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _onRewardEarned = onRewardEarned;
      _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) {
          // Standard bonus points for watching a rewarded video
          const bonusPoints = 50;
          _onRewardEarned?.call(bonusPoints);
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        },
      );
    } else {
      onAdNotAvailable?.call();
      debugPrint('Rewarded ad not available');
    }
  }

  /// Create a widget to display the banner ad.
  /// Returns null if the banner ad is not loaded.
  AdWidget? getBannerAdWidget() {
    if (_isBannerAdLoaded && _bannerAd != null) {
      return AdWidget(ad: _bannerAd!);
    }
    return null;
  }

  /// Get the banner ad size for layout calculations.
  AdSize get bannerAdSize => AdSize.banner;

  /// Dispose all ads and clean up resources.
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    _isBannerAdLoaded = false;
    _isInterstitialAdLoaded = false;
    _isRewardedAdLoaded = false;
  }
}
