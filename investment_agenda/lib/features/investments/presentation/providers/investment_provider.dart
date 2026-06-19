import 'package:flutter/material.dart';
import '../../domain/entities/investment.dart';
import '../../domain/repositories/investment_repository.dart';

class InvestmentProvider extends ChangeNotifier {
  final InvestmentRepository repository;

  InvestmentProvider({required this.repository});

  List<Investment> _investments = [];
  PortfolioSummary _summary = PortfolioSummary.empty();
  bool _isLoading = false;
  String? _errorMessage;

  List<Investment> get investments => _investments;
  PortfolioSummary get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadInvestments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await repository.getPortfolioValuation();
      _investments = data.positions;
      _summary = data.summary;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addInvestment(
    String portfolioId,
    String symbol,
    String assetType,
    double quantity,
    double purchasePrice,
    DateTime purchaseDate,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.addInvestment(portfolioId, symbol, assetType, quantity, purchasePrice, purchaseDate);
      await loadInvestments();
      return null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<String?> deleteInvestment(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deleteInvestment(id);
      await loadInvestments();
      return null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return _errorMessage;
    }
  }
}
