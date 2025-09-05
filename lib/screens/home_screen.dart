import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/savings_provider.dart';
import '../widgets/overview_card.dart';
import '../widgets/recent_expenses_list.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/savings_overview_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<ExpenseProvider>().loadExpenses(),
      context.read<BudgetProvider>().loadBudgets(),
      context.read<SavingsProvider>().loadSavingsGoals(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Finance Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              _buildWelcomeMessage(),
              const SizedBox(height: 24),
              
              // Overview cards
              _buildOverviewCards(),
              const SizedBox(height: 24),
              
              // Budget progress
              _buildBudgetSection(),
              const SizedBox(height: 24),
              
              // Savings overview
              _buildSavingsSection(),
              const SizedBox(height: 24),
              
              // Recent expenses
              _buildRecentExpensesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w300,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Let\'s track your finances today!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCards() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            OverviewCard(
              title: 'This Week',
              amount: expenseProvider.currentWeekTotal,
              icon: Icons.calendar_today,
              color: Colors.blue,
              subtitle: 'Spending',
            ),
            OverviewCard(
              title: 'This Month',
              amount: expenseProvider.currentMonthTotal,
              icon: Icons.calendar_month,
              color: Colors.green,
              subtitle: 'Spending',
            ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetSection() {
    return Consumer2<BudgetProvider, ExpenseProvider>(
      builder: (context, budgetProvider, expenseProvider, child) {
        final currentBudget = budgetProvider.currentBudget;
        final currentSpending = expenseProvider.currentMonthTotal;
        
        if (currentBudget == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Budget',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No budget set for this month',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to budget screen
                    },
                    child: const Text('Set Budget'),
                  ),
                ],
              ),
            ),
          );
        }

        return BudgetProgressCard(
          budget: currentBudget,
          currentSpending: currentSpending,
        );
      },
    );
  }

  Widget _buildSavingsSection() {
    return Consumer<SavingsProvider>(
      builder: (context, savingsProvider, child) {
        return SavingsOverviewCard(
          totalSaved: savingsProvider.totalSaved,
          totalTarget: savingsProvider.totalTarget,
          activeGoals: savingsProvider.activeGoals.length,
          completedGoals: savingsProvider.completedGoals.length,
        );
      },
    );
  }

  Widget _buildRecentExpensesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Expenses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to expenses screen
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const RecentExpensesList(),
      ],
    );
  }
}
