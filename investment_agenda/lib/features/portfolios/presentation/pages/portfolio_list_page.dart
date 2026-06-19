import 'dart:ui';
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

  void _showCreatePortfolioDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Carteira'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nome da Carteira'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final provider = context.read<PortfolioProvider>();
              final newPortfolio = await provider.createPortfolio(nameController.text.trim());
              if (newPortfolio != null && mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePortfolioDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nova Carteira'),
      ),
      body: Consumer<PortfolioProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.portfolios.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.portfolios.isEmpty) {
            return Center(child: Text('Erro: ${provider.error}'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text(
                  'Minhas Carteiras',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => provider.fetchPortfolios(),
                  )
                ],
              ),
              if (provider.portfolios.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Você ainda não possui carteiras.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final portfolio = provider.portfolios[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.transparent,
                                  ),
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    title: Text(
                                      portfolio.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${portfolio.investments.length} ativos',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    children: [
                                      if (portfolio.investments.isEmpty)
                                        const Padding(
                                          padding: EdgeInsets.all(24.0),
                                          child: Text('Carteira vazia'),
                                        )
                                      else
                                        ...portfolio.investments.map((inv) {
                                          return ListTile(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                            title: Text(
                                              inv.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(
                                              '${inv.quantity} un. @ R\$ ${inv.purchasePrice.toStringAsFixed(2)}',
                                            ),
                                            trailing: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                inv.assetType.name.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: provider.portfolios.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
