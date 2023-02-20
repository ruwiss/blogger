import 'package:blogmanname/constants/strings.dart';
import 'package:blogmanname/locator.dart';
import 'package:blogmanname/services/analytics_service.dart';
import 'package:blogmanname/services/blogger_service.dart';
import 'package:blogmanname/services/local_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final firebaseInstance = FirebaseAuth.instance;
  final authInstance = GoogleSignIn(scopes: KStrings.scopes);

  Future authWithGoogle(
      {required Function(User? user, String accessToken) onLogin,
      Function(Map<String, dynamic> blogsJson)? whenGotBlogs}) async {
    //if (await authInstance.isSignedIn()) await authInstance.disconnect();
    final googleSignInAccount = await authInstance.signIn();
    final authValue = await googleSignInAccount!.authentication;

    final authCredential = GoogleAuthProvider.credential(
        idToken: authValue.idToken, accessToken: authValue.accessToken);
    final authResult =
        await firebaseInstance.signInWithCredential(authCredential);

    final accessToken = authValue.accessToken!;
    await locator
        .get<BloggerService>()
        .fetchBlogs(accessToken, onResult: whenGotBlogs ?? (e) {});
    final User? user = authResult.user;
    if (user != null) {
      await locator.get<AnalyticsService>().setUserProp(authResult.user!.uid);
      onLogin(authResult.user, accessToken);
    }
  }

  Future signOut() async {
    locator.get<LocalService>().whenSignOut();
    await authInstance.disconnect();
    await firebaseInstance.signOut();
  }
}
