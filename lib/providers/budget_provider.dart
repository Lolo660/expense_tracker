import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class BudgetProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  final NotificationService _notificationService = NotificationService.instance;
  
  List<Budget> _budgets = [];
  Budget? _currentBudget;
  bool _isLoading = false;
  String? _error;

  List<Budget> get budgets => _budgets;
  Budget? get currentBudget => _currentBudget;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get current month spending progress
  double get currentMonthProgress {
    if (_currentBudget == null) return 0.0;
    // This will be calculated by combining with ExpenseProvider
    return 0.0;
  }

  // Get current month remaining budget
  double get currentMonthRemaining {
    if (_currentBudget == null) return 0.0;
    // This will be calculated by combining with ExpenseProvider
    return _currentBudget!.amount;
  }

  // Check if over budget
  bool get isOverBudget {
    if (_currentBudget == null) return false;
    // This will be calculated by combining with ExpenseProvider
    return false;
  }

  Future<void> loadBudgets() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _budgets = await _databaseService.getAllBudgets();
      _currentBudget = await _databaseService.getCurrentBudget();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load budgets: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      _error = null;
      
      // Deactivate other budgets for the same month/year
      if (budget.isActive) {
        for (final existingBudget in _budgets) {
          if (existingBudget.month == budget.month && 
              existingBudget.year == budget.year &&
              existingBudget.isActive) {
            await _databaseService.updateBudget(
              existingBudget.copyWith(isActive: false)
            );
          }
        }
      }
      
      final id = await _databaseService.insertBudget(budget);
      final newBudget = budget.copyWith(id: id);
      _budgets.add(newBudget);
      
      if (newBudget.isActive) {
        _currentBudget = newBudget;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add budget: $e';
      notifyListeners();
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      _error = null;
      await _databaseService.updateBudget(budget);
      
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
      }
      
      if (budget.isActive) {
        _currentBudget = budget;
      } else if (_currentBudget?.id == budget.id) {
        _currentBudget = null;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update budget: $e';
      notifyListeners();
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      _error = null;
      await _databaseService.deleteBudget(id);
      _budgets.removeWhere((budget) => budget.id == id);
      
      if (_currentBudget?.id == id) {
        _currentBudget = null;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete budget: $e';
      notifyListeners();
    }
  }

  Future<void> setCurrentBudget(Budget budget) async {
    try {
      _error = null;
      
      // Deactivate all other budgets
      for (final existingBudget in _budgets) {
        if (existingBudget.isActive) {
          await _databaseService.updateBudget(
            existingBudget.copyWith(isActive: false)
          );
        }
      }
      
      // Activate the selected budget
      final activeBudget = budget.copyWith(isActive: true);
      await _databaseService.updateBudget(activeBudget);
      
      // Update local state
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = activeBudget;
      }
      _currentBudget = activeBudget;
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to set current budget: $e';
      notifyListeners();
    }
  }

  // Check budget status and send notifications if needed
  Future<void> checkBudgetStatus(double currentSpending) async {
    if (_currentBudget == null) return;
    
    final progress = _currentBudget!.getProgress(currentSpending);
    final remaining = _currentBudget!.getRemaining(currentSpending);
    final isOver = _currentBudget!.isOverBudget(currentSpending);
    
    if (isOver) {
      await _notificationService.showBudgetAlert(
        title: 'Budget Exceeded!',
        body: 'You have exceeded your monthly budget of \$${_currentBudget!.amount.toStringAsFixed(2)}. Current spending: \$${currentSpending.toStringAsFixed(2)}',
        payload: 'budget_exceeded',
      );
    } else if (progress >= 0.8) {
      await _notificationService.showBudgetAlert(
        title: 'Budget Warning',
        body: 'You have used ${(progress * 100).toStringAsFixed(1)}% of your budget. Only \$${remaining.toStringAsFixed(2)} remaining.',
        payload: 'budget_warning',
      );
    }
  }

  // Get budget for a specific month/year
  Budget? getBudgetForMonth(String month, int year) {
    try {
      return _budgets.firstWhere(
        (budget) => budget.month == month && budget.year == year,
      );
    } catch (e) {
      return null;
    }
  }

  // Get total budget for a year
  double getTotalBudgetForYear(int year) {
    return _budgets
        .where((budget) => budget.year == year)
        .fold(0.0, (sum, budget) => sum + budget.amount);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Create default budget for current month if none exists
  Future<void> createDefaultBudget() async {
    if (_currentBudget != null) return;
    
    final defaultBudget = Budget(
      amount: 500.0,
      month: BudgetMonth.getCurrentMonth(),
      year: BudgetMonth.getCurrentYear(),
      createdAt: DateTime.now(),
      isActive: true,
    );
    
    await addBudget(defaultBudget);
  }
}
