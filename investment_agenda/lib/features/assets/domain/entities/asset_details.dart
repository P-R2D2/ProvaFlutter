class AssetDetails {
  final String symbol;
  final String name;
  final double currentPrice;
  final double dayHigh;
  final double dayLow;
  final double changePercent;
  final String currency;
  final DateTime updatedAt;

  const AssetDetails({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.dayHigh,
    required this.dayLow,
    required this.changePercent,
    required this.currency,
    required this.updatedAt,
  });
}
