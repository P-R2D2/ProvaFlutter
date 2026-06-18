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

  Future<bool> addInvestment(String portfolioId, Map<String, dynamic> data) async {
    // Ideally use InvestmentRepository, but since provider holds state, we do it here.
    try {
      final apiClient = (repository as PortfolioRepositoryImpl).apiClient;
      data['portfolioId'] = portfolioId;
      final response = await apiClient.post('/investments', data);
      
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
