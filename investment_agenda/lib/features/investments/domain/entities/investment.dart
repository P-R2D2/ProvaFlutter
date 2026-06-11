class Investment {
  final String id;
  final String symbol;
  final String name;
  final double quantity;
  final double averagePurchasePrice;
  final double currentMarketPrice;
  final double investedAmount;
  final double currentPositionValue;
  final double profitLoss;
  final double profitLossPercentage;
  final bool isDelayed;

  Investment({
    required this.id,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.averagePurchasePrice,
    required this.currentMarketPrice,
    required this.investedAmount,
    required this.currentPositionValue,
    required this.profitLoss,
    required this.profitLossPercentage,
    required this.isDelayed,
  });

  Investment copyWith({
    String? id,
    String? symbol,
    String? name,
    double? quantity,
    double? averagePurchasePrice,
    double? currentMarketPrice,
    double? investedAmount,
    double? currentPositionValue,
    double? profitLoss,
    double? profitLossPercentage,
    bool? isDelayed,
  }) {
    return Investment(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      averagePurchasePrice: averagePurchasePrice ?? this.averagePurchasePrice,
      currentMarketPrice: currentMarketPrice ?? this.currentMarketPrice,
      investedAmount: investedAmount ?? this.investedAmount,
      currentPositionValue: currentPositionValue ?? this.currentPositionValue,
      profitLoss: profitLoss ?? this.profitLoss,
      profitLossPercentage: profitLossPercentage ?? this.profitLossPercentage,
      isDelayed: isDelayed ?? this.isDelayed,
    );
  }

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      averagePurchasePrice: (json['averagePurchasePrice'] as num?)?.toDouble() ?? 0.0,
      currentMarketPrice: (json['currentMarketPrice'] as num?)?.toDouble() ?? 0.0,
      investedAmount: (json['investedAmount'] as num?)?.toDouble() ?? 0.0,
      currentPositionValue: (json['currentPositionValue'] as num?)?.toDouble() ?? 0.0,
      profitLoss: (json['profitLoss'] as num?)?.toDouble() ?? 0.0,
      profitLossPercentage: (json['profitLossPercentage'] as num?)?.toDouble() ?? 0.0,
      isDelayed: json['isDelayed'] as bool? ?? false,
    );
  }
}

class PortfolioSummary {
  final double totalInvested;
  final double totalCurrentValue;
  final double totalProfitLoss;
  final double totalReturnPercentage;
  final bool isDelayed;

  PortfolioSummary({
    required this.totalInvested,
    required this.totalCurrentValue,
    required this.totalProfitLoss,
    required this.totalReturnPercentage,
    required this.isDelayed,
  });

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    return PortfolioSummary(
      totalInvested: (json['totalInvested'] as num?)?.toDouble() ?? 0.0,
      totalCurrentValue: (json['totalCurrentValue'] as num?)?.toDouble() ?? 0.0,
      totalProfitLoss: (json['totalProfitLoss'] as num?)?.toDouble() ?? 0.0,
      totalReturnPercentage: (json['totalReturnPercentage'] as num?)?.toDouble() ?? 0.0,
      isDelayed: json['isDelayed'] as bool? ?? false,
    );
  }

  factory PortfolioSummary.empty() {
    return PortfolioSummary(
      totalInvested: 0.0,
      totalCurrentValue: 0.0,
      totalProfitLoss: 0.0,
      totalReturnPercentage: 0.0,
      isDelayed: false,
    );
  }
}
