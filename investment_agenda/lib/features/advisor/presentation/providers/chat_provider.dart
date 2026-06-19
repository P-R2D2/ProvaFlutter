import 'package:flutter/foundation.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/entities/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final SendMessageUseCase sendMessageUseCase;
  
  List<ChatMessage> _messages = [];
  String? _currentSessionId;
  bool _isLoading = false;

  ChatProvider({required this.sendMessageUseCase});

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get currentSessionId => _currentSessionId;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'USER',
      content: text,
      createdAt: DateTime.now(),
    );
    
    _messages.add(userMsg);
    
    final assistantMsgId = DateTime.now().millisecondsSinceEpoch.toString() + "_ai";
    _messages.add(ChatMessage(
      id: assistantMsgId,
      role: 'ASSISTANT',
      content: '',
      createdAt: DateTime.now(),
    ));
    
    _isLoading = true;
    notifyListeners();

    try {
      final stream = sendMessageUseCase.execute(_currentSessionId ?? '', text);
      
      await for (final chunk in stream) {
        final index = _messages.indexWhere((m) => m.id == assistantMsgId);
        if (index != -1) {
          final oldMsg = _messages[index];
          _messages[index] = ChatMessage(
            id: oldMsg.id,
            role: oldMsg.role,
            content: oldMsg.content + chunk,
            createdAt: oldMsg.createdAt,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      final index = _messages.indexWhere((m) => m.id == assistantMsgId);
      if (index != -1) {
        final oldMsg = _messages[index];
        _messages[index] = ChatMessage(
          id: oldMsg.id,
          role: oldMsg.role,
          content: oldMsg.content + '\nError: Failed to fetch response.\n\nDetails: $e',
          createdAt: oldMsg.createdAt,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
