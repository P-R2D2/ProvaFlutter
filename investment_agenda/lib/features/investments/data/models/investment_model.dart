import '../../domain/entities/investment_entity.dart';

class InvestmentModel extends InvestmentEntity {
  const InvestmentModel({
    required super.id,
    required super.name,
    required super.assetType,
    required super.quantity,
    required super.purchasePrice,
    required super.purchaseDate,
    required super.portfolioId,
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentModel(
      id: json['id'],
      name: json['name'],
      assetType: AssetTypeExtension.fromString(json['assetType']),
      quantity: (json['quantity'] as num).toDouble(),
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate']),
      portfolioId: json['portfolioId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'assetType': assetType.value,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate.toIso8601String(),
      'portfolioId': portfolioId,
    };
  }
}
