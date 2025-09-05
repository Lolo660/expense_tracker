class SavingsGoal {
  final int? id;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final bool isCompleted;
  final String? note;

  SavingsGoal({
    this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.createdAt,
    this.isCompleted = false,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'note': note,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
      targetDate: DateTime.parse(map['targetDate']),
      createdAt: DateTime.parse(map['createdAt']),
      isCompleted: map['isCompleted'] == 1,
      note: map['note'],
    );
  }

  SavingsGoal copyWith({
    int? id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    bool? isCompleted,
    String? note,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      note: note ?? this.note,
    );
  }

  double getProgress() {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double getRemaining() {
    return (targetAmount - currentAmount).clamp(0.0, double.infinity);
  }

  bool get isOnTrack {
    final daysRemaining = targetDate.difference(DateTime.now()).inDays;
    final expectedProgress = 1.0 - (daysRemaining / 30.0); // Assuming monthly goals
    return getProgress() >= expectedProgress;
  }

  int get daysRemaining {
    final difference = targetDate.difference(DateTime.now());
    return difference.inDays.clamp(0, 365);
  }

  bool get isOverdue {
    return DateTime.now().isAfter(targetDate) && !isCompleted;
  }

  @override
  String toString() {
    return 'SavingsGoal(id: $id, title: $title, description: $description, targetAmount: $targetAmount, currentAmount: $currentAmount, targetDate: $targetDate, createdAt: $createdAt, isCompleted: $isCompleted, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavingsGoal &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.targetDate == targetDate &&
        other.createdAt == createdAt &&
        other.isCompleted == isCompleted &&
        other.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        targetAmount.hashCode ^
        currentAmount.hashCode ^
        targetDate.hashCode ^
        createdAt.hashCode ^
        isCompleted.hashCode ^
        note.hashCode;
  }
}
