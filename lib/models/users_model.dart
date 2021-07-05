import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';


class UsersModel extends ChangeNotifier {

  int _users = 0;
  int get users => _users;

  void login(String username, String password) {

    notifyListeners();
  }

}

class User {

  String email;
  String password;

  User({@required this.email, @required this.password});

}