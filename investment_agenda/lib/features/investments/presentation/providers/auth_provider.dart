import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';

  final AuthApiService _apiService = AuthApiService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentToken;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentToken => _currentToken;

  AuthProvider() {
    _restoreSession();
  }

  /// Attempts to restore a previously saved JWT from shared_preferences.
  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      _currentToken = token;
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  /// Calls POST /auth/login. Returns null on success, error message on failure.
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);
      _currentToken = result.accessToken;
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, result.accessToken);

      return null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return e.message;
    } catch (_) {
      _errorMessage = 'Não foi possível conectar ao servidor';
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calls POST /auth/register. Returns null on success, error message on failure.
  Future<String?> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.register(email, password);
      return null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return e.message;
    } catch (_) {
      _errorMessage = 'Não foi possível conectar ao servidor';
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calls POST /auth/logout and clears local state + persisted token.
  Future<void> logout() async {
    if (_currentToken != null) {
      await _apiService.logout(_currentToken!).catchError((_) {});
    }
    _isAuthenticated = false;
    _currentToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);

    notifyListeners();
  }
}
