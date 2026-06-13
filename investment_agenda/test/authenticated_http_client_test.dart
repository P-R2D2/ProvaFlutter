import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:investment_agenda/core/network/authenticated_http_client.dart';

class MockHttpClient extends http.BaseClient {
  int sendCount = 0;
  final List<http.BaseRequest> requestsSent = [];
  final List<http.StreamedResponse> responsesToReturn;

  MockHttpClient(this.responsesToReturn);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requestsSent.add(request);
    final response = responsesToReturn[sendCount];
    sendCount++;
    return response;
  }
}

void main() {
  test('Should attach Authorization header to outgoing requests', () async {
    final mockResponse = http.StreamedResponse(const Stream.empty(), 200);
    final mockInnerClient = MockHttpClient([mockResponse]);

    final client = AuthenticatedHttpClient(
      innerClient: mockInnerClient,
      getAccessToken: () async => 'initial-access-token',
      refreshTokens: () async => true,
      onSessionExpired: () {},
    );

    final response = await client.get(Uri.parse('http://example.com/api/data'));

    expect(response.statusCode, equals(200));
    expect(mockInnerClient.requestsSent.length, equals(1));
    expect(mockInnerClient.requestsSent.first.headers['Authorization'], equals('Bearer initial-access-token'));
  });

  test('Should refresh token and retry on 401 response', () async {
    final mock401Response = http.StreamedResponse(const Stream.empty(), 401);
    final mock200Response = http.StreamedResponse(const Stream.empty(), 200);
    final mockInnerClient = MockHttpClient([mock401Response, mock200Response]);

    String currentToken = 'expired-token';
    int refreshCalls = 0;

    final client = AuthenticatedHttpClient(
      innerClient: mockInnerClient,
      getAccessToken: () async => currentToken,
      refreshTokens: () async {
        refreshCalls++;
        currentToken = 'new-valid-token';
        return true;
      },
      onSessionExpired: () {},
    );

    final response = await client.get(Uri.parse('http://example.com/api/data'));

    expect(response.statusCode, equals(200));
    expect(mockInnerClient.requestsSent.length, equals(2));
    expect(refreshCalls, equals(1));
    expect(mockInnerClient.requestsSent.first.headers['Authorization'], equals('Bearer expired-token'));
    expect(mockInnerClient.requestsSent.last.headers['Authorization'], equals('Bearer new-valid-token'));
  });

  test('Should invoke session expired callback when refresh fails', () async {
    final mock401Response = http.StreamedResponse(const Stream.empty(), 401);
    final mockInnerClient = MockHttpClient([mock401Response]);

    int expiredCalls = 0;

    final client = AuthenticatedHttpClient(
      innerClient: mockInnerClient,
      getAccessToken: () async => 'expired-token',
      refreshTokens: () async => false, // Refresh fails
      onSessionExpired: () {
        expiredCalls++;
      },
    );

    final response = await client.get(Uri.parse('http://example.com/api/data'));

    expect(response.statusCode, equals(401));
    expect(mockInnerClient.requestsSent.length, equals(1));
    expect(expiredCalls, equals(1));
  });

  test('Should serialize concurrent 401s so that only a single refresh is triggered', () async {
    final mock401Response1 = http.StreamedResponse(const Stream.empty(), 401);
    final mock401Response2 = http.StreamedResponse(const Stream.empty(), 401);
    final mock200Response1 = http.StreamedResponse(const Stream.empty(), 200);
    final mock200Response2 = http.StreamedResponse(const Stream.empty(), 200);

    final mockInnerClient = MockHttpClient([
      mock401Response1,
      mock401Response2,
      mock200Response1,
      mock200Response2,
    ]);

    int refreshCalls = 0;

    final client = AuthenticatedHttpClient(
      innerClient: mockInnerClient,
      getAccessToken: () async => 'token',
      refreshTokens: () async {
        refreshCalls++;
        // Simulate a slow network response for the refresh endpoint
        await Future.delayed(const Duration(milliseconds: 50));
        return true;
      },
      onSessionExpired: () {},
    );

    // Run both requests concurrently
    final results = await Future.wait([
      client.get(Uri.parse('http://example.com/1')),
      client.get(Uri.parse('http://example.com/2')),
    ]);

    expect(results[0].statusCode, equals(200));
    expect(results[1].statusCode, equals(200));
    expect(refreshCalls, equals(1)); // Only a single refresh request should be fired!
    expect(mockInnerClient.requestsSent.length, equals(4)); // 2 failed + 2 retries
  });
}
