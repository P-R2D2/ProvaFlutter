import '../entities/investment.dart';

class PortfolioValuationData {
  final List<Investment> positions;
  final PortfolioSummary summary;

  PortfolioValuationData({
    required this.positions,
    required this.summary,
  });
}

abstract class InvestmentRepository {
  Future<PortfolioValuationData> getPortfolioValuation();
  Future<void> addInvestment(String symbol, double quantity, double averagePurchasePrice);
  Future<void> deleteInvestment(String id);
}
