import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';

void changeStatusBarColor(Color color) {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color));
}

void shareUrlAction({required String title, required String url}) async {
  await FlutterShare.share(
    title: title,
    linkUrl: url,
  );
}
