class Investment {
  final String id;
  final String name;
  final double amountInvested;
  final double monthlyReturn;

  Investment({
    required this.id,
    required this.name,
    required this.amountInvested,
    required this.monthlyReturn,
  });

  Investment copyWith({
    String? id,
    String? name,
    double? amountInvested,
    double? monthlyReturn,
  }) {
    return Investment(
      id: id ?? this.id,
      name: name ?? this.name,
      amountInvested: amountInvested ?? this.amountInvested,
      monthlyReturn: monthlyReturn ?? this.monthlyReturn,
    );
  }
}
