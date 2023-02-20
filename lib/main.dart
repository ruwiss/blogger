import 'package:blogmanname/locator.dart';
import 'package:blogmanname/screens/auth_screen.dart';
import 'package:blogmanname/screens/comments_screen.dart';
import 'package:blogmanname/screens/content_screen.dart';
import 'package:blogmanname/screens/home_screen.dart';
import 'package:blogmanname/services/ads_service.dart';
import 'package:blogmanname/services/analytics_service.dart';
import 'package:blogmanname/services/local_service.dart';
import 'package:blogmanname/viewmodels/auth_v_model.dart';
import 'package:blogmanname/viewmodels/blog_v_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setup(); // get_it
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isPaused = false;

  @override
  void initState() {
    locator.get<AdService>().loadAppOpenAd();
    locator.get<AdService>().loadInterstitialAd();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _isPaused = true;
    }
    if (state == AppLifecycleState.resumed && _isPaused) {
      locator.get<AdService>().showAppOpenAd();
      _isPaused = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
            create: (context) => locator.get<AuthViewModel>()),
        ChangeNotifierProvider<BlogViewModel>(
            create: (context) => locator.get<BlogViewModel>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: [
          locator.get<AnalyticsService>().getAnalyticsObserver()
        ],
        theme: ThemeData(useMaterial3: true),
        initialRoute: "/",
        routes: {
          "/": (context) => const AuthScreen(),
          "/home": (context) => const HomeScreen(),
          "/content": (context) => const ContentScreen(),
          "/comments": (context) => CommentsScreen(
                commentsLink:
                    ModalRoute.of(context)!.settings.arguments.toString(),
              )
        },
      ),
    );
  }
}
