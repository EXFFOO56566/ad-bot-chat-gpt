import '../helper/unit_id_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobHelper {
  InterstitialAd? interstitialAd;
  int numOfAttemptLoad = 0;

  static initialization() {
    // ignore: unnecessary_null_comparison
    if (MobileAds.instance == null) {
      MobileAds.instance.initialize();
    }
  }

  //banner ad
  static BannerAd getBannerAd() {
    BannerAd bAd = BannerAd(
      adUnitId: UnitIdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(onAdLoaded: (_) {
        // isBannerAdReady = true;
        // ignore: avoid_print
        print('BannerAd has been initial}');
      }, onAdFailedToLoad: (ad, error) {
        // ignore: avoid_print
        print('BannerAd has been crushed ${error.message}');
        // isBannerAdReady = false;
        ad.dispose();
      }, onAdOpened: (Ad ad) {
        // ignore: avoid_print
        print('BannerAd has been opened}');
      }),
    );

    return bAd;
  }

  //InterstitialAd load
  static Future<void> getInterstitialAdLoad() {
    debugPrint('------------ InterstitialAd Load ----------');
    late InterstitialAd interstitialAd;
    return InterstitialAd.load(
      adUnitId: UnitIdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
        debugPrint('------------ InterstitialAd Started ----------');

        interstitialAd = ad;
        interstitialAd.show();

        debugPrint('------------ InterstitialAd Show ----------');

        interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
            onAdFailedToShowFullScreenContent: ((ad, error) {
          ad.dispose();
          debugPrint(error.message);
        }), onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          interstitialAd.dispose();
        });
      }, onAdFailedToLoad: (error) {
        // ignore: avoid_print
        print('interstitial ad is not done $error');
      }),
    );
  }
}
