import 'package:blogmanname/services/ads_service.dart';
import 'package:blogmanname/services/analytics_service.dart';
import 'package:blogmanname/services/auth_service.dart';
import 'package:blogmanname/services/blogger_service.dart';
import 'package:blogmanname/services/local_service.dart';
import 'package:blogmanname/viewmodels/auth_v_model.dart';
import 'package:blogmanname/viewmodels/blog_v_model.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setup() {
  locator.registerLazySingleton<AuthViewModel>(() => AuthViewModel());
  locator.registerLazySingleton<BlogViewModel>(() => BlogViewModel());
  locator.registerLazySingleton<BloggerService>(() => BloggerService());
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<AdService>(() => AdService(
      interstitialAd: "ca-app-pub-1923752572867502/4404138073",
      openAppAd: "ca-app-pub-1923752572867502/6035401058"));
  locator.registerLazySingleton<LocalService>(() => LocalService());
  locator.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
}
