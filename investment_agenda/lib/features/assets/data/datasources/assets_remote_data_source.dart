import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_asset_model.dart';
import '../models/asset_details_model.dart';

class AssetsRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  AssetsRemoteDataSource({
    this.baseUrl = 'http://localhost:3000',
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<MarketAssetModel>> searchAssets(String query, String token) async {
    final uri = Uri.parse('$baseUrl/api/assets/search?query=${Uri.encodeComponent(query)}');
    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((item) => MarketAssetModel.fromJson(item)).toList();
    } else {
      _handleError(response);
    }
  }

  Future<AssetDetailsModel> getAssetDetails(String ticker, String token) async {
    final uri = Uri.parse('$baseUrl/api/assets/details/${Uri.encodeComponent(ticker)}');
    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return AssetDetailsModel.fromJson(data);
    } else {
      _handleError(response);
    }
  }

  Never _handleError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final message = body['message'] ?? 'Request failed';
      final retryable = body['retryable'] ?? false;
      throw AssetsServerException(message: message.toString(), retryable: retryable);
    } catch (e) {
      if (e is AssetsServerException) rethrow;
      throw AssetsServerException(
        message: 'Network error (status ${response.statusCode})',
        retryable: response.statusCode == 429 || response.statusCode >= 500,
      );
    }
  }
}

class AssetsServerException implements Exception {
  final String message;
  final bool retryable;

  AssetsServerException({
    required this.message,
    required this.retryable,
  });

  @override
  String toString() => message;
}
