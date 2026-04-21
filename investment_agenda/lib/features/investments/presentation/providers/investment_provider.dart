import 'package:flutter/material.dart';
import '../../domain/entities/investment.dart';
import '../../domain/repositories/investment_repository.dart';

class InvestmentProvider extends ChangeNotifier {
  final InvestmentRepository repository;

  InvestmentProvider({required this.repository});

  List<Investment> _investments = [];
  bool _isLoading = false;

  List<Investment> get investments => _investments;
  bool get isLoading => _isLoading;

  double get totalInvested =>
      _investments.fold(0, (sum, item) => sum + item.amountInvested);

  Future<void> loadInvestments() async {
    _isLoading = true;
    notifyListeners();
    _investments = await repository.getInvestments();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addInvestment(Investment investment) async {
    await repository.addInvestment(investment);
    await loadInvestments();
  }

  Future<void> updateInvestment(Investment investment) async {
    await repository.updateInvestment(investment);
    await loadInvestments();
  }

  Future<void> deleteInvestment(String id) async {
    await repository.deleteInvestment(id);
    await loadInvestments();
  }
}
