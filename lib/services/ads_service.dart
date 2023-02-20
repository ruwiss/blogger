import 'package:blogmanname/locator.dart';
import 'package:blogmanname/services/analytics_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  String? interstitialAd;
  String? openAppAd;

  AdService({this.interstitialAd, this.openAppAd}) {
    interstitialAd = interstitialAd ?? "ca-app-pub-3940256099942544/1033173712";
    openAppAd = openAppAd ?? "ca-app-pub-3940256099942544/3419835294";
  }

  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;

  void loadInterstitialAd() {
    final analytics = locator.get<AnalyticsService>();
    InterstitialAd.load(
      adUnitId: interstitialAd!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            analytics.recordAd("InterstitialAd Loaded");
            _interstitialAd?.fullScreenContentCallback =
                FullScreenContentCallback(
              onAdShowedFullScreenContent: (InterstitialAd ad) =>
                  analytics.recordAd("InterstitialAd Shown"),
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                interstitialAd = null;
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent:
                  (InterstitialAd ad, AdError error) {
                analytics.recordAd("InterstitialAd Show Error");
                interstitialAd = null;
                ad.dispose();
              },
              onAdImpression: (InterstitialAd ad) {
                analytics.recordAd("InterstitialAd Impression");
              },
              onAdClicked: (ad) =>
                  analytics.recordAd("Interstitial Clicked", withUid: true),
            );
          },
          onAdFailedToLoad: (LoadAdError error) =>
              analytics.recordAd("InterstitialAd Load Error")),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    }
  }

  void loadAppOpenAd() {
    final analytics = locator.get<AnalyticsService>();
    AppOpenAd.load(
      adUnitId: "ca-app-pub-3940256099942544/3419835294",
      orientation: AppOpenAd.orientationPortrait,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          analytics.recordAd("appOpenAd Loaded");
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          analytics.recordAd("appOpenAd Load Error");
        },
      ),
    );
  }

  bool get isAppOpenAdAvailable => _appOpenAd != null;

  void showAppOpenAd() {
    final analytics = locator.get<AnalyticsService>();
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        analytics.recordAd("appOpenAd Shown");
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
      onAdClicked: (ad) =>
          analytics.recordAd("appOpenAd Clicked", withUid: true),
    );
    if (isAppOpenAdAvailable) {
      _appOpenAd!.show();
    }
  }
}
