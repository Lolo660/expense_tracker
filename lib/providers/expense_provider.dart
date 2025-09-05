import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get total expenses for current month
  double get currentMonthTotal {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _expenses
        .where((expense) => 
            expense.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(endOfMonth.add(const Duration(days: 1))))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get total expenses for current week
  double get currentWeekTotal {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return _expenses
        .where((expense) => 
            expense.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(endOfWeek.add(const Duration(days: 1))))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses by category for current month
  Map<String, double> get currentMonthByCategory {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final monthlyExpenses = _expenses
        .where((expense) => 
            expense.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(endOfMonth.add(const Duration(days: 1))));
    
    final Map<String, double> categoryTotals = {};
    for (final expense in monthlyExpenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }
    return categoryTotals;
  }

  Future<void> loadExpenses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _expenses = await _databaseService.getAllExpenses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load expenses: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      _error = null;
      final id = await _databaseService.insertExpense(expense);
      final newExpense = expense.copyWith(id: id);
      _expenses.insert(0, newExpense);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add expense: $e';
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      _error = null;
      await _databaseService.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update expense: $e';
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      _error = null;
      await _databaseService.deleteExpense(id);
      _expenses.removeWhere((expense) => expense.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete expense: $e';
      notifyListeners();
    }
  }

  Future<void> loadExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _expenses = await _databaseService.getExpensesByDateRange(start, end);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load expenses: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExpensesByCategory(String category) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _expenses = await _databaseService.getExpensesByCategory(category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load expenses: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get recent expenses (last 5)
  List<Expense> get recentExpenses {
    return _expenses.take(5).toList();
  }

  // Get expenses for a specific date
  List<Expense> getExpensesForDate(DateTime date) {
    return _expenses
        .where((expense) => 
            expense.date.year == date.year &&
            expense.date.month == date.month &&
            expense.date.day == date.day)
        .toList();
  }

  // Get total expenses for a specific date
  double getTotalForDate(DateTime date) {
    return getExpensesForDate(date)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }
}
