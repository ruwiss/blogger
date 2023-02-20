import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalService {
  late SharedPreferences prefs;

  void checkForAppReview() async {
    final int? review = prefs.getInt("inAppReview");
    if (review == null) {
      prefs.setInt("inAppReview", 1);
    } else if (review == 1) {
      prefs.setInt("inAppReview", 2);
    } else if (review == 2) {
      final InAppReview inAppReview = InAppReview.instance;
      inAppReview.requestReview();
      prefs.setInt("inAppReview", -1);
    }
  }

  void whenSignIn() {
    if (!prefs.containsKey("auth")) {
      prefs.setBool("auth", true);
    }
  }

  void whenSignOut() {
    prefs.remove("auth");
  }

  Future<bool> isLogged() async {
    prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("auth");
  }
}
