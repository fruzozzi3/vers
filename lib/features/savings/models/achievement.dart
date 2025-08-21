// lib/features/savings/models/achievement.dart
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int maxProgress;
  int progress;
  bool isUnlocked;
  bool isNew; // Добавляем флаг для новых достижений
  DateTime? unlockedAt;

  Achievement({
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

  void unlock() {
    isUnlocked = true;
    isNew = true;
    unlockedAt = DateTime.now();
    progress = maxProgress;
  }

  void markAsSeen() {
    isNew = false;
  }

  void updateProgress(int newProgress) {
    progress = newProgress.clamp(0, maxProgress);
    if (progress >= maxProgress && !isUnlocked) {
      unlock();
    }
  }

  // Статический метод для получения всех достижений
  static List<Achievement> getAllAchievements() {
    return [
      Achievement(
        id: 'first_goal',
        title: 'Первая цель',
        description: 'Создайте свою первую цель накопления',
        icon: '🎯',
      ),
      Achievement(
        id: 'first_deposit',
        title: 'Первый взнос',
        description: 'Внесите первый взнос в копилку',
        icon: '💰',
      ),
      Achievement(
        id: 'goal_completed',
        title: 'Цель достигнута!',
        description: 'Достигните своей первой цели',
        icon: '🏆',
      ),
      Achievement(
        id: 'savings_100k',
        title: 'Копилка на 100К',
        description: 'Накопите 100 000 ₽ суммарно',
        icon: '💎',
        maxProgress: 100000,
      ),
      Achievement(
        id: 'savings_500k',
        title: 'Полмиллиона',
        description: 'Накопите 500 000 ₽ суммарно',
        icon: '👑',
        maxProgress: 500000,
      ),
      Achievement(
        id: 'savings_1m',
        title: 'Миллионер',
        description: 'Накопите 1 000 000 ₽ суммарно',
        icon: '🤑',
        maxProgress: 1000000,
      ),
      Achievement(
        id: 'goals_5',
        title: 'Планировщик',
        description: 'Создайте 5 целей',
        icon: '📋',
        maxProgress: 5,
      ),
      Achievement(
        id: 'goals_10',
        title: 'Мастер планирования',
        description: 'Создайте 10 целей',
        icon: '🗂️',
        maxProgress: 10,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Неделя дисциплины',
        description: 'Вносите взносы 7 дней подряд',
        icon: '🔥',
        maxProgress: 7,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Месяц дисциплины',
        description: 'Вносите взносы 30 дней подряд',
        icon: '⚡',
        maxProgress: 30,
      ),
      Achievement(
        id: 'early_bird',
        title: 'Ранняя пташка',
        description: 'Достигните цели раньше дедлайна',
        icon: '🐦',
      ),
      Achievement(
        id: 'speed_saver',
        title: 'Скоростной накопитель',
        description: 'Достигните цели за месяц',
        icon: '🚀',
      ),
      Achievement(
        id: 'big_deposit',
        title: 'Крупный взнос',
        description: 'Внесите разовый взнос более 50 000 ₽',
        icon: '💸',
      ),
      Achievement(
        id: 'regular_saver',
        title: 'Регулярные накопления',
        description: 'Вносите взносы каждую неделю в течение месяца',
        icon: '📅',
      ),
      Achievement(
        id: 'diversified',
        title: 'Диверсификация',
        description: 'Имейте 3 активные цели одновременно',
        icon: '🎪',
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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      maxProgress: json['maxProgress'] ?? 1,
      progress: json['progress'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      isNew: json['isNew'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
    );
  }
}
