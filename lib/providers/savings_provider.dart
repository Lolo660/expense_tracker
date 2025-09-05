import 'package:flutter/foundation.dart';
import '../models/savings.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class SavingsProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  final NotificationService _notificationService = NotificationService.instance;
  
  List<SavingsGoal> _savingsGoals = [];
  bool _isLoading = false;
  String? _error;

  List<SavingsGoal> get savingsGoals => _savingsGoals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get active (non-completed) savings goals
  List<SavingsGoal> get activeGoals {
    return _savingsGoals.where((goal) => !goal.isCompleted).toList();
  }

  // Get completed savings goals
  List<SavingsGoal> get completedGoals {
    return _savingsGoals.where((goal) => goal.isCompleted).toList();
  }

  // Get overdue goals
  List<SavingsGoal> get overdueGoals {
    return _savingsGoals.where((goal) => goal.isOverdue).toList();
  }

  // Get total saved amount across all goals
  double get totalSaved {
    return _savingsGoals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
  }

  // Get total target amount across all active goals
  double get totalTarget {
    return activeGoals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
  }

  // Get overall progress percentage
  double get overallProgress {
    if (totalTarget <= 0) return 0.0;
    return (totalSaved / totalTarget).clamp(0.0, 1.0);
  }

  Future<void> loadSavingsGoals() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _savingsGoals = await _databaseService.getAllSavingsGoals();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load savings goals: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    try {
      _error = null;
      final id = await _databaseService.insertSavingsGoal(goal);
      final newGoal = goal.copyWith(id: id);
      _savingsGoals.add(newGoal);
      
      // Schedule reminder for the goal
      await _scheduleGoalReminder(newGoal);
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add savings goal: $e';
      notifyListeners();
    }
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    try {
      _error = null;
      await _databaseService.updateSavingsGoal(goal);
      
      final index = _savingsGoals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _savingsGoals[index] = goal;
      }
      
      // Update reminder if needed
      await _scheduleGoalReminder(goal);
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update savings goal: $e';
      notifyListeners();
    }
  }

  Future<void> deleteSavingsGoal(int id) async {
    try {
      _error = null;
      await _databaseService.deleteSavingsGoal(id);
      _savingsGoals.removeWhere((goal) => goal.id == id);
      
      // Cancel any scheduled reminders
      await _notificationService.cancelNotification(id);
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete savings goal: $e';
      notifyListeners();
    }
  }

  Future<void> updateGoalProgress(int goalId, double newAmount) async {
    try {
      _error = null;
      final goal = _savingsGoals.firstWhere((g) => g.id == goalId);
      final updatedGoal = goal.copyWith(currentAmount: newAmount);
      
      await _databaseService.updateSavingsGoal(updatedGoal);
      
      final index = _savingsGoals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _savingsGoals[index] = updatedGoal;
      }
      
      // Check if goal is completed
      if (newAmount >= goal.targetAmount && !goal.isCompleted) {
        await _markGoalAsCompleted(updatedGoal);
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update goal progress: $e';
      notifyListeners();
    }
  }

  Future<void> _markGoalAsCompleted(SavingsGoal goal) async {
    final completedGoal = goal.copyWith(isCompleted: true);
    await _databaseService.updateSavingsGoal(completedGoal);
    
    // Show completion notification
    await _notificationService.showSavingsReminder(
      title: 'Goal Achieved! 🎉',
      body: 'Congratulations! You have reached your savings goal: ${goal.title}',
      payload: 'goal_completed',
    );
    
    // Cancel any scheduled reminders
    await _notificationService.cancelNotification(goal.id!);
  }

  Future<void> _scheduleGoalReminder(SavingsGoal goal) async {
    if (goal.isCompleted) return;
    
    // Schedule reminder for 1 week before target date
    final reminderDate = goal.targetDate.subtract(const Duration(days: 7));
    
    if (reminderDate.isAfter(DateTime.now())) {
      await _notificationService.scheduleSavingsReminder(
        title: 'Savings Goal Reminder',
        body: 'Your goal "${goal.title}" is due in 1 week. Current progress: ${(goal.getProgress() * 100).toStringAsFixed(1)}%',
        scheduledDate: reminderDate,
        payload: 'goal_reminder_${goal.id}',
      );
    }
    
    // Schedule daily reminder if goal is overdue
    if (goal.isOverdue) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await _notificationService.scheduleSavingsReminder(
        title: 'Overdue Goal Alert',
        body: 'Your goal "${goal.title}" is overdue. Consider adjusting your target or increasing contributions.',
        scheduledDate: tomorrow,
        payload: 'goal_overdue_${goal.id}',
      );
    }
  }

  // Get goals by progress status
  List<SavingsGoal> getGoalsByProgress(double minProgress, double maxProgress) {
    return _savingsGoals.where((goal) {
      final progress = goal.getProgress();
      return progress >= minProgress && progress <= maxProgress;
    }).toList();
  }

  // Get goals due within specified days
  List<SavingsGoal> getGoalsDueWithinDays(int days) {
    final deadline = DateTime.now().add(Duration(days: days));
    return _savingsGoals.where((goal) => 
        goal.targetDate.isBefore(deadline) && !goal.isCompleted).toList();
  }

  // Get goals by category (if you want to add categories later)
  List<SavingsGoal> getGoalsByCategory(String category) {
    // For now, return all goals. You can extend this later
    return _savingsGoals;
  }

  // Calculate monthly contribution needed for a goal
  double getMonthlyContributionNeeded(SavingsGoal goal) {
    if (goal.isCompleted) return 0.0;
    
    final remaining = goal.getRemaining();
    final monthsRemaining = goal.daysRemaining / 30.0;
    
    if (monthsRemaining <= 0) return remaining;
    return remaining / monthsRemaining;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check all goals and send appropriate notifications
  Future<void> checkAllGoals() async {
    for (final goal in activeGoals) {
      if (goal.isOverdue) {
        await _notificationService.showSavingsReminder(
          title: 'Goal Overdue',
          body: 'Your goal "${goal.title}" is overdue. Consider extending the deadline or adjusting the target.',
          payload: 'goal_overdue_${goal.id}',
        );
      } else if (goal.daysRemaining <= 7) {
        await _notificationService.showSavingsReminder(
          title: 'Goal Due Soon',
          body: 'Your goal "${goal.title}" is due in ${goal.daysRemaining} days. Current progress: ${(goal.getProgress() * 100).toStringAsFixed(1)}%',
          payload: 'goal_due_soon_${goal.id}',
        );
      }
    }
  }
}
