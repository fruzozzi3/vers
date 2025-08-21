// lib/features/savings/models/achievement.dart
import 'package:flutter/foundation.dart';

@immutable
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int maxProgress;
  final int progress;
  final bool isUnlocked;
  final bool isNew;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.maxProgress = 1,
    this.progress = 0,
    this.isUnlocked = false,
    this.isNew = false,
    this.unlockedAt,
  });

  double get progressPercent => maxProgress > 0 ? (progress / maxProgress).clamp(0.0, 1.0) : 0.0;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? maxProgress,
    int? progress,
    bool? isUnlocked,
    bool? isNew,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      maxProgress: maxProgress ?? this.maxProgress,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isNew: isNew ?? this.isNew,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Achievement unlock() {
    return copyWith(
      isUnlocked: true,
      isNew: true,
      unlockedAt: DateTime.now(),
      progress: maxProgress,
    );
  }

  Achievement markAsSeen() {
    return copyWith(isNew: false);
  }

  Achievement updateProgress(int newProgress) {
    final clampedProgress = newProgress.clamp(0, maxProgress);
    if (clampedProgress >= maxProgress && !isUnlocked) {
      return copyWith(
        progress: clampedProgress,
        isUnlocked: true,
        isNew: true,
        unlockedAt: DateTime.now(),
      );
    }
    return copyWith(progress: clampedProgress);
  }

  // Статический метод для получения всех достижений
  static List<Achievement> getAllAchievements() {
    return [
      const Achievement(
        id: 'first_goal',
        title: 'Первая цель',
        description: 'Создайте свою первую цель накопления',
        icon: '🎯',
      ),
      const Achievement(
        id: 'first_deposit',
        title: 'Первый взнос',
        description: 'Внесите первый взнос в копилку',
        icon: '💰',
      ),
      const Achievement(
        id: 'goal_completed',
        title: 'Цель достигнута!',
        description: 'Достигните своей первой цели',
        icon: '🏆',
      ),
      const Achievement(
        id: 'savings_10k',
        title: 'Начинающий накопитель',
        description: 'Накопите 10 000 ₽ суммарно',
        icon: '💵',
        maxProgress: 10000,
      ),
      const Achievement(
        id: 'savings_50k',
        title: 'Серьезные намерения',
        description: 'Накопите 50 000 ₽ суммарно',
        icon: '💳',
        maxProgress: 50000,
      ),
      const Achievement(
        id: 'savings_100k',
        title: 'Копилка на 100К',
        description: 'Накопите 100 000 ₽ суммарно',
        icon: '💎',
        maxProgress: 100000,
      ),
      const Achievement(
        id: 'savings_500k',
        title: 'Полмиллиона',
        description: 'Накопите 500 000 ₽ суммарно',
        icon: '👑',
        maxProgress: 500000,
      ),
      const Achievement(
        id: 'savings_1m',
        title: 'Миллионер',
        description: 'Накопите 1 000 000 ₽ суммарно',
        icon: '🤑',
        maxProgress: 1000000,
      ),
      const Achievement(
        id: 'goals_3',
        title: 'Многозадачность',
        description: 'Создайте 3 цели',
        icon: '📝',
        maxProgress: 3,
      ),
      const Achievement(
        id: 'goals_5',
        title: 'Планировщик',
        description: 'Создайте 5 целей',
        icon: '📋',
        maxProgress: 5,
      ),
      const Achievement(
        id: 'goals_10',
        title: 'Мастер планирования',
        description: 'Создайте 10 целей',
        icon: '🗂️',
        maxProgress: 10,
      ),
      const Achievement(
        id: 'streak_7',
        title: 'Неделя дисциплины',
        description: 'Вносите взносы 7 дней подряд',
        icon: '🔥',
        maxProgress: 7,
      ),
      const Achievement(
        id: 'streak_30',
        title: 'Месяц дисциплины',
        description: 'Вносите взносы 30 дней подряд',
        icon: '⚡',
        maxProgress: 30,
      ),
      const Achievement(
        id: 'streak_100',
        title: 'Стальная воля',
        description: 'Вносите взносы 100 дней подряд',
        icon: '💪',
        maxProgress: 100,
      ),
      const Achievement(
        id: 'early_bird',
        title: 'Ранняя пташка',
        description: 'Достигните цели раньше дедлайна',
        icon: '🐦',
      ),
      const Achievement(
        id: 'speed_saver',
        title: 'Скоростной накопитель',
        description: 'Достигните цели за месяц',
        icon: '🚀',
      ),
      const Achievement(
        id: 'big_deposit',
        title: 'Крупный взнос',
        description: 'Внесите разовый взнос более 50 000 ₽',
        icon: '💸',
      ),
      const Achievement(
        id: 'small_deposits',
        title: 'Копейка рубль бережет',
        description: 'Сделайте 100 мелких взносов до 100 ₽',
        icon: '🪙',
        maxProgress: 100,
      ),
      const Achievement(
        id: 'regular_saver',
        title: 'Регулярные накопления',
        description: 'Вносите взносы каждую неделю в течение месяца',
        icon: '📅',
      ),
      const Achievement(
        id: 'diversified',
        title: 'Диверсификация',
        description: 'Имейте 3 активные цели одновременно',
        icon: '🎪',
      ),
      const Achievement(
        id: 'night_owl',
        title: 'Ночная сова',
        description: 'Внесите взнос после полуночи',
        icon: '🦉',
      ),
      const Achievement(
        id: 'morning_person',
        title: 'Жаворонок',
        description: 'Внесите взнос до 6 утра',
        icon: '🌅',
      ),
      const Achievement(
        id: 'weekend_warrior',
        title: 'Воин выходного дня',
        description: 'Вносите взносы каждые выходные месяц подряд',
        icon: '⚔️',
      ),
      const Achievement(
        id: 'perfectionist',
        title: 'Перфекционист',
        description: 'Достигните цели с точностью до рубля',
        icon: '🎯',
      ),
      const Achievement(
        id: 'comeback',
        title: 'Возвращение',
        description: 'Вернитесь к накоплениям после перерыва в 30 дней',
        icon: '🔄',
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'maxProgress': maxProgress,
      'progress': progress,
      'isUnlocked': isUnlocked,
      'isNew': isNew,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      maxProgress: json['maxProgress'] ?? 1,
      progress: json['progress'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      isNew: json['isNew'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.tryParse(json['unlockedAt']) 
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, progress: $progress/$maxProgress, isUnlocked: $isUnlocked, isNew: $isNew)';
  }
}
