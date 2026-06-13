import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/investment_provider.dart';
import '../../domain/entities/investment.dart';
import '../../../assets/presentation/providers/assets_provider.dart';

class InvestmentFormPage extends StatefulWidget {
  final Investment? investment;

  const InvestmentFormPage({super.key, this.investment});

  @override
  State<InvestmentFormPage> createState() => _InvestmentFormPageState();
}

class _InvestmentFormPageState extends State<InvestmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _symbolController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _symbolController = TextEditingController(text: widget.investment?.symbol ?? '');
    _quantityController = TextEditingController(
        text: widget.investment?.quantity.toString() ?? '');
    _priceController = TextEditingController(
        text: widget.investment?.averagePurchasePrice.toString() ?? '');
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _showAssetSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return _AssetSearchSelector(
              onAssetSelected: (symbol) {
                setState(() {
                  _symbolController.text = symbol;
                });
                Navigator.pop(context);
              },
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<InvestmentProvider>();
      
      final symbol = _symbolController.text.trim().toUpperCase();
      final quantity = double.parse(_quantityController.text);
      final price = double.parse(_priceController.text);

      final error = await provider.addInvestment(symbol, quantity, price);

      if (mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.investment == null
                  ? 'Posição registrada com sucesso'
                  : 'Posição atualizada com sucesso'),
            ),
          );
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.investment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Posição' : 'Adicionar Ativo B3'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _symbolController,
                    readOnly: isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Símbolo do Ativo (Ticker)',
                      hintText: 'e.g. PETR4, VALE3',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Digite o código do ativo'
                        : null,
                  ),
                ),
                if (!isEditing) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _showAssetSearchBottomSheet,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Buscar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                hintText: 'Quantidade adquirida (ex: 10.0)',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Digite a quantidade';
                final numVal = double.tryParse(value);
                if (numVal == null) return 'Digite um número válido';
                if (numVal <= 0) return 'A quantidade deve ser maior que zero';
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Preço Médio de Compra',
                prefixText: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Digite o preço médio';
                final numVal = double.tryParse(value);
                if (numVal == null) return 'Digite um número válido';
                if (numVal <= 0) return 'O preço médio deve ser maior que zero';
                return null;
              },
            ),
            const SizedBox(height: 40),
            Consumer<InvestmentProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Atualizar Posição' : 'Confirmar Registro'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetSearchSelector extends StatefulWidget {
  final ValueChanged<String> onAssetSelected;
  final ScrollController scrollController;

  const _AssetSearchSelector({
    required this.onAssetSelected,
    required this.scrollController,
  });

  @override
  State<_AssetSearchSelector> createState() => _AssetSearchSelectorState();
}

class _AssetSearchSelectorState extends State<_AssetSearchSelector> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<AssetsProvider>().search(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar ativo B3',
              hintText: 'e.g. PETR4, VALE3...',
              prefixIcon: Icon(Icons.search),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<AssetsProvider>(
              builder: (context, provider, child) {
                if (provider.isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_searchController.text.isEmpty) {
                  return const Center(child: Text('Pesquise por tickers da B3'));
                }

                if (provider.searchResults.isEmpty) {
                  return const Center(child: Text('Nenhum ativo encontrado'));
                }

                return ListView.builder(
                  controller: widget.scrollController,
                  itemCount: provider.searchResults.length,
                  itemBuilder: (context, index) {
                    final asset = provider.searchResults[index];
                    return ListTile(
                      title: Text(asset.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(asset.name),
                      trailing: const Icon(Icons.check, size: 16),
                      onTap: () => widget.onAssetSelected(asset.symbol),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
