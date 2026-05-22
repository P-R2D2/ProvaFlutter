import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import '../providers/investment_provider.dart';
import '../../domain/entities/investment.dart';

class InvestmentFormPage extends StatefulWidget {
  final Investment? investment;

  const InvestmentFormPage({super.key, this.investment});

  @override
  State<InvestmentFormPage> createState() => _InvestmentFormPageState();
}

class _InvestmentFormPageState extends State<InvestmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _returnController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.investment?.name ?? '');
    _amountController = TextEditingController(
        text: widget.investment?.amountInvested.toString() ?? '');
    _returnController = TextEditingController(
        text: widget.investment?.monthlyReturn.toString() ?? '');
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<InvestmentProvider>();
      final investment = Investment(
        id: widget.investment?.id ?? const Uuid().v4(),
        name: _nameController.text,
        amountInvested: double.parse(_amountController.text),
        monthlyReturn: double.parse(_returnController.text),
      );

      if (widget.investment == null) {
        await provider.addInvestment(investment);
      } else {
        await provider.updateInvestment(investment);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.investment == null
                  ? 'Investimento adicionado'
                  : 'Investimento atualizado')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.investment != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Investimento' : 'Adicionar Investimento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Investimento',
                hintText: 'e.g. Tesouro Direto',
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Digite o nome do investimento' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Valor Investido',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Digite o valor investido';
                if (double.tryParse(value) == null) return 'Digite um número válido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _returnController,
              decoration: const InputDecoration(
                labelText: 'Rendimento Mensal',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Digite o rendimento mensal';
                if (double.tryParse(value) == null) return 'Digite um número válido';
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? 'Atualizar Investimento' : 'Adicionar Investimento'),
            ),
          ],
        ),
      ),
    );
  }
}
