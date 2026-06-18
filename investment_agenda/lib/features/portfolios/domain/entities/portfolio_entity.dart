import 'package:investment_agenda/features/investments/domain/entities/investment_entity.dart';

class PortfolioEntity {
  final String id;
  final String name;
  final String userId;
  final List<InvestmentEntity> investments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PortfolioEntity({
    required this.id,
    required this.name,
    required this.userId,
    this.investments = const [],
    required this.createdAt,
    required this.updatedAt,
  });
}
