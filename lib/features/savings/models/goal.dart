// lib/features/savings/data/models/goal.dart

class Goal {
  final int? id;
  final String name;
  final int targetAmount;
  final DateTime createdAt;
  // Это поле будет вычисляться отдельно и не хранится в БД
  int currentAmount;

  // Дата дедлайна для достижения цели
  final DateTime deadlineAt;

  Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.createdAt,
    required this.deadlineAt,
this.currentAmount = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'target_amount': targetAmount,
        'created_at': createdAt.millisecondsSinceEpoch,
        'deadline_at': deadlineAt.millisecondsSinceEpoch,
      };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
        id: map['id'] as int?,
        name: map['name'] as String,
        targetAmount: map['target_amount'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        deadlineAt: DateTime.fromMillisecondsSinceEpoch(map['deadline_at'] as int),
      );
}