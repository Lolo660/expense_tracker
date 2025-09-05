import 'package:flutter/material.dart';

class Expense {
  final int? id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String? note;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }

  Expense copyWith({
    int? id,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, amount: $amount, category: $category, description: $description, date: $date, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.amount == amount &&
        other.category == category &&
        other.description == description &&
        other.date == date &&
        other.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        category.hashCode ^
        description.hashCode ^
        date.hashCode ^
        note.hashCode;
  }
}

class ExpenseCategory {
  static const List<String> categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Shopping',
    'Education',
    'Healthcare',
    'Utilities',
    'Other',
  ];

  static const Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Entertainment': Icons.movie,
    'Shopping': Icons.shopping_bag,
    'Education': Icons.school,
    'Healthcare': Icons.medical_services,
    'Utilities': Icons.electric_bolt,
    'Other': Icons.more_horiz,
  };

  static const Map<String, Color> categoryColors = {
    'Food': Colors.orange,
    'Transport': Colors.blue,
    'Entertainment': Colors.purple,
    'Shopping': Colors.pink,
    'Education': Colors.green,
    'Healthcare': Colors.red,
    'Utilities': Colors.yellow,
    'Other': Colors.grey,
  };
}



