import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;

  // Getter para acceder al usuario actual
  AppUser? get user => _user;

  // Indica si hay un usuario logueado
  bool get isLoggedIn => _user != null;

  // Establecer usuario (login)
  void setUser(AppUser newUser) {
    _user = newUser;
    notifyListeners();
  }

  // Limpiar usuario (logout)
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
