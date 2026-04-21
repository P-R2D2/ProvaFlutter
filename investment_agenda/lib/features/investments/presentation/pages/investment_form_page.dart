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
                  ? 'Investment added'
                  : 'Investment updated')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.investment != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Investment' : 'Add Investment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Investment Name',
                hintText: 'e.g. S&P 500 Index',
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount Invested',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter an amount';
                if (double.tryParse(value) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _returnController,
              decoration: const InputDecoration(
                labelText: 'Monthly Return',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter return';
                if (double.tryParse(value) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? 'Update Investment' : 'Add Investment'),
            ),
          ],
        ),
      ),
    );
  }
}
