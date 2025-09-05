import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/savings_provider.dart';
import '../widgets/spending_chart.dart';
import '../widgets/category_pie_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'Last Month', 'This Year'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
      context.read<BudgetProvider>().loadBudgets();
      context.read<SavingsProvider>().loadSavingsGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ExpenseProvider>().loadExpenses();
              context.read<BudgetProvider>().loadBudgets();
              context.read<SavingsProvider>().loadSavingsGoals();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Period selector
          _buildPeriodSelector(),
          
          // Reports content
          Expanded(
            child: Consumer3<ExpenseProvider, BudgetProvider, SavingsProvider>(
              builder: (context, expenseProvider, budgetProvider, savingsProvider, child) {
                if (expenseProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary cards
                      _buildSummaryCards(expenseProvider, budgetProvider, savingsProvider),
                      const SizedBox(height: 24),
                      
                      // Spending trends chart
                      _buildSpendingTrendsChart(expenseProvider),
                      const SizedBox(height: 24),
                      
                      // Category breakdown
                      _buildCategoryBreakdown(expenseProvider),
                      const SizedBox(height: 24),
                      
                      // Budget vs actual
                      _buildBudgetVsActual(budgetProvider, expenseProvider),
                      const SizedBox(height: 24),
                      
                      // Savings progress
                      _buildSavingsProgress(savingsProvider),
                      const SizedBox(height: 24),
                      
                      // Insights and recommendations
                      _buildInsightsAndRecommendations(expenseProvider, budgetProvider, savingsProvider),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _periods.length,
        itemBuilder: (context, index) {
          final period = _periods[index];
          final isSelected = _selectedPeriod == period;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(ExpenseProvider expenseProvider, BudgetProvider budgetProvider, SavingsProvider savingsProvider) {
    final periodData = _getPeriodData(expenseProvider);
    
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
          'Total Spending',
          '\$${periodData['totalSpending'].toStringAsFixed(2)}',
          Icons.trending_down,
          Colors.red,
        ),
        _buildSummaryCard(
          'Daily Average',
          '\$${periodData['dailyAverage'].toStringAsFixed(2)}',
          Icons.calendar_today,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Highest Day',
          '\$${periodData['highestDay'].toStringAsFixed(2)}',
          Icons.arrow_upward,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Transactions',
          '${periodData['transactionCount']}',
          Icons.receipt,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingTrendsChart(ExpenseProvider expenseProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Trends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SpendingChart(
                period: _selectedPeriod,
                expenses: expenseProvider.expenses,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(ExpenseProvider expenseProvider) {
    final categoryData = _getCategoryData(expenseProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: CategoryPieChart(data: categoryData),
            ),
            const SizedBox(height: 16),
            _buildCategoryLegend(categoryData),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLegend(Map<String, double> categoryData) {
    final sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Column(
      children: sortedCategories.map((entry) {
        final category = entry.key;
        final amount = entry.value;
        final color = ExpenseCategory.categoryColors[category] ?? Colors.grey;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBudgetVsActual(BudgetProvider budgetProvider, ExpenseProvider expenseProvider) {
    final currentBudget = budgetProvider.currentBudget;
    final currentSpending = expenseProvider.currentMonthTotal;
    
    if (currentBudget == null) {
      return const SizedBox.shrink();
    }

    final progress = currentBudget.getProgress(currentSpending);
    final remaining = currentBudget.getRemaining(currentSpending);
    final isOver = currentBudget.isOverBudget(currentSpending);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget vs Actual',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBudgetStat(
                    'Budget',
                    '\$${currentBudget.amount.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBudgetStat(
                    'Spent',
                    '\$${currentSpending.toStringAsFixed(2)}',
                    Icons.shopping_cart,
                    isOver ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBudgetStat(
                    'Remaining',
                    '\$${remaining.toStringAsFixed(2)}',
                    Icons.savings,
                    remaining < 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver ? Colors.red : (progress >= 0.8 ? Colors.orange : Colors.green),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% of budget used',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetStat(String title, String value, IconData icon, Color color) {
    return Column(
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
    );
  }

  Widget _buildSavingsProgress(SavingsProvider savingsProvider) {
    final totalSaved = savingsProvider.totalSaved;
    final totalTarget = savingsProvider.totalTarget;
    
    if (totalTarget <= 0) {
      return const SizedBox.shrink();
    }

    final progress = savingsProvider.overallProgress;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Savings Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSavingsStat(
                    'Saved',
                    '\$${totalSaved.toStringAsFixed(2)}',
                    Icons.savings,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSavingsStat(
                    'Target',
                    '\$${totalTarget.toStringAsFixed(2)}',
                    Icons.flag,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSavingsStat(
                    'Progress',
                    '${(progress * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsStat(String title, String value, IconData icon, Color color) {
    return Column(
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
    );
  }

  Widget _buildInsightsAndRecommendations(ExpenseProvider expenseProvider, BudgetProvider budgetProvider, SavingsProvider savingsProvider) {
    final insights = _generateInsights(expenseProvider, budgetProvider, savingsProvider);
    
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
                  'Insights & Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => _buildInsightItem(insight)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String insight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getPeriodData(ExpenseProvider expenseProvider) {
    final now = DateTime.now();
    List<Expense> periodExpenses;
    
    switch (_selectedPeriod) {
      case 'This Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        periodExpenses = expenseProvider.expenses
            .where((expense) => expense.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                               expense.date.isBefore(endOfWeek.add(const Duration(days: 1))))
            .toList();
        break;
      case 'This Month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        periodExpenses = expenseProvider.expenses
            .where((expense) => expense.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
                               expense.date.isBefore(endOfMonth.add(const Duration(days: 1))))
            .toList();
        break;
      case 'Last Month':
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth = DateTime(now.year, now.month, 0);
        periodExpenses = expenseProvider.expenses
            .where((expense) => expense.date.isAfter(startOfLastMonth.subtract(const Duration(days: 1))) &&
                               expense.date.isBefore(endOfLastMonth.add(const Duration(days: 1))))
            .toList();
        break;
      case 'This Year':
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year, 12, 31);
        periodExpenses = expenseProvider.expenses
            .where((expense) => expense.date.isAfter(startOfYear.subtract(const Duration(days: 1))) &&
                               expense.date.isBefore(endOfYear.add(const Duration(days: 1))))
            .toList();
        break;
      default:
        periodExpenses = expenseProvider.expenses;
    }

    final totalSpending = periodExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final daysInPeriod = _getDaysInPeriod();
    final dailyAverage = daysInPeriod > 0 ? totalSpending / daysInPeriod : 0.0;
    
    // Group by date and find highest spending day
    final dailySpending = <DateTime, double>{};
    for (final expense in periodExpenses) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      dailySpending[date] = (dailySpending[date] ?? 0.0) + expense.amount;
    }
    
    final highestDay = dailySpending.values.isNotEmpty ? dailySpending.values.reduce((a, b) => a > b ? a : b) : 0.0;

    return {
      'totalSpending': totalSpending,
      'dailyAverage': dailyAverage,
      'highestDay': highestDay,
      'transactionCount': periodExpenses.length,
    };
  }

  Map<String, double> _getCategoryData(ExpenseProvider expenseProvider) {
    final periodData = _getPeriodData(expenseProvider);
    final periodExpenses = expenseProvider.expenses; // This should be filtered by period
    
    final Map<String, double> categoryTotals = {};
    for (final expense in periodExpenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }
    return categoryTotals;
  }

  int _getDaysInPeriod() {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'This Week':
        return 7;
      case 'This Month':
        return DateTime(now.year, now.month + 1, 0).day;
      case 'Last Month':
        return DateTime(now.year, now.month, 0).day;
      case 'This Year':
        return DateTime(now.year, 12, 31).difference(DateTime(now.year, 1, 1)).inDays + 1;
      default:
        return 30;
    }
  }

  List<String> _generateInsights(ExpenseProvider expenseProvider, BudgetProvider budgetProvider, SavingsProvider savingsProvider) {
    final insights = <String>[];
    
    // Spending insights
    final currentMonthTotal = expenseProvider.currentMonthTotal;
    final currentBudget = budgetProvider.currentBudget;
    
    if (currentBudget != null) {
      final progress = currentBudget.getProgress(currentMonthTotal);
      if (progress >= 0.9) {
        insights.add('You\'re close to your monthly budget limit. Consider reducing non-essential expenses.');
      } else if (progress <= 0.3) {
        insights.add('Great job! You\'re well under your budget. Consider increasing your savings.');
      }
    }
    
    // Category insights
    final categoryData = expenseProvider.currentMonthByCategory;
    if (categoryData.isNotEmpty) {
      final highestCategory = categoryData.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add('${highestCategory.key} is your highest spending category this month.');
    }
    
    // Savings insights
    final savingsProgress = savingsProvider.overallProgress;
    if (savingsProgress < 0.5) {
      insights.add('Your savings progress is below 50%. Consider setting smaller, achievable goals.');
    } else if (savingsProgress >= 0.8) {
      insights.add('Excellent savings progress! You\'re on track to reach your goals.');
    }
    
    if (insights.isEmpty) {
      insights.add('Keep up the good work with your financial management!');
    }
    
    return insights;
  }
}
