import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/auth_result.dart';

class AuthApiService {
  // Change to http://10.0.2.2:3000 when running on Android emulator
  static const String _baseUrl = 'http://localhost:3000';

  Future<AuthResult> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResult.fromJson(body);
    }

    final message = body['message'];
    throw AuthException(
      message is List<dynamic>
          ? (message).join(', ')
          : message?.toString() ?? 'Erro ao fazer login',
    );
  }

  Future<void> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) return;

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final message = body['message'];
    throw AuthException(
      message is List<dynamic>
          ? (message).join(', ')
          : message?.toString() ?? 'Erro ao cadastrar',
    );
  }

  Future<void> logout(String token) async {
    await http.post(
      Uri.parse('$_baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
