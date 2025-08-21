// lib/features/savings/ui/screens/detailed_plan_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_kopilka/features/savings/models/goal.dart';
import 'package:my_kopilka/features/savings/services/savings_calculator.dart';
import 'package:my_kopilka/features/savings/viewmodels/savings_view_model.dart';
import 'package:my_kopilka/theme/colors.dart';
import 'package:provider/provider.dart';

class DetailedPlanScreen extends StatelessWidget {
  final Goal goal;
  
  const DetailedPlanScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SavingsViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMMM yyyy', 'ru');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Детальный план'),
        subtitle: Text(goal.name),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<SavingsPlan>(
        future: vm.getSavingsPlan(goal),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData) {
            return const Center(child: Text('Ошибка загрузки плана'));
          }
          
          final plan = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Общий статус
                _buildStatusCard(context, plan, currencyFormat, isDark),
                const SizedBox(height: 16),
                
                // Анализ текущего месяца
                if (!plan.isGoalCompleted) ...[
                  _buildMonthAnalysisCard(context, plan, currencyFormat, isDark),
                  const SizedBox(height: 16),
                ],
                
                // Временная шкала
                _buildTimelineCard(context, plan, goal, dateFormat, isDark),
                const SizedBox(height: 16),
                
                // Рекомендации
                if (!plan.isGoalCompleted)
                  _buildRecommendationsCard(context, plan, currencyFormat, isDark),
                
                const SizedBox(height: 16),
                
                // Сценарии "что если"
                if (!plan.isGoalCompleted)
                  _buildWhatIfCard(context, plan, goal, currencyFormat, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, SavingsPlan plan, NumberFormat currencyFormat, bool isDark) {
    final progress = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppGradients.cardDark : AppGradients.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? DarkColors.primary : LightColors.primary).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.isGoalCompleted ? 'Цель достигнута! 🎉' : 'Текущий статус',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (!plan.isGoalCompleted) ...[
            Text(
              plan.statusMessage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Накоплено',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    currencyFormat.format(goal.currentAmount),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthAnalysisCard(BuildContext context, SavingsPlan plan, NumberFormat currencyFormat, bool isDark) {
    final monthStatus = plan.currentMonthStatus;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Анализ текущего месяца',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Детальная информация о месяце
            _buildMonthDetailRow('Планировалось', currencyFormat.format(monthStatus.plannedAmount)),
            const SizedBox(height: 8),
            _buildMonthDetailRow('Фактически внесено', currencyFormat.format(monthStatus.actualAmount)),
            const SizedBox(height: 8),
            _buildMonthDetailRow('Должно быть к сегодня', currencyFormat.format(monthStatus.shouldHaveByNow)),
            const SizedBox(height: 8),
            _buildMonthDetailRow(
              monthStatus.isAhead ? 'Опережение' : 'Отставание',
              currencyFormat.format(monthStatus.difference.abs()),
              color: monthStatus.isAhead 
                  ? (isDark ? DarkColors.success : LightColors.success)
                  : monthStatus.isBehind
                      ? (isDark ? DarkColors.warning : LightColors.warning)
                      : null,
            ),
            
            const SizedBox(height: 16),
            
            // Визуализация прогресса месяца
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Прогресс по дням',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: monthStatus.dailyProgressPercent,
                          minHeight: 6,
                          backgroundColor: (isDark ? DarkColors.border : LightColors.border).withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? DarkColors.secondary : LightColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Прогресс по сумме',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: monthStatus.progressPercent,
                          minHeight: 6,
                          backgroundColor: (isDark ? DarkColors.border : LightColors.border).withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? DarkColors.primary : LightColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthDetailRow(String title, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(BuildContext context, SavingsPlan plan, Goal goal, DateFormat dateFormat, bool isDark) {
    final now = DateTime.now();
    final daysLeft = goal.deadlineAt.difference(now).inDays;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Временная шкала',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildTimelineItem(
              context,
              'Цель создана',
              dateFormat.format(goal.createdAt),
              Icons.flag,
              isDark ? DarkColors.primary : LightColors.primary,
              isDark,
              isCompleted: true,
            ),
            
            _buildTimelineItem(
              context,
              'Сегодня',
              dateFormat.format(now),
              Icons.today,
              isDark ? DarkColors.secondary : LightColors.secondary,
              isDark,
              isCompleted: true,
            ),
            
            if (!plan.isGoalCompleted && plan.projectedCompletion != null)
              _buildTimelineItem(
                context,
                'Прогнозируемое завершение',
                dateFormat.format(plan.projectedCompletion!),
                Icons.insights,
                isDark ? DarkColors.warning : LightColors.warning,
                isDark,
                subtitle: 'При текущем темпе',
              ),
            
            _buildTimelineItem(
              context,
              plan.isGoalCompleted ? 'Цель достигнута' : 'Дедлайн',
              dateFormat.format(goal.deadlineAt),
              plan.isGoalCompleted ? Icons.check_circle : Icons.schedule,
              plan.isGoalCompleted 
                  ? (isDark ? DarkColors.success : LightColors.success)
                  : daysLeft < 30
                      ? (isDark ? DarkColors.error : LightColors.error)
                      : (isDark ? DarkColors.primary : LightColors.primary),
              isDark,
              isCompleted: plan.isGoalCompleted,
              subtitle: plan.isGoalCompleted 
                  ? null
                  : daysLeft > 0
                      ? 'Осталось $daysLeft дней'
                      : 'Просрочено на ${daysLeft.abs()} дней',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String title,
    String date,
    IconData icon,
    Color color,
    bool isDark, {
    bool isCompleted = false,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(isCompleted ? 1.0 : 0.1),
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? color : null,
                  ),
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(BuildContext context, SavingsPlan plan, NumberFormat currencyFormat, bool isDark) {
    final recommendations = _generateRecommendations(plan);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: isDark ? DarkColors.warning : LightColors.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  'Рекомендации',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...recommendations.map((rec) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: rec.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: rec.color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(rec.icon, color: rec.color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rec.text,
                      style: TextStyle(color: rec.color),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatIfCard(BuildContext context, SavingsPlan plan, Goal goal, NumberFormat currencyFormat, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сценарии "что если"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildScenarioRow(
              context,
              'Если увеличить взнос на 50%',
              _calculateScenario(plan, 1.5),
              currencyFormat,
              isDark,
            ),
            
            _buildScenarioRow(
              context,
              'Если уменьшить взнос на 20%',
              _calculateScenario(plan, 0.8),
              currencyFormat,
              isDark,
            ),
            
            _buildScenarioRow(
              context,
              'Если вносить каждый день',
              _calculateDailyScenario(plan),
              currencyFormat,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioRow(BuildContext context, String title, Map<String, dynamic> scenario, NumberFormat currencyFormat, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? DarkColors.surface : LightColors.background).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Ежемесячно: ${currencyFormat.format(scenario['monthly'])}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Завершение: ${scenario['completion']}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  List<Recommendation> _generateRecommendations(SavingsPlan plan) {
    final recommendations = <Recommendation>[];
    final monthStatus = plan.currentMonthStatus;
    
    if (monthStatus.isBehind) {
      recommendations.add(Recommendation(
        'Увеличьте ежедневный взнос до ${plan.dailyRequired} ₽ для достижения цели в срок',
        Icons.trending_up,
        Colors.orange,
      ));
    }
    
    if (monthStatus.isAhead) {
      recommendations.add(Recommendation(
        'Отличная работа! Можете снизить будущие взносы или достичь цели раньше',
        Icons.celebration,
        Colors.green,
      ));
    }
    
    if (plan.monthsRemaining != null && plan.monthsRemaining! < 2) {
      recommendations.add(Recommendation(
        'До дедлайна осталось мало времени. Рассмотрите возможность крупного взноса',
        Icons.warning,
        Colors.red,
      ));
    }
    
    // Если нет особых рекомендаций
    if (recommendations.isEmpty) {
      recommendations.add(Recommendation(
        'Продолжайте регулярно пополнять копилку для достижения цели в срок',
        Icons.thumb_up,
        Colors.blue,
      ));
    }
    
    return recommendations;
  }

  Map<String, dynamic> _calculateScenario(SavingsPlan plan, double multiplier) {
    final newMonthly = (plan.monthlyRequired * multiplier).round();
    final remaining = plan.totalRemaining ?? 0;
    final monthsToComplete = remaining > 0 ? (remaining / newMonthly).ceil() : 0;
    final completionDate = DateTime.now().add(Duration(days: monthsToComplete * 30));
    
    return {
      'monthly': newMonthly,
      'completion': DateFormat('MMM yyyy', 'ru').format(completionDate),
    };
  }

  Map<String, dynamic> _calculateDailyScenario(SavingsPlan plan) {
    final remaining = plan.totalRemaining ?? 0;
    final dailyAmount = plan.dailyRequired;
    final daysToComplete = remaining > 0 ? (remaining / dailyAmount).ceil() : 0;
    final completionDate = DateTime.now().add(Duration(days: daysToComplete));
    
    return {
      'monthly': dailyAmount * 30,
      'completion': DateFormat('dd MMM yyyy', 'ru').format(completionDate),
    };
  }
}

class Recommendation {
  final String text;
  final IconData icon;
  final Color color;
  
  Recommendation(this.text, this.icon, this.color);
}
