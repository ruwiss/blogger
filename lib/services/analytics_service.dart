import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final _analytics = FirebaseAnalytics.instance;
  String userId = "";

  FirebaseAnalyticsObserver getAnalyticsObserver() =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future setUserProp(String uid) async {
    userId = uid;
    await _analytics.setUserId(id: uid);
  }

  void recordAd(String log, {bool withUid = false}) {
    _analytics.logEvent(name: withUid ? "$log : $userId" : log);
  }
}
