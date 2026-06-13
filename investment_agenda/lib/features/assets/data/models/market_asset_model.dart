import '../../domain/entities/market_asset.dart';

class MarketAssetModel extends MarketAsset {
  const MarketAssetModel({
    required super.symbol,
    required super.name,
  });

  factory MarketAssetModel.fromJson(Map<String, dynamic> json) {
    return MarketAssetModel(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
    };
  }
}
