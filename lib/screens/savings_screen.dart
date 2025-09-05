import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/savings_provider.dart';
import '../models/savings.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/add_savings_goal_dialog.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsProvider>().loadSavingsGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SavingsProvider>().loadSavingsGoals();
            },
          ),
        ],
      ),
      body: Consumer<SavingsProvider>(
        builder: (context, savingsProvider, child) {
          if (savingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (savingsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${savingsProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () => savingsProvider.loadSavingsGoals(),
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
                // Overview cards
                _buildOverviewCards(savingsProvider),
                const SizedBox(height: 24),
                
                // Active goals
                _buildActiveGoals(savingsProvider),
                const SizedBox(height: 24),
                
                // Completed goals
                if (savingsProvider.completedGoals.isNotEmpty) ...[
                  _buildCompletedGoals(savingsProvider),
                  const SizedBox(height: 24),
                ],
                
                // Savings tips
                _buildSavingsTips(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSavingsGoalDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOverviewCards(SavingsProvider savingsProvider) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildOverviewCard(
          'Total Saved',
          '\$${savingsProvider.totalSaved.toStringAsFixed(2)}',
          Icons.savings,
          Colors.green,
        ),
        _buildOverviewCard(
          'Total Target',
          '\$${savingsProvider.totalTarget.toStringAsFixed(2)}',
          Icons.flag,
          Colors.blue,
        ),
        _buildOverviewCard(
          'Active Goals',
          '${savingsProvider.activeGoals.length}',
          Icons.track_changes,
          Colors.orange,
        ),
        _buildOverviewCard(
          'Completed',
          '${savingsProvider.completedGoals.length}',
          Icons.check_circle,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  Widget _buildActiveGoals(SavingsProvider savingsProvider) {
    final activeGoals = savingsProvider.activeGoals;
    
    if (activeGoals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.savings,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Savings Goals',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Create your first savings goal to start building wealth',
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
                  onPressed: _showAddSavingsGoalDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Savings Goal'),
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
          'Active Goals',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeGoals.length,
          itemBuilder: (context, index) {
            final goal = activeGoals[index];
            return SavingsGoalCard(
              goal: goal,
              onTap: () => _showEditSavingsGoalDialog(goal),
              onDelete: () => _deleteSavingsGoal(goal),
              onUpdateProgress: (newAmount) => _updateGoalProgress(goal, newAmount),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompletedGoals(SavingsProvider savingsProvider) {
    final completedGoals = savingsProvider.completedGoals;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completed Goals',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: completedGoals.length,
          itemBuilder: (context, index) {
            final goal = completedGoals[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                title: Text(
                  goal.title,
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
                subtitle: Text(
                  'Completed: ${DateFormat('MMM dd, yyyy').format(goal.targetDate)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  '\$${goal.targetAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSavingsTips() {
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
                  'Savings Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              'Pay yourself first - set aside money before spending',
              Icons.priority_high,
            ),
            _buildTipItem(
              'Use the 52-week challenge to build savings gradually',
              Icons.trending_up,
            ),
            _buildTipItem(
              'Automate your savings with recurring transfers',
              Icons.schedule,
            ),
            _buildTipItem(
              'Track your progress regularly to stay motivated',
              Icons.analytics,
            ),
            _buildTipItem(
              'Celebrate small wins to maintain momentum',
              Icons.celebration,
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

  void _showAddSavingsGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddSavingsGoalDialog(),
    );
  }

  void _showEditSavingsGoalDialog(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AddSavingsGoalDialog(goal: goal),
    );
  }

  Future<void> _deleteSavingsGoal(SavingsGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Savings Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<SavingsProvider>().deleteSavingsGoal(goal.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Savings goal deleted')),
        );
      }
    }
  }

  Future<void> _updateGoalProgress(SavingsGoal goal, double newAmount) async {
    await context.read<SavingsProvider>().updateGoalProgress(goal.id!, newAmount);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal progress updated')),
      );
    }
  }
}
