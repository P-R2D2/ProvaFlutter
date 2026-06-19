import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../portfolios/domain/entities/portfolio_entity.dart';
import '../../data/repositories/portfolio_repository_impl.dart';

class PortfolioProvider with ChangeNotifier {
  final PortfolioRepository repository;
  
  List<PortfolioEntity> _portfolios = [];
  bool _isLoading = false;
  String? _error;

  PortfolioProvider({required this.repository});

  List<PortfolioEntity> get portfolios => _portfolios;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPortfolios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _portfolios = await repository.getPortfolios();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PortfolioEntity?> createPortfolio(String name, [String? description]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPortfolio = await repository.createPortfolio(name, description);
      _portfolios.add(newPortfolio);
      _isLoading = false;
      notifyListeners();
      return newPortfolio;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> addInvestment(String portfolioId, Map<String, dynamic> data) async {
    // Ideally use InvestmentRepository, but since provider holds state, we do it here.
    try {
      final repoImpl = repository as PortfolioRepositoryImpl;
      final client = repoImpl.client;
      final baseUrl = repoImpl.baseUrl;
      final token = await repoImpl.getToken();
      data['portfolioId'] = portfolioId;
      final response = await client.post(
        Uri.parse('$baseUrl/portfolios/$portfolioId/investments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        // Refresh portfolios to get updated data
        await fetchPortfolios();
        return true;
      } else {
        _error = 'Failed to add investment: ${response.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
