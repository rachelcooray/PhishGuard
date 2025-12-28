import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = true; // Start loading to check for stored token

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    _token = await _storage.read(key: 'jwt');
    if (_token != null) {
      _isAuthenticated = true;
      // In a real app, we would validate the token with /profile endpoint here
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.login(email, password);

    if (result.containsKey('token')) {
      _token = result['token'];
      _user = result['user'];
      _isAuthenticated = true;
      await _storage.write(key: 'jwt', value: _token);
      _isLoading = false;
      notifyListeners();
      return null; // No error
    } else {
      _isLoading = false;
      notifyListeners();
      return result['error'] ?? 'Login failed';
    }
  }

  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.register(name, email, password);

    if (result.containsKey('token')) {
      _token = result['token'];
      _user = result['user'];
      _isAuthenticated = true;
      await _storage.write(key: 'jwt', value: _token);
      _isLoading = false;
      notifyListeners();
      return null; // No error
    } else {
      _isLoading = false;
      notifyListeners();
      return result['error'] ?? 'Registration failed';
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _isAuthenticated = false;
    await _storage.delete(key: 'jwt');
    notifyListeners();
  }
}
