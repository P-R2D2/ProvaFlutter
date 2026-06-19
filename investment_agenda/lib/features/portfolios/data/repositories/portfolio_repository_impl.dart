import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../portfolios/domain/entities/portfolio_entity.dart';
import '../models/portfolio_model.dart';


abstract class PortfolioRepository {
  Future<List<PortfolioEntity>> getPortfolios();
  Future<PortfolioEntity> createPortfolio(String name, String? description);
}

class PortfolioRepositoryImpl implements PortfolioRepository {
  final String baseUrl;
  final http.Client client;
  final Future<String> Function() getToken;

  PortfolioRepositoryImpl({
    this.baseUrl = 'http://localhost:3000',
    http.Client? client,
    required this.getToken,
  }) : client = client ?? http.Client();

  @override
  Future<List<PortfolioEntity>> getPortfolios() async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/portfolios');
    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => PortfolioModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load portfolios: ${response.body}');
    }
  }

  @override
  Future<PortfolioEntity> createPortfolio(String name, String? description) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/portfolios');
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        if (description != null) 'description': description,
      }),
    );

    if (response.statusCode == 201) {
      return PortfolioModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create portfolio: ${response.body}');
    }
  }
}
