import 'dart:convert';
import 'package:http/http.dart' as http;

class InvestmentsRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  InvestmentsRemoteDataSource({
    this.baseUrl = 'http://localhost:3000',
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<Map<String, dynamic>> getValuation(String token) async {
    final uri = Uri.parse('$baseUrl/api/investments');
    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      _handleError(response);
    }
  }

  Future<void> registerPosition(
    String token,
    String symbol,
    double quantity,
    double averagePurchasePrice,
  ) async {
    final uri = Uri.parse('$baseUrl/api/investments');
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'symbol': symbol,
        'quantity': quantity,
        'averagePurchasePrice': averagePurchasePrice,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      _handleError(response);
    }
  }

  Future<void> deletePosition(String token, String id) async {
    final uri = Uri.parse('$baseUrl/api/investments/$id');
    final response = await client.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      _handleError(response);
    }
  }

  Never _handleError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final message = body['message'] ?? 'Falha na requisição';
      throw InvestmentsServerException(message: message.toString());
    } catch (e) {
      if (e is InvestmentsServerException) rethrow;
      throw InvestmentsServerException(
        message: 'Erro de rede (status ${response.statusCode})',
      );
    }
  }
}

class InvestmentsServerException implements Exception {
  final String message;

  InvestmentsServerException({required this.message});

  @override
  String toString() => message;
}
