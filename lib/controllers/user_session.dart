import 'package:flutter/material.dart';

class UserSessionController extends ChangeNotifier {
  bool _login = false;
  String _userInSession = 'Anônimo';
  bool get login => _login;
  String get userInSession => _userInSession;

  // As I alter this variable, the other widgets linked will know about it
  void changeLoginState({required bool loginToken}) {
    // print('===== ANTES =====\n$_flashlight');
    _login = loginToken;
    // print('===== DEPOIS =====\n$_flashlight');
    notifyListeners();
  }

  void toggleUserInSession({required String userToken}) {
    _userInSession = userToken;
    notifyListeners();
  }

  void logoutUserInSession() {
    _userInSession = 'Anônimo';
    notifyListeners();
  }
}
