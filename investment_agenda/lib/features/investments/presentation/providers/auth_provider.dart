import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final AuthApiService _apiService = AuthApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentToken;
  String? _currentRefreshToken;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentToken => _currentToken;
  String? get currentRefreshToken => _currentRefreshToken;

  AuthProvider() {
    _restoreSession();
  }

  /// Attempts to restore a previously saved token pair from secure storage.
  Future<void> _restoreSession() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (refreshToken != null && refreshToken.isNotEmpty) {
        _currentToken = accessToken;
        _currentRefreshToken = refreshToken;
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (_) {
      // Secure storage read error (e.g. key corruption) -> clear
      await logout();
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
      _currentRefreshToken = result.refreshToken;
      _isAuthenticated = true;

      await _secureStorage.write(key: _accessTokenKey, value: result.accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: result.refreshToken);

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

  /// Automatically calls refresh endpoint and updates active tokens.
  /// Returns true on success, false on failure.
  Future<bool> refreshSession() async {
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final result = await _apiService.refresh(refreshToken);
      _currentToken = result.accessToken;
      _currentRefreshToken = result.refreshToken;
      _isAuthenticated = true;

      await _secureStorage.write(key: _accessTokenKey, value: result.accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: result.refreshToken);

      notifyListeners();
      return true;
    } catch (_) {
      // Invalidate on refresh failure
      await logout();
      return false;
    }
  }

  /// Force session invalidation (logout)
  void forceSessionExpired() {
    _isAuthenticated = false;
    _currentToken = null;
    _currentRefreshToken = null;
    _secureStorage.delete(key: _accessTokenKey);
    _secureStorage.delete(key: _refreshTokenKey);
    notifyListeners();
  }

  /// Calls POST /auth/logout and clears local state + persisted token.
  Future<void> logout() async {
    final token = _currentToken;
    final refreshToken = _currentRefreshToken;

    _isAuthenticated = false;
    _currentToken = null;
    _currentRefreshToken = null;

    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);

    notifyListeners();

    if (token != null) {
      await _apiService.logout(token).catchError((_) {});
    }
  }
}
