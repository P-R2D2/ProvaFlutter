import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';

class PortfolioListPage extends StatefulWidget {
  const PortfolioListPage({super.key});

  @override
  State<PortfolioListPage> createState() => _PortfolioListPageState();
}

class _PortfolioListPageState extends State<PortfolioListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioProvider>().fetchPortfolios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Carteiras'),
      ),
      body: Consumer<PortfolioProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Erro: ${provider.error}'));
          }

          if (provider.portfolios.isEmpty) {
            return const Center(child: Text('Nenhuma carteira encontrada.'));
          }

          return ListView.builder(
            itemCount: provider.portfolios.length,
            itemBuilder: (context, index) {
              final portfolio = provider.portfolios[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text(portfolio.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${portfolio.investments.length} investimentos'),
                  children: portfolio.investments.isEmpty
                      ? [const Padding(padding: EdgeInsets.all(16.0), child: Text('Carteira vazia'))]
                      : portfolio.investments.map((inv) => ListTile(
                            title: Text(inv.name),
                            subtitle: Text('${inv.quantity} quotas @ R\$ ${inv.purchasePrice}'),
                            trailing: Text(inv.assetType.name.toUpperCase()),
                          )).toList(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create portfolio/investment
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
