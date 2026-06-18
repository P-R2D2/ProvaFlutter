import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/investment_entity.dart';
import '../../../portfolios/presentation/providers/portfolio_provider.dart';

class AddInvestmentPage extends StatefulWidget {
  final String portfolioId;

  const AddInvestmentPage({super.key, required this.portfolioId});

  @override
  State<AddInvestmentPage> createState() => _AddInvestmentPageState();
}

class _AddInvestmentPageState extends State<AddInvestmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  AssetType _selectedAssetType = AssetType.fixedIncome;
  DateTime _selectedDate = DateTime.now();

  bool _isSubmitting = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      final data = {
        'name': _nameController.text,
        'assetType': _selectedAssetType.value,
        'quantity': double.parse(_quantityController.text),
        'purchasePrice': double.parse(_priceController.text),
        'purchaseDate': _selectedDate.toIso8601String(),
      };

      final provider = context.read<PortfolioProvider>();
      final success = await provider.addInvestment(widget.portfolioId, data);
      
      setState(() => _isSubmitting = false);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Investimento adicionado com sucesso')));
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? 'Erro desconhecido')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Investimento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Ativo'),
                validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
              ),
              DropdownButtonFormField<AssetType>(
                value: _selectedAssetType,
                decoration: const InputDecoration(labelText: 'Tipo de Ativo'),
                items: AssetType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedAssetType = val);
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Campo obrigatório';
                  final num = double.tryParse(val);
                  if (num == null) return 'Valor inválido';
                  if (num <= 0) return 'Deve ser maior que zero';
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Preço de Compra (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Campo obrigatório';
                  final num = double.tryParse(val);
                  if (num == null) return 'Valor inválido';
                  if (num < 0) return 'Não pode ser negativo';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Data de Compra: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                    child: const Text('Alterar'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting ? const CircularProgressIndicator() : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
