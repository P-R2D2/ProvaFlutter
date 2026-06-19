import 'chat_message.dart';

class ChatSession {
  final String id;
  final List<ChatMessage> messages;
  final DateTime lastActive;

  ChatSession({
    required this.id,
    required this.messages,
    required this.lastActive,
  });
}
