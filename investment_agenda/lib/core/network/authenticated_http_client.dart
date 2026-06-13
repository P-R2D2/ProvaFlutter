import 'dart:async';
import 'package:http/http.dart' as http;

class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _innerClient;
  final Future<String?> Function() _getAccessToken;
  final Future<bool> Function() _refreshTokens;
  final void Function() _onSessionExpired;

  AuthenticatedHttpClient({
    http.Client? innerClient,
    required Future<String?> Function() getAccessToken,
    required Future<bool> Function() refreshTokens,
    required void Function() onSessionExpired,
  })  : _innerClient = innerClient ?? http.Client(),
        _getAccessToken = getAccessToken,
        _refreshTokens = refreshTokens,
        _onSessionExpired = onSessionExpired;

  Future<void>? _refreshFuture;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final accessToken = await _getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Read the request body to allow replaying it in case of a retry.
    final List<int> requestBytes = await request.finalize().toBytes();

    final streamedResponse = await _innerClient.send(
      _cloneRequest(request, requestBytes),
    );

    if (streamedResponse.statusCode == 401) {
      final success = await _performRefresh();
      if (success) {
        final newAccessToken = await _getAccessToken();
        final retryRequest = _cloneRequest(request, requestBytes);
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';
        } else {
          retryRequest.headers.remove('Authorization');
        }
        return _innerClient.send(retryRequest);
      } else {
        _onSessionExpired();
      }
    }

    return streamedResponse;
  }

  Future<bool> _performRefresh() async {
    if (_refreshFuture != null) {
      await _refreshFuture;
      final currentToken = await _getAccessToken();
      return currentToken != null && currentToken.isNotEmpty;
    }

    final completer = Completer<void>();
    _refreshFuture = completer.future;

    try {
      final success = await _refreshTokens();
      completer.complete();
      return success;
    } catch (_) {
      completer.complete();
      return false;
    } finally {
      _refreshFuture = null;
    }
  }

  http.BaseRequest _cloneRequest(http.BaseRequest original, List<int> bodyBytes) {
    final cloned = http.Request(original.method, original.url);
    cloned.headers.addAll(original.headers);
    cloned.bodyBytes = bodyBytes;
    cloned.followRedirects = original.followRedirects;
    cloned.maxRedirects = original.maxRedirects;
    cloned.persistentConnection = original.persistentConnection;
    return cloned;
  }

  @override
  void close() {
    _innerClient.close();
    super.close();
  }
}
