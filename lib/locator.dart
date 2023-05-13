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
      interstitialAd: null,
      openAppAd: null));
  locator.registerLazySingleton<LocalService>(() => LocalService());
  locator.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
}
