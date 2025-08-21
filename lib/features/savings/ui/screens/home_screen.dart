// lib/features/savings/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_kopilka/features/savings/models/goal.dart';
import 'package:my_kopilka/features/savings/services/savings_calculator.dart';
import 'package:my_kopilka/features/savings/ui/screens/goal_details_screen.dart';
import 'package:my_kopilka/features/savings/ui/screens/detailed_plan_screen.dart';
import 'package:my_kopilka/features/savings/ui/screens/achievements_screen.dart';
import 'package:my_kopilka/features/savings/ui/screens/settings_screen.dart';
import 'package:my_kopilka/features/savings/viewmodels/savings_view_model.dart';
import 'package:my_kopilka/features/settings/viewmodels/settings_view_model.dart';
import 'package:my_kopilka/theme/colors.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavingsViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Красивый AppBar с градиентом
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: isDark ? AppGradients.cardDark : AppGradients.primary,
              ),
              child: const FlexibleSpaceBar(
                title: Text(
                  'Мои Копилки',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
            ),
            actions: [
              // Кнопка достижений
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.white),
                    // Индикатор новых достижений
                    if (vm.achievements.where((a) => a.isUnlocked && a.isNew).isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AchievementsScreen(),
                    ),
                  );
                },
                tooltip: 'Достижения',
              ),
              // Кнопка настроек
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                tooltip: 'Настройки',
              ),
            ],
          ),

          // Контент
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: vm.isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : vm.goals.isEmpty
                    ? _buildEmptyState(context, isDark)
                    : SliverList(
                        delegate: SliverChildListDelegate([
                          // Общая статистика
                          _buildOverallStatsCard(context, vm, isDark),
                          const SizedBox(height: 16),

                          // Быстрые действия (включая достижения)
                          _buildQuickActionsCard(context, vm, isDark),
                          const SizedBox(height: 16),

                          // Заголовок целей
                          _buildSectionHeader(context, 'Мои цели', vm.goals.length),
                          const SizedBox(height: 8),

                          // Список целей
                          ...vm.goals.map((goal) => SmartGoalCard(goal: goal)).toList(),

                          const SizedBox(height: 80), // Отступ для FAB
                        ]),
                      ),
          ),
        ],
      ),

      floatingActionButton: _buildFAB(context, vm),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isDark ? AppGradients.cardDark : AppGradients.primary,
              ),
              child: const Icon(
                Icons.savings,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Создайте свою первую копилку!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Поставьте цель и начните копить.\nКаждый рубль приближает к мечте!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Кнопка достижений даже в пустом состоянии
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AchievementsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.emoji_events),
              label: const Text('Посмотреть достижения'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard(BuildContext context, SavingsViewModel vm, bool isDark) {
    final totalSaved = vm.getTotalSaved();
    final totalGoals = vm.getTotalGoals();
    final progress = vm.getOverallProgress();
    final currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppGradients.cardDark : AppGradients.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Общий прогресс',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? DarkColors.primary : LightColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            currencyFormat.format(totalSaved),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'из ${currencyFormat.format(totalGoals)}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: (isDark ? DarkColors.border : LightColors.border).withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? DarkColors.primary : LightColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Активных целей',
                  vm.getActiveGoals().length.toString(),
                  Icons.track_changes,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Достигнуто',
                  vm.getCompletedGoals().length.toString(),
                  Icons.check_circle,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, SavingsViewModel vm, bool isDark) {
    final unlockedAchievements = vm.achievements.where((a) => a.isUnlocked).length;
    final totalAchievements = vm.achievements.length;
    
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Карточка достижений
          _buildActionCard(
            context,
            icon: Icons.emoji_events,
            title: 'Достижения',
            subtitle: '$unlockedAchievements/$totalAchievements получено',
            color: Colors.amber,
            isDark: isDark,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AchievementsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          
          // Карточка статистики
          _buildActionCard(
            context,
            icon: Icons.analytics,
            title: 'Статистика',
            subtitle: 'Анализ прогресса',
            color: Colors.blue,
            isDark: isDark,
            onTap: () {
              // TODO: Навигация к экрану статистики
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Статистика в разработке')),
              );
            },
          ),
          const SizedBox(width: 12),
          
          // Карточка советов
          _buildActionCard(
            context,
            icon: Icons.lightbulb,
            title: 'Советы',
            subtitle: 'Как копить эффективнее',
            color: Colors.green,
            isDark: isDark,
            onTap: () {
              // TODO: Навигация к экрану советов
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Советы в разработке')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? DarkColors.surface : LightColors.background).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isDark ? DarkColors.primary : LightColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context, SavingsViewModel vm) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddGoalDialog(context, vm),
      icon: const Icon(Icons.add),
      label: const Text('Новая цель'),
    );
  }

  void _showAddGoalDialog(BuildContext context, SavingsViewModel vm) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime deadlineAt = DateTime.now().add(const Duration(days: 365));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Новая цель накопления'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название цели',
                    hintText: 'Например: Отпуск в Турции',
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Введите название' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Сумма',
                    hintText: 'Например: 50000',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите сумму';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Сумма должна быть числом';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.event),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: deadlineAt,
                            firstDate: now,
                            lastDate: DateTime(now.year + 10),
                          );
                          if (picked != null) {
                            setState(() {
                              deadlineAt = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Дедлайн: ${DateFormat('dd.MM.yyyy').format(deadlineAt)}'),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final name = nameController.text.trim();
                  final amount = int.parse(amountController.text);
                  vm.addGoal(name, amount, deadlineAt);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }
}

// УМНАЯ КАРТОЧКА ЦЕЛИ
class SmartGoalCard extends StatelessWidget {
  final Goal goal;
  const SmartGoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);
    final progress = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vm = context.read<SavingsViewModel>();
    final settingsVM = context.read<SettingsViewModel>();
    final isCompleted = goal.currentAmount >= goal.targetAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GoalDetailsScreen(goalId: goal.id!),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Заголовок с градиентом
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: isDark ? AppGradients.cardDark : AppGradients.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isCompleted)
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => DetailedPlanScreen(goal: goal),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.analytics,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip: 'Детальный план',
                          ),
                      ],
                    ),
                    
                    // Умное сообщение о статусе
                    FutureBuilder<String>(
                      future: vm.getSmartMotivationalMessage(goal),
                      builder: (context, snapshot) {
                        final message = snapshot.data ?? vm.getMotivationalMessage(goal);
                        return Text(
                          message,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Основной контент
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Прогресс цели
                    _buildGoalProgress(context, progress, currencyFormat, isDark, isCompleted),
                    
                    const SizedBox(height: 20),
                    
                    // Умный план накопления
                    if (!isCompleted)
                      _buildSmartPlan(context, vm, currencyFormat, isDark),
                    
                    if (!isCompleted)
                      const SizedBox(height: 20),

                    // Кнопки быстрого пополнения
                    if (!isCompleted)
                      _buildQuickAddButtons(context, vm, settingsVM, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalProgress(BuildContext context, double progress, NumberFormat currencyFormat, bool isDark, bool isCompleted) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Накоплено',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  currencyFormat.format(goal.currentAmount),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Цель',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  currencyFormat.format(goal.targetAmount),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 16),

        // Прогресс бар с анимацией
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (!isCompleted)
                  Text(
                    'Осталось: ${currencyFormat.format(goal.targetAmount - goal.currentAmount)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 12,
                    backgroundColor: (isDark ? DarkColors.border : LightColors.border).withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? (isDark ? DarkColors.success : LightColors.success)
                          : (isDark ? DarkColors.primary : LightColors.primary),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmartPlan(BuildContext context, SavingsViewModel vm, NumberFormat currencyFormat, bool isDark) {
    return FutureBuilder<SavingsPlan>(
      future: vm.getSavingsPlan(goal),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: (isDark ? DarkColors.surface : LightColors.background).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        
        final plan = snapshot.data!;
        final monthStatus = plan.currentMonthStatus;
        
        Color getStatusColor() {
          if (monthStatus.isAhead) return isDark ? DarkColors.success : LightColors.success;
          if (monthStatus.isBehind) return isDark ? DarkColors.warning : LightColors.warning;
          return isDark ? DarkColors.primary : LightColors.primary;
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: getStatusColor().withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              // Статус текущего месяца
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Текущий месяц',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: getStatusColor(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${monthStatus.daysPassed}/${monthStatus.daysInMonth} дней',
                      style: TextStyle(
                        fontSize: 12,
                        color: getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Прогресс месяца с подписями
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Внесено: ${currencyFormat.format(monthStatus.actualAmount)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: getStatusColor(),
                              ),
                            ),
                            Text(
                              'План: ${currencyFormat.format(monthStatus.plannedAmount)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: monthStatus.progressPercent,
                            minHeight: 6,
                            backgroundColor: getStatusColor().withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(getStatusColor()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Плановые суммы
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: getStatusColor().withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: getStatusColor(),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'В месяц',
                            style: TextStyle(
                              fontSize: 12,
                              color: getStatusColor(),
                            ),
                          ),
                          Text(
                            currencyFormat.format(plan.monthlyRequired),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: getStatusColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: getStatusColor().withOpacity(0.3),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.today,
                            color: getStatusColor(),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'В день',
                            style: TextStyle(
                              fontSize: 12,
                              color: getStatusColor(),
                            ),
                          ),
                          Text(
                            currencyFormat.format(plan.dailyRequired),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: getStatusColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAddButtons(BuildContext context, SavingsViewModel vm, SettingsViewModel settingsVM, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Быстрое пополнение',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DetailedPlanScreen(goal: goal),
                  ),
                );
              },
              icon: const Icon(Icons.analytics, size: 16),
              label: const Text(
                'План',
                style: TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: settingsVM.settings.quickAddPresets.map((amount) {
            return SizedBox(
              height: 36,
              child: OutlinedButton(
                onPressed: () => vm.addTransaction(goal.id!, amount),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  side: BorderSide(
                    color: (isDark ? DarkColors.primary : LightColors.primary).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  '+$amount ₽',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
