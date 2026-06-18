enum AssetType {
  fixedIncome,
  stock,
  crypto,
  other
}

extension AssetTypeExtension on AssetType {
  String get value {
    switch (this) {
      case AssetType.fixedIncome:
        return 'FIXED_INCOME';
      case AssetType.stock:
        return 'STOCK';
      case AssetType.crypto:
        return 'CRYPTO';
      case AssetType.other:
        return 'OTHER';
    }
  }

  static AssetType fromString(String value) {
    switch (value) {
      case 'FIXED_INCOME':
        return AssetType.fixedIncome;
      case 'STOCK':
        return AssetType.stock;
      case 'CRYPTO':
        return AssetType.crypto;
      default:
        return AssetType.other;
    }
  }
}

class InvestmentEntity {
  final String id;
  final String name;
  final AssetType assetType;
  final double quantity;
  final double purchasePrice;
  final DateTime purchaseDate;
  final String portfolioId;

  const InvestmentEntity({
    required this.id,
    required this.name,
    required this.assetType,
    required this.quantity,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.portfolioId,
  });
}
