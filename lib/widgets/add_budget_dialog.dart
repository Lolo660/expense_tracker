import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../providers/budget_provider.dart';

class AddBudgetDialog extends StatefulWidget {
  final Budget? budget;

  const AddBudgetDialog({
    super.key,
    this.budget,
  });

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  String _selectedMonth = BudgetMonth.getCurrentMonth();
  int _selectedYear = BudgetMonth.getCurrentYear();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _amountController.text = widget.budget!.amount.toString();
      _selectedMonth = widget.budget!.month;
      _selectedYear = widget.budget!.year;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.budget != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Budget' : 'Set Monthly Budget'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Amount field
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monthly Budget Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
                helperText: 'Enter your monthly spending limit',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a budget amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Month dropdown
            DropdownButtonFormField<String>(
              value: _selectedMonth,
              decoration: const InputDecoration(
                labelText: 'Month',
                border: OutlineInputBorder(),
              ),
              items: BudgetMonth.months.map((month) {
                return DropdownMenuItem(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a month';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Year dropdown
            DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
              ),
              items: List.generate(5, (index) {
                final year = DateTime.now().year - 2 + index;
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value!;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a year';
                }
                return null;
              },
            ),
            
            if (isEditing) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Note: Only one budget can be active per month. Setting this budget will deactivate any existing budget for ${_selectedMonth} $_selectedYear.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveBudget,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);

      if (widget.budget != null) {
        // Update existing budget
        final updatedBudget = widget.budget!.copyWith(
          amount: amount,
          month: _selectedMonth,
          year: _selectedYear,
        );
        
        await context.read<BudgetProvider>().updateBudget(updatedBudget);
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Budget updated successfully')),
          );
        }
      } else {
        // Create new budget
        final newBudget = Budget(
          amount: amount,
          month: _selectedMonth,
          year: _selectedYear,
          createdAt: DateTime.now(),
          isActive: true,
        );
        
        await context.read<BudgetProvider>().addBudget(newBudget);
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Budget set successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
