import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../portfolios/domain/entities/portfolio_entity.dart';
import '../models/portfolio_model.dart';
import '../../../../core/network/api_client.dart';

abstract class PortfolioRepository {
  Future<List<PortfolioEntity>> getPortfolios();
}

class PortfolioRepositoryImpl implements PortfolioRepository {
  final ApiClient apiClient;

  PortfolioRepositoryImpl({required this.apiClient});

  @override
  Future<List<PortfolioEntity>> getPortfolios() async {
    final response = await apiClient.get('/portfolios');
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => PortfolioModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load portfolios');
    }
  }
}
