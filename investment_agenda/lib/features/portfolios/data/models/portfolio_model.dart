import '../../domain/entities/portfolio_entity.dart';
import '../../../investments/data/models/investment_model.dart';

class PortfolioModel extends PortfolioEntity {
  const PortfolioModel({
    required super.id,
    required super.name,
    required super.userId,
    super.investments,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id'],
      name: json['name'],
      userId: json['userId'],
      investments: json['investments'] != null
          ? (json['investments'] as List)
              .map((i) => InvestmentModel.fromJson(i))
              .toList()
          : [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'investments': investments.map((i) => (i as InvestmentModel).toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
