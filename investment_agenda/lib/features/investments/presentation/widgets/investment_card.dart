import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/investment.dart';

class InvestmentCard extends StatelessWidget {
  final Investment investment;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const InvestmentCard({
    super.key,
    required this.investment,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    );
    final percentFormat = NumberFormat.decimalPercentPattern(
      locale: 'pt_BR',
      decimalDigits: 2,
    );

    final isProfit = investment.profitLoss >= 0;
    final color = isProfit ? Colors.greenAccent : Colors.redAccent;
    final sign = isProfit ? '+' : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        investment.symbol,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (investment.isDelayed)
                      const Tooltip(
                        message: 'Preço atrasado devido a instabilidade no mercado',
                        child: Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: onDelete,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              investment.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const Divider(height: 24, thickness: 0.5, color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${investment.quantity.toStringAsFixed(2)} un  •  Mkt: ${currencyFormat.format(investment.currentMarketPrice)}',
                      style: const TextStyle(fontSize: 13, color: Colors.white54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Avg. Cost: ${currencyFormat.format(investment.averagePurchasePrice)}',
                      style: const TextStyle(fontSize: 13, color: Colors.white54),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(investment.currentPositionValue),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$sign${currencyFormat.format(investment.profitLoss)} ($sign${(investment.profitLossPercentage / 100).toStringAsFixed(2)}%)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
