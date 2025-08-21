// lib/features/savings/services/savings_calculator.dart
import 'package:my_kopilka/features/savings/models/goal.dart';
import 'package:my_kopilka/features/savings/models/transaction.dart';

/// Умная система расчета взносов с автоматическим перераспределением
class SavingsCalculator {
  
  /// Основная структура с информацией о плане накоплений
  static SavingsPlan calculatePlan(Goal goal, List<Transaction> transactions) {
    final now = DateTime.now();
    final totalRemaining = (goal.targetAmount - goal.currentAmount).clamp(0, goal.targetAmount);
    
    if (totalRemaining <= 0) {
      return SavingsPlan(
        isGoalCompleted: true,
        monthlyRequired: 0,
        dailyRequired: 0,
        currentMonthStatus: MonthStatus.completed(),
      );
    }

    // Рассчитываем сколько месяцев осталось
    final monthsRemaining = _calculateMonthsRemaining(now, goal.deadlineAt);
    
    // Базовый ежемесячный взнос
    final baseMonthlyRequired = monthsRemaining > 0 
        ? (totalRemaining / monthsRemaining).ceil() 
        : totalRemaining;

    // Анализируем текущий месяц
    final currentMonthStatus = _analyzeCurrentMonth(
      now, 
      baseMonthlyRequired, 
      transactions,
      monthsRemaining
    );

    // Рассчитываем скорректированный план
    final adjustedMonthlyRequired = _calculateAdjustedMonthly(
      totalRemaining,
      currentMonthStatus,
      monthsRemaining
    );

    final dailyRequired = _calculateDailyRequired(
      adjustedMonthlyRequired,
      currentMonthStatus,
      now
    );

    return SavingsPlan(
      isGoalCompleted: false,
      monthlyRequired: adjustedMonthlyRequired,
      dailyRequired: dailyRequired,
      currentMonthStatus: currentMonthStatus,
      monthsRemaining: monthsRemaining,
      totalRemaining: totalRemaining,
      projectedCompletion: _calculateProjectedCompletion(now, goal, dailyRequired),
    );
  }

  /// Рассчитывает количество полных месяцев до дедлайна
  static double _calculateMonthsRemaining(DateTime now, DateTime deadline) {
    if (deadline.isBefore(now)) return 0;
    
    final diffInDays = deadline.difference(now).inDays;
    return diffInDays / 30.44; // Среднее количество дней в месяце
  }

  /// Анализирует состояние текущего месяца
  static MonthStatus _analyzeCurrentMonth(
    DateTime now, 
    int baseMonthlyRequired, 
    List<Transaction> transactions,
    double monthsRemaining
  ) {
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = endOfMonth.day;
    final daysPassed = now.day;
    final daysLeft = daysInMonth - daysPassed;

    // Сумма внесенная в текущем месяце
    final amountThisMonth = transactions
        .where((t) => 
          t.createdAt.isAfter(startOfMonth.subtract(Duration(days: 1))) && 
          t.createdAt.isBefore(endOfMonth.add(Duration(days: 1))) &&
          t.amount > 0
        )
        .fold<int>(0, (sum, t) => sum + t.amount);

    // Должны были внести к текущему дню
    final shouldHaveByNow = (baseMonthlyRequired * daysPassed / daysInMonth).ceil();
    
    // Разница
    final difference = amountThisMonth - shouldHaveByNow;
    final isAhead = difference > 0;
    final isBehind = difference < 0;

    return MonthStatus(
      plannedAmount: baseMonthlyRequired,
      actualAmount: amountThisMonth,
      shouldHaveByNow: shouldHaveByNow,
      difference: difference,
      daysLeft: daysLeft,
      daysPassed: daysPassed,
      daysInMonth: daysInMonth,
      isAhead: isAhead,
      isBehind: isBehind,
    );
  }

  /// Корректирует месячный план с учетом текущих отклонений
  static int _calculateAdjustedMonthly(
    int totalRemaining,
    MonthStatus currentMonth,
    double monthsRemaining
  ) {
    if (monthsRemaining <= 1) {
      // Если остался последний месяц - нужно внести всё оставшееся
      return totalRemaining;
    }

    // Если мы отстаём в текущем месяце, нужно перераспределить долг
    if (currentMonth.isBehind) {
      final debt = currentMonth.difference.abs();
      final monthsForDebt = monthsRemaining - 1; // Исключаем текущий месяц
      final additionalMonthly = monthsForDebt > 0 ? (debt / monthsForDebt).ceil() : debt;
      
      return currentMonth.plannedAmount + additionalMonthly;
    }
    
    // Если мы опережаем план, можем уменьшить будущие взносы
    if (currentMonth.isAhead) {
      final surplus = currentMonth.difference;
      final monthsForSurplus = monthsRemaining - 1;
      final reductionMonthly = monthsForSurplus > 0 ? (surplus / monthsForSurplus).floor() : surplus;
      
      return (currentMonth.plannedAmount - reductionMonthly).clamp(0, currentMonth.plannedAmount);
    }

    return currentMonth.plannedAmount;
  }

