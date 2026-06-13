import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _entrevistaKey = 'auth_entrevista';
  static const _perfilKey = 'auth_perfil';
  static const _pontuacaoKey = 'auth_pontuacao';

  final AuthApiService _apiService = AuthApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentToken;
  bool _entrevistaConcluida = false;
  String? _perfilInvestidor;
  int? _pontuacaoPerfil;
  bool _showProfileModal = false;
  String? _currentRefreshToken;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentToken => _currentToken;
  String? get currentRefreshToken => _currentRefreshToken;
  bool get entrevistaConcluida => _entrevistaConcluida;
  String? get perfilInvestidor => _perfilInvestidor;
  int? get pontuacaoPerfil => _pontuacaoPerfil;
  bool get showProfileModal => _showProfileModal;

  void completeEntrevista(String perfil, int pontuacao) async {
    _entrevistaConcluida = true;
    _perfilInvestidor = perfil;
    _pontuacaoPerfil = pontuacao;
    _showProfileModal = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_entrevistaKey, true);
    await prefs.setString(_perfilKey, perfil);
    await prefs.setInt(_pontuacaoKey, pontuacao);
    notifyListeners();
  }

  void clearProfileModal() {
    _showProfileModal = false;
    notifyListeners();
  }

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

          final prefs = await SharedPreferences.getInstance();
          _entrevistaConcluida = prefs.getBool(_entrevistaKey) ?? false;
          _perfilInvestidor = prefs.getString(_perfilKey);
          _pontuacaoPerfil = prefs.getInt(_pontuacaoKey);

          notifyListeners();
        }
      } catch (_) {
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

          _entrevistaConcluida = result.entrevistaConcluida;
          _perfilInvestidor = result.perfilInvestidor;
          _pontuacaoPerfil = result.pontuacaoPerfil;

          await _secureStorage.write(key: _accessTokenKey, value: result.accessToken);
          await _secureStorage.write(key: _refreshTokenKey, value: result.refreshToken);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_entrevistaKey, result.entrevistaConcluida);

          if (result.perfilInvestidor != null) {
            await prefs.setString(_perfilKey, result.perfilInvestidor);
          }

          if (result.pontuacaoPerfil != null) {
            await prefs.setInt(_pontuacaoKey, result.pontuacaoPerfil);
          }

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
    _entrevistaConcluida = false;
    _perfilInvestidor = null;
    _pontuacaoPerfil = null;
    _showProfileModal = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_entrevistaKey);
    await prefs.remove(_perfilKey);
    await prefs.remove(_pontuacaoKey);
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);

    notifyListeners();

    if (token != null) {
      await _apiService.logout(token).catchError((_) {});
    }
  }
}
