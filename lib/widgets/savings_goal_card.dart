import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/savings.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Function(double)? onUpdateProgress;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onDelete,
    this.onUpdateProgress,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.getProgress();
    final remaining = goal.getRemaining();
    final daysRemaining = goal.daysRemaining;
    
    Color progressColor;
    if (goal.isOverdue) {
      progressColor = Colors.red;
    } else if (progress >= 0.8) {
      progressColor = Colors.green;
    } else if (progress >= 0.5) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.blue;
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          goal.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: onDelete,
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Amount details
              Row(
                children: [
                  Expanded(
                    child: _buildAmountInfo(
                      'Saved',
                      '\$${goal.currentAmount.toStringAsFixed(2)}',
                      Icons.savings,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAmountInfo(
                      'Target',
                      '\$${goal.targetAmount.toStringAsFixed(2)}',
                      Icons.flag,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAmountInfo(
                      'Remaining',
                      '\$${remaining.toStringAsFixed(2)}',
                      Icons.trending_up,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Status and date info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target Date',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(goal.targetDate),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          goal.isOverdue ? 'Overdue' : 'Days Left',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          goal.isOverdue 
                              ? '${daysRemaining.abs()} days'
                              : '$daysRemaining days',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: goal.isOverdue ? Colors.red : progressColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Progress update section
              if (onUpdateProgress != null && !goal.isCompleted) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Progress',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: goal.currentAmount.toString(),
                              decoration: const InputDecoration(
                                labelText: 'New Amount',
                                prefixText: '\$',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              onFieldSubmitted: (value) {
                                final newAmount = double.tryParse(value);
                                if (newAmount != null && newAmount >= 0) {
                                  onUpdateProgress!(newAmount);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              final controller = TextEditingController();
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Update Progress'),
                                  content: TextFormField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      labelText: 'New Amount',
                                      prefixText: '\$',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    autofocus: true,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        final newAmount = double.tryParse(controller.text);
                                        if (newAmount != null && newAmount >= 0) {
                                          Navigator.of(context).pop();
                                          onUpdateProgress!(newAmount);
                                        }
                                      },
                                      child: const Text('Update'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Update'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              
              // Note section
              if (goal.note != null && goal.note!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal.note!,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
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
    );
  }

  Widget _buildAmountInfo(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
