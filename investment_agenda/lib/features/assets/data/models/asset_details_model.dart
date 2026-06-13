import '../../domain/entities/asset_details.dart';

class AssetDetailsModel extends AssetDetails {
  const AssetDetailsModel({
    required super.symbol,
    required super.name,
    required super.currentPrice,
    required super.dayHigh,
    required super.dayLow,
    required super.changePercent,
    required super.currency,
    required super.updatedAt,
  });

  factory AssetDetailsModel.fromJson(Map<String, dynamic> json) {
    return AssetDetailsModel(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      dayHigh: (json['dayHigh'] as num?)?.toDouble() ?? 0.0,
      dayLow: (json['dayLow'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'BRL',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'currentPrice': currentPrice,
      'dayHigh': dayHigh,
      'dayLow': dayLow,
      'changePercent': changePercent,
      'currency': currency,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
