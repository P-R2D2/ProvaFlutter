import '../entities/investment.dart';

abstract class InvestmentRepository {
  Future<List<Investment>> getInvestments();
  Future<void> addInvestment(Investment investment);
  Future<void> updateInvestment(Investment investment);
  Future<void> deleteInvestment(String id);
}
