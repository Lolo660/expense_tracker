import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/savings.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_finance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        month TEXT NOT NULL,
        year INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        isActive INTEGER NOT NULL
      )
    ''');

    // Create savings_goals table
    await db.execute('''
      CREATE TABLE savings_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL,
        targetDate TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        note TEXT
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> _insertSampleData(Database db) async {
    // Sample expenses
    final sampleExpenses = [
      {
        'amount': 25.50,
        'category': 'Food',
        'description': 'Lunch at cafeteria',
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'note': 'Daily lunch expense',
      },
      {
        'amount': 15.00,
        'category': 'Transport',
        'description': 'Bus fare',
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'note': 'Weekly bus pass',
      },
      {
        'amount': 50.00,
        'category': 'Shopping',
        'description': 'Textbooks',
        'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'note': 'Required course materials',
      },
    ];

    for (final expense in sampleExpenses) {
      await db.insert('expenses', expense);
    }

    // Sample budget
    final sampleBudget = {
      'amount': 500.0,
      'month': BudgetMonth.getCurrentMonth(),
      'year': BudgetMonth.getCurrentYear(),
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': 1,
    };
    await db.insert('budgets', sampleBudget);

    // Sample savings goal
    final sampleSavingsGoal = {
      'title': 'Emergency Fund',
      'description': 'Save money for unexpected expenses',
      'targetAmount': 1000.0,
      'currentAmount': 250.0,
      'targetDate': DateTime.now().add(const Duration(days: 60)).toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'isCompleted': 0,
      'note': 'Monthly contribution of $125',
    };
    await db.insert('savings_goals', sampleSavingsGoal);
  }

  // Expense operations
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Expense>> getExpensesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Budget operations
  Future<int> insertBudget(Budget budget) async {
    final db = await database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<Budget?> getCurrentBudget() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'month = ? AND year = ? AND isActive = 1',
      whereArgs: [BudgetMonth.getCurrentMonth(), BudgetMonth.getCurrentYear()],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Budget>> getAllBudgets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      orderBy: 'year DESC, month DESC',
    );
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  Future<void> updateBudget(Budget budget) async {
    final db = await database;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> deleteBudget(int id) async {
    final db = await database;
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Savings operations
  Future<int> insertSavingsGoal(SavingsGoal goal) async {
    final db = await database;
    return await db.insert('savings_goals', goal.toMap());
  }

  Future<List<SavingsGoal>> getAllSavingsGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => SavingsGoal.fromMap(maps[i]));
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    final db = await database;
    await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteSavingsGoal(int id) async {
    final db = await database;
    await db.delete(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Analytics methods
  Future<double> getTotalExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM expenses 
      WHERE date BETWEEN ? AND ?
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    return result.first['total'] as double? ?? 0.0;
  }

  Future<Map<String, double>> getExpensesByCategoryInRange(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total FROM expenses 
      WHERE date BETWEEN ? AND ?
      GROUP BY category
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    final Map<String, double> categoryTotals = {};
    for (final row in result) {
      categoryTotals[row['category'] as String] = row['total'] as double;
    }
    return categoryTotals;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
