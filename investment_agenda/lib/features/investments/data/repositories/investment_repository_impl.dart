import '../../domain/entities/investment.dart';
import '../../domain/repositories/investment_repository.dart';
import '../datasources/investments_remote_data_source.dart';

class InvestmentRepositoryImpl implements InvestmentRepository {
  final InvestmentsRemoteDataSource remoteDataSource;
  final Future<String> Function() getToken;

  InvestmentRepositoryImpl({
    required this.remoteDataSource,
    required this.getToken,
  });

  @override
  Future<PortfolioValuationData> getPortfolioValuation() async {
    final token = await getToken();
    final data = await remoteDataSource.getValuation(token);

    final summaryJson = data['summary'] as Map<String, dynamic>? ?? {};
    final summary = PortfolioSummary.fromJson(summaryJson);

    final positionsList = data['positions'] as List<dynamic>? ?? [];
    final positions = positionsList
        .map((item) => Investment.fromJson(item as Map<String, dynamic>))
        .toList();

    return PortfolioValuationData(
      positions: positions,
      summary: summary,
    );
  }

  @override
  Future<void> addInvestment(
    String portfolioId,
    String symbol,
    String assetType,
    double quantity,
    double purchasePrice,
    DateTime purchaseDate,
  ) async {
    final token = await getToken();
    await remoteDataSource.registerPosition(
      token,
      portfolioId,
      symbol,
      assetType,
      quantity,
      purchasePrice,
      purchaseDate,
    );
  }

  @override
  Future<void> deleteInvestment(String id) async {
    final token = await getToken();
    await remoteDataSource.deletePosition(token, id);
  }
}
