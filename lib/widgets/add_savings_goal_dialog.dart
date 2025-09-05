import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/savings.dart';
import '../providers/savings_provider.dart';

class AddSavingsGoalDialog extends StatefulWidget {
  final SavingsGoal? goal;

  const AddSavingsGoalDialog({
    super.key,
    this.goal,
  });

  @override
  State<AddSavingsGoalDialog> createState() => _AddSavingsGoalDialogState();
}

class _AddSavingsGoalDialogState extends State<AddSavingsGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  final _noteController = TextEditingController();
  
  DateTime _selectedTargetDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _titleController.text = widget.goal!.title;
      _descriptionController.text = widget.goal!.description;
      _targetAmountController.text = widget.goal!.targetAmount.toString();
      _currentAmountController.text = widget.goal!.currentAmount.toString();
      _noteController.text = widget.goal!.note ?? '';
      _selectedTargetDate = widget.goal!.targetDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goal != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Savings Goal' : 'Create New Savings Goal'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  border: OutlineInputBorder(),
                  helperText: 'e.g., Emergency Fund, Vacation Savings',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a goal title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  helperText: 'Describe what you\'re saving for',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Target amount field
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                  helperText: 'How much do you want to save?',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Current amount field
              TextFormField(
                controller: _currentAmountController,
                decoration: const InputDecoration(
                  labelText: 'Current Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                  helperText: 'How much have you saved so far?',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Please enter a valid amount';
                  }
                  
                  final targetAmount = double.tryParse(_targetAmountController.text);
                  if (targetAmount != null && amount > targetAmount) {
                    return 'Current amount cannot exceed target amount';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Target date picker
              InkWell(
                onTap: () => _selectTargetDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Target Date',
                    border: OutlineInputBorder(),
                    helperText: 'When do you want to reach your goal?',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(_selectedTargetDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Note field
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                  helperText: 'Additional notes or reminders',
                ),
                maxLines: 2,
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
                          'You can update your progress anytime by editing this goal.',
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveGoal,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _selectTargetDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)), // 5 years from now
    );
    if (picked != null && picked != _selectedTargetDate) {
      setState(() {
        _selectedTargetDate = picked;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final targetAmount = double.parse(_targetAmountController.text);
      final currentAmount = double.parse(_currentAmountController.text);
      final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

      if (widget.goal != null) {
        // Update existing goal
        final updatedGoal = widget.goal!.copyWith(
          title: title,
          description: description,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          targetDate: _selectedTargetDate,
          note: note,
        );
        
        await context.read<SavingsProvider>().updateSavingsGoal(updatedGoal);
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Savings goal updated successfully')),
          );
        }
      } else {
        // Create new goal
        final newGoal = SavingsGoal(
          title: title,
          description: description,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          targetDate: _selectedTargetDate,
          createdAt: DateTime.now(),
          note: note,
        );
        
        await context.read<SavingsProvider>().addSavingsGoal(newGoal);
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Savings goal created successfully')),
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
