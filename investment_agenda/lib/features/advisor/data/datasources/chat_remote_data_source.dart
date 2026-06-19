import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_session_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ChatRemoteDataSource {
  Future<ChatSessionModel> getSession(String sessionId);
  Stream<String> sendMessageStream(String sessionId, String message);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final String baseUrl;
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  ChatRemoteDataSourceImpl({
    required this.baseUrl,
    required this.client,
    required this.secureStorage,
  });

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<ChatSessionModel> getSession(String sessionId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/advisor/session/$sessionId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return ChatSessionModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load session');
    }
  }

  @override
  Stream<String> sendMessageStream(String sessionId, String message) async* {
    final request = http.Request('POST', Uri.parse('$baseUrl/advisor/stream'));
    request.headers.addAll(await _getHeaders());
    request.body = json.encode({
      'sessionId': sessionId,
      'message': message,
    });

    final response = await client.send(request);

    if (response.statusCode != 200) {
      final bodyStr = await response.stream.bytesToString();
      throw Exception('HTTP ${response.statusCode}: $bodyStr');
    }

    await for (final chunk in response.stream.transform(utf8.decoder)) {
      if (chunk.trim().isEmpty) continue;
      
      final lines = chunk.split('\n');
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          try {
            final dataStr = line.substring(6);
            if (dataStr.trim().isEmpty) continue;
            final data = json.decode(dataStr);
            yield data['chunk'] as String;
          } catch (_) {
            // ignore malformed chunks
          }
        }
      }
    }
  }
}