  /// Рассчитывает дневной взнос с учетом прогресса текущего месяца
  static int _calculateDailyRequired(
    int adjustedMonthlyRequired,
    MonthStatus currentMonth,
    DateTime now
  ) {
    if (currentMonth.daysLeft <= 0) return 0;

    // Сколько нужно внести до конца месяца
    final remainingForMonth = (adjustedMonthlyRequired - currentMonth.actualAmount).clamp(0, adjustedMonthlyRequired);
    
    return (remainingForMonth / currentMonth.daysLeft).ceil();
  }

  /// Прогнозирует дату завершения при текущем темпе
  static DateTime? _calculateProjectedCompletion(DateTime now, Goal goal, int dailyRequired) {
    if (dailyRequired <= 0) return goal.deadlineAt;
    
    final remaining = (goal.targetAmount - goal.currentAmount).clamp(0, goal.targetAmount);
    final daysNeeded = (remaining / dailyRequired).ceil();
    
    return now.add(Duration(days: daysNeeded));
  }
}

/// Полный план накоплений
class SavingsPlan {
  final bool isGoalCompleted;
  final int monthlyRequired;      // Скорректированный месячный взнос
  final int dailyRequired;        // Дневной взнос для достижения цели
  final MonthStatus currentMonthStatus;
  final double? monthsRemaining;
  final int? totalRemaining;
  final DateTime? projectedCompletion;

  SavingsPlan({
    required this.isGoalCompleted,
    required this.monthlyRequired,
    required this.dailyRequired,
    required this.currentMonthStatus,
    this.monthsRemaining,
    this.totalRemaining,
    this.projectedCompletion,
  });

  /// Генерирует понятное сообщение о текущем статусе
  String get statusMessage {
    if (isGoalCompleted) return "🎉 Цель достигнута!";
    
    final status = currentMonthStatus;
    if (status.isAhead) {
      return "💪 Отлично! Вы опережаете план на ${status.difference} ₽";
    } else if (status.isBehind) {
      return "⚠️ Нужно наверстать ${status.difference.abs()} ₽ до конца месяца";
    } else {
      return "✅ Идёте точно по плану!";
    }
  }

  /// Цвет для статуса (для UI)
  String get statusColor {
    if (isGoalCompleted) return "success";
    if (currentMonthStatus.isAhead) return "success";
    if (currentMonthStatus.isBehind) return "warning";
    return "primary";
  }
}

/// Статус текущего месяца
class MonthStatus {
  final int plannedAmount;        // Планируемая сумма на месяц
  final int actualAmount;         // Фактически внесено
  final int shouldHaveByNow;      // Должно быть внесено к текущему дню
  final int difference;           // Разница (+ опережение, - отставание)
  final int daysLeft;             // Дней осталось в месяце
  final int daysPassed;           // Дней прошло
  final int daysInMonth;          // Всего дней в месяце
  final bool isAhead;             // Опережаем план
  final bool isBehind;            // Отстаём от плана

  MonthStatus({
    required this.plannedAmount,
    required this.actualAmount,
    required this.shouldHaveByNow,
    required this.difference,
    required this.daysLeft,
    required this.daysPassed,
    required this.daysInMonth,
    required this.isAhead,
    required this.isBehind,
  });

  /// Конструктор для завершенной цели
  factory MonthStatus.completed() => MonthStatus(
    plannedAmount: 0,
    actualAmount: 0,
    shouldHaveByNow: 0,
    difference: 0,
    daysLeft: 0,
    daysPassed: 0,
    daysInMonth: 0,
    isAhead: false,
    isBehind: false,
  );

  /// Прогресс месяца в процентах
  double get progressPercent => plannedAmount > 0 ? (actualAmount / plannedAmount).clamp(0.0, 1.0) : 0.0;
  
  /// Прогресс по дням месяца
  double get dailyProgressPercent => (daysPassed / daysInMonth).clamp(0.0, 1.0);
  
  /// Сколько нужно внести до конца месяца
  int get remainingForMonth => (plannedAmount - actualAmount).clamp(0, plannedAmount);
}
