//import 'dart:async';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class AdManager {
  bool _rewarded = false;
  get rewarded => _rewarded;

  setRewarded(bool rewarded) {
    _rewarded = rewarded;
  }

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  Completer<bool>? _completer;
  // Future? _myFuture;
  // Timer? _timer;

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );

    _bannerAd?.load();
  }

  void loadRewardedAd() {
    RewardedAd.load(
        adUnitId: AdHelper.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback:
            RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
        }, onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
        }));
  }

  void loadInterstitialAd() {
    String interstitialAdId = AdHelper.interstitialAdUnitId;

    InterstitialAd.load(
        adUnitId: interstitialAdId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                // if (_completer != null) {
                //   _timer?.cancel();
                //   _completer!.complete(true);
                // }
                ad.dispose();
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent:
                  (InterstitialAd ad, AdError error) {
                ad.dispose();
                _interstitialAd = null;
                loadInterstitialAd();
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  void addAds(bool interstitial, bool bannerAd, bool rewardedAd) {
    if (interstitial && _interstitialAd == null) {
      loadInterstitialAd();
    }

    if (bannerAd) {
      loadBannerAd();
    }

    if (rewardedAd && _rewardedAd == null) {
      loadRewardedAd();
    }
  }

/*   Future<bool> showInterstitial() async {
    _completer = Completer<bool>();
    _interstitialAd?.show();
    _timer = Timer(const Duration(seconds: 1), () {
      _completer!.complete(true);
    });
    return _completer!.future;
  }
 */

  showInterstitial() {
    if (_interstitialAd == null) {
      loadInterstitialAd();
    }
    _interstitialAd?.show();
  }

  BannerAd? getBannerAd() {
    return _bannerAd;
  }

  Future<bool> showRewardedAd() async {
    _completer = Completer<bool>();
    if (_rewardedAd == null) {
      loadRewardedAd();
    }
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (RewardedAd ad) {
        debugPrint("Ad onAdShowedFullScreenContent");
      }, onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        //loadRewardedAd();
        _rewardedAd = null;
        _completer!.complete(_rewarded);
      }, onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        loadRewardedAd();
      });

      _rewardedAd!.setImmersiveMode(true);
      _rewardedAd!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        _rewarded = true;
        debugPrint("${reward.amount} ${reward.type}");
      });
    } else {
      _completer!.complete(_rewarded);
    }
    return _completer!.future;
  }

  void disposeAds() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
