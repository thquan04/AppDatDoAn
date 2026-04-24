import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ✅ Login state dựa vào Supabase
  bool get isLoggedIn => _user != null;

  // ================= INIT =================
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await ApiService.getCurrentUser();
      _user = user;
    } catch (e) {
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ================= REGISTER =================
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final appUser = await ApiService.register(email, password, name);
      _user = appUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ================= LOGIN =================
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final appUser = await ApiService.login(email, password);
      _user = appUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (e) {
      debugPrint("Logout error: $e");
    }

    _user = null;
    _error = null;
    notifyListeners();
  }

  // ================= UPDATE USER =================
  Future<bool> updateUser(AppUser user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await ApiService.updateUser(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
