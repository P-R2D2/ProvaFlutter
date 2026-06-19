import '../../domain/entities/chat_session.dart';
import 'chat_message_model.dart';

class ChatSessionModel extends ChatSession {
  ChatSessionModel({
    required String id,
    required List<ChatMessageModel> messages,
    required DateTime lastActive,
  }) : super(id: id, messages: messages, lastActive: lastActive);

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'],
      messages: (json['messages'] as List)
          .map((msg) => ChatMessageModel.fromJson(msg))
          .toList(),
      lastActive: DateTime.parse(json['lastActive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messages': (messages as List<ChatMessageModel>).map((m) => m.toJson()).toList(),
      'lastActive': lastActive.toIso8601String(),
    };
  }
}
