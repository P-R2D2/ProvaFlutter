import '../../domain/entities/investment.dart';
import '../../domain/repositories/investment_repository.dart';

class InvestmentRepositoryImpl implements InvestmentRepository {
  final List<Investment> _investments = [];

  @override
  Future<List<Investment>> getInvestments() async {
    return List.unmodifiable(_investments);
  }

  @override
  Future<void> addInvestment(Investment investment) async {
    _investments.add(investment);
  }

  @override
  Future<void> updateInvestment(Investment investment) async {
    final index = _investments.indexWhere((item) => item.id == investment.id);
    if (index != -1) {
      _investments[index] = investment;
    }
  }

  @override
  Future<void> deleteInvestment(String id) async {
    _investments.removeWhere((item) => item.id == id);
  }
}
