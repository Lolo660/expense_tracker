import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';
import '../models/budget.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/add_budget_dialog.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadBudgets();
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BudgetProvider>().loadBudgets();
              context.read<ExpenseProvider>().loadExpenses();
            },
          ),
        ],
      ),
      body: Consumer2<BudgetProvider, ExpenseProvider>(
        builder: (context, budgetProvider, expenseProvider, child) {
          if (budgetProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (budgetProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${budgetProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () => budgetProvider.loadBudgets(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current month budget overview
                _buildCurrentMonthOverview(budgetProvider, expenseProvider),
                const SizedBox(height: 24),
                
                // Budget history
                _buildBudgetHistory(budgetProvider),
                const SizedBox(height: 24),
                
                // Budget tips
                _buildBudgetTips(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBudgetDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCurrentMonthOverview(BudgetProvider budgetProvider, ExpenseProvider expenseProvider) {
    final currentBudget = budgetProvider.currentBudget;
    final currentSpending = expenseProvider.currentMonthTotal;
    
    if (currentBudget == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Budget Set',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Set a monthly budget to track your spending',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAddBudgetDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Set Monthly Budget'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Month Budget',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        BudgetProgressCard(
          budget: currentBudget,
          currentSpending: currentSpending,
        ),
        const SizedBox(height: 16),
        _buildBudgetStats(currentBudget, currentSpending),
      ],
    );
  }

  Widget _buildBudgetStats(Budget budget, double currentSpending) {
    final progress = budget.getProgress(currentSpending);
    final remaining = budget.getRemaining(currentSpending);
    final isOver = budget.isOverBudget(currentSpending);
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Progress',
            '${(progress * 100).toStringAsFixed(1)}%',
            progress >= 0.8 ? Colors.orange : Colors.green,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Remaining',
            '\$${remaining.toStringAsFixed(2)}',
            isOver ? Colors.red : Colors.blue,
            Icons.account_balance_wallet,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Status',
            isOver ? 'Over Budget' : 'On Track',
            isOver ? Colors.red : Colors.green,
            isOver ? Icons.warning : Icons.check_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetHistory(BudgetProvider budgetProvider) {
    final budgets = budgetProvider.budgets;
    
    if (budgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: budgets.length,
          itemBuilder: (context, index) {
            final budget = budgets[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: budget.isActive 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey,
                  child: Icon(
                    budget.isActive ? Icons.check : Icons.history,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  '${budget.month} ${budget.year}',
                  style: TextStyle(
                    fontWeight: budget.isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  'Budget: \$${budget.amount.toStringAsFixed(2)}',
                ),
                trailing: budget.isActive
                    ? Chip(
                        label: const Text('Active'),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : null,
                onTap: () => _showEditBudgetDialog(budget),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBudgetTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.amber[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Budget Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              'Track your expenses regularly to stay within budget',
              Icons.track_changes,
            ),
            _buildTipItem(
              'Set realistic budgets based on your income and needs',
              Icons.smart_toy,
            ),
            _buildTipItem(
              'Use the 50/30/20 rule: 50% needs, 30% wants, 20% savings',
              Icons.pie_chart,
            ),
            _buildTipItem(
              'Review and adjust your budget monthly',
              Icons.edit_calendar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddBudgetDialog(),
    );
  }

  void _showEditBudgetDialog(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(budget: budget),
    );
  }
}
