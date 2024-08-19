import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProvider with ChangeNotifier {
  String _userId = '';
  String _userNickName = '';
  String get userId => _userId;
  String get userNickName => _userNickName;
  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }
  void setUserNickName(String userNickName) {
    _userNickName = userNickName;
    notifyListeners();
  }
}
