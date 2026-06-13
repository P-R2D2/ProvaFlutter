import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:investment_agenda/features/investments/presentation/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.itrix.com.br/flutter_secure_storage');
  final Map<String, String> secureStoreMock = {};

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'read':
          return secureStoreMock[methodCall.arguments['key']];
        case 'write':
          secureStoreMock[methodCall.arguments['key']] = methodCall.arguments['value'];
          return null;
        case 'delete':
          secureStoreMock.remove(methodCall.arguments['key']);
          return null;
        case 'deleteAll':
          secureStoreMock.clear();
          return null;
      }
      return null;
    });
  });

  setUp(() {
    secureStoreMock.clear();
  });

  test('Should optimistically authenticate if refresh token is present in secure storage', () async {
    secureStoreMock['access_token'] = 'mock-access-token';
    secureStoreMock['refresh_token'] = 'mock-refresh-token';

    final authProvider = AuthProvider();
    
    // Wait for async constructor initialization to execute (_restoreSession)
    await Future.delayed(Duration.zero);

    expect(authProvider.isAuthenticated, isTrue);
    expect(authProvider.currentToken, equals('mock-access-token'));
    expect(authProvider.currentRefreshToken, equals('mock-refresh-token'));
  });

  test('Should not authenticate if refresh token is absent', () async {
    final authProvider = AuthProvider();
    await Future.delayed(Duration.zero);

    expect(authProvider.isAuthenticated, isFalse);
    expect(authProvider.currentToken, isNull);
  });
}
