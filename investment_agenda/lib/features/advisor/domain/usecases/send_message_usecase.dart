import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Stream<String> execute(String sessionId, String message) {
    return repository.sendMessageStream(sessionId, message);
  }
}
