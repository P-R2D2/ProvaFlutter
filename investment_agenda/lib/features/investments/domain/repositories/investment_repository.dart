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
  Future<void> addInvestment(String portfolioId, String symbol, String assetType, double quantity, double purchasePrice, DateTime purchaseDate);
  Future<void> deleteInvestment(String id);
}
