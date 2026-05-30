import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class ChatResponse {
  final String role;
  final String content;
  final bool finalizado;
  final String? perfil;

  ChatResponse({
    required this.role,
    required this.content,
    required this.finalizado,
    this.perfil,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      role: json['role'] as String,
      content: json['content'] as String,
      finalizado: json['finalizado'] as bool? ?? false,
      perfil: json['perfil'] as String?,
    );
  }
}

class ChatApiService {
  static const String _baseUrl = 'http://localhost:3000';

  Future<ChatResponse> sendMessage(List<ChatMessage> messages, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/porquinho'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'messages': messages.map((m) => m.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ChatResponse.fromJson(body);
    }

    throw Exception('Erro ao comunicar com a IA do Porquinho');
  }
}
