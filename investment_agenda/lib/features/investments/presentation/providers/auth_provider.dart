import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';
  static const _entrevistaKey = 'auth_entrevista';
  static const _perfilKey = 'auth_perfil';
  static const _pontuacaoKey = 'auth_pontuacao';

  final AuthApiService _apiService = AuthApiService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentToken;
  bool _entrevistaConcluida = false;
  String? _perfilInvestidor;
  int? _pontuacaoPerfil;
  bool _showProfileModal = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentToken => _currentToken;
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

  /// Attempts to restore a previously saved JWT from shared_preferences.
  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final entrevista = prefs.getBool(_entrevistaKey) ?? false;
    final perfil = prefs.getString(_perfilKey);
    final pontuacao = prefs.getInt(_pontuacaoKey);
    
    if (token != null && token.isNotEmpty) {
      _currentToken = token;
      _isAuthenticated = true;
      _entrevistaConcluida = entrevista;
      _perfilInvestidor = perfil;
      _pontuacaoPerfil = pontuacao;
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
      _entrevistaConcluida = result.entrevistaConcluida;
      _perfilInvestidor = result.perfilInvestidor;
      _pontuacaoPerfil = result.pontuacaoPerfil;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, result.accessToken);
      await prefs.setBool(_entrevistaKey, result.entrevistaConcluida);
      if (result.perfilInvestidor != null) {
        await prefs.setString(_perfilKey, result.perfilInvestidor!);
      }
      if (result.pontuacaoPerfil != null) {
        await prefs.setInt(_pontuacaoKey, result.pontuacaoPerfil!);
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

  /// Calls POST /auth/logout and clears local state + persisted token.
  Future<void> logout() async {
    if (_currentToken != null) {
      await _apiService.logout(_currentToken!).catchError((_) {});
    }
    _isAuthenticated = false;
    _currentToken = null;
    _entrevistaConcluida = false;
    _perfilInvestidor = null;
    _pontuacaoPerfil = null;
    _showProfileModal = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_entrevistaKey);
    await prefs.remove(_perfilKey);
    await prefs.remove(_pontuacaoKey);

    notifyListeners();
  }
}
