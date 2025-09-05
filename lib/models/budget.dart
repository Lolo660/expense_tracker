class Budget {
  final int? id;
  final double amount;
  final String month;
  final int year;
  final DateTime createdAt;
  final bool isActive;

  Budget({
    this.id,
    required this.amount,
    required this.month,
    required this.year,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      amount: map['amount'],
      month: map['month'],
      year: map['year'],
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] == 1,
    );
  }

  Budget copyWith({
    int? id,
    double? amount,
    String? month,
    int? year,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Budget(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  double getProgress(double spentAmount) {
    if (amount <= 0) return 0.0;
    return (spentAmount / amount).clamp(0.0, 1.0);
  }

  double getRemaining(double spentAmount) {
    return (amount - spentAmount).clamp(0.0, double.infinity);
  }

  bool isOverBudget(double spentAmount) {
    return spentAmount > amount;
  }

  @override
  String toString() {
    return 'Budget(id: $id, amount: $amount, month: $month, year: $year, createdAt: $createdAt, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.amount == amount &&
        other.month == month &&
        other.year == year &&
        other.createdAt == createdAt &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        month.hashCode ^
        year.hashCode ^
        createdAt.hashCode ^
        isActive.hashCode;
  }
}

class BudgetMonth {
  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String getCurrentMonth() {
    final now = DateTime.now();
    return months[now.month - 1];
  }

  static int getCurrentYear() {
    return DateTime.now().year;
  }
}
