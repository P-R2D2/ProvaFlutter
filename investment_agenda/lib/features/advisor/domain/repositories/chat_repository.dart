import '../entities/chat_session.dart';

abstract class ChatRepository {
  Future<ChatSession> getSession(String sessionId);
  Stream<String> sendMessageStream(String sessionId, String message);
}
