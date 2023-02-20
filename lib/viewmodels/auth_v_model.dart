import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthViewModel with ChangeNotifier {
  late User user;

  void setUser(User u) {
    user = u;
    notifyListeners();
  }

}
