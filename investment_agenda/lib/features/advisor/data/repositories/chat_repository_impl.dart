import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/chat_session.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ChatSession> getSession(String sessionId) async {
    return await remoteDataSource.getSession(sessionId);
  }

  @override
  Stream<String> sendMessageStream(String sessionId, String message) {
    return remoteDataSource.sendMessageStream(sessionId, message);
  }
}
