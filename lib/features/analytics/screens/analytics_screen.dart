import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../care_tracking/providers/care_log_provider.dart';
import '../../../shared/providers/cat_provider.dart';
import '../../../shared/widgets/pastel_card.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedTab = 'Week';

  // Map internal tab keys to localized display labels
  static const List<String> _tabKeys = ['Week', 'Month', 'All'];

  String _localizedTab(String key) {
    switch (key) {
      case 'Week': return AppStrings.get('week');
      case 'Month': return AppStrings.get('month');
      case 'All': return AppStrings.get('all');
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final careLogs = ref.watch(careLogListProvider);
    final selectedCat = ref.watch(selectedCatProvider);
    final catName = selectedCat?.name ?? AppStrings.get('your_cat');
    final isModern = ref.watch(themeProvider) == AppThemeType.modern;

    // Calculate time range
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int daysBack = _selectedTab == 'Week' ? 7 : _selectedTab == 'Month' ? 30 : 365;
    final startDate = today.subtract(Duration(days: daysBack - 1));

    // Filter records by time range
    final filteredLogs = careLogs.where((l) => l.timestamp.isAfter(startDate)).toList();

    // Calculate real stats
    final totalMeals = filteredLogs.where((l) => l.type == 'food').length;
    final totalLitter = filteredLogs.where((l) => l.type == 'litter').length;
    final totalWater = filteredLogs.where((l) => l.type == 'water').length;
    final weightLogsList = filteredLogs.where((l) => l.type == 'weight').toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final latestWeight = weightLogsList.isNotEmpty ? (weightLogsList.first.value ?? '0.0') : '0.0';
    final streak = _calculateStreak(careLogs);

    // Get today's food logs for timeline
    final todayFoodLogs = careLogs
        .where((l) => l.type == 'food' && l.timestamp.day == now.day && l.timestamp.month == now.month && l.timestamp.year == now.year)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Generate insight
    final insight = _generateInsight(catName, filteredLogs);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: isModern ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Text(
              isModern ? AppStrings.get('insights').toUpperCase() : '${AppStrings.get('insights')} ', 
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: isModern ? FontWeight.w900 : FontWeight.w900, 
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: isModern ? 20 : 26,
                letterSpacing: isModern ? 1.5 : 0,
              )
            ),
            if (!isModern) Icon(Icons.bar_chart_outlined, color: Theme.of(context).colorScheme.onSurface, size: 28),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: !isModern,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: isModern ? Colors.transparent : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: isModern ? Border.all(color: const Color(0xFFE2E8F0), width: 1.5) : null,
                  boxShadow: isModern ? [] : [
                    BoxShadow(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: _tabKeys.map((tab) {
                    final isSelected = _selectedTab == tab;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = tab),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? (isModern ? const Color(0xFF1E293B) : Theme.of(context).colorScheme.primary) : Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Center(
                            child: Text(
                              _localizedTab(tab),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: isSelected 
                                    ? Colors.white 
                                    : (isModern ? const Color(0xFF64748B) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 32),

              // Insight Card
              PastelCard(
                backgroundColor: isModern ? Colors.white : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isModern ? const Color(0xFFF1F5F9) : Colors.white.withValues(alpha: 0.5), 
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lightbulb_outline_rounded, color: isModern ? const Color(0xFF1E293B) : Theme.of(context).colorScheme.onSurface, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(insight['title']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(insight['subtitle']!, style: TextStyle(color: isModern ? const Color(0xFF64748B) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(AppStrings.get('feeding_pattern'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              _buildFeedingTimeline(todayFoodLogs, isModern),

              const SizedBox(height: 32),

              Text(AppStrings.get('stats'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildStatBox('$totalMeals', AppStrings.get('meals'), Icons.restaurant_outlined, isModern)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatBox('$totalLitter', AppStrings.get('litter'), Icons.cleaning_services_outlined, isModern)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatBox('$totalWater', AppStrings.get('water'), Icons.water_drop_outlined, isModern)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatBox(latestWeight, AppStrings.get('weight'), Icons.monitor_weight_outlined, isModern)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatBox('$streak', AppStrings.get('day_streak'), Icons.local_fire_department_outlined, isModern)),
                ],
              ),
              const SizedBox(height: 32),

              Text(AppStrings.get('weight'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              _buildWeightChart(filteredLogs),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateStreak(List careLogs) {
    final now = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final day = DateTime(now.year, now.month, now.day - i);
      final hasLog = careLogs.any((l) => l.timestamp.year == day.year && l.timestamp.month == day.month && l.timestamp.day == day.day);
      if (hasLog) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Map<String, String> _generateInsight(String catName, List filteredLogs) {
    if (filteredLogs.isEmpty) {
      return {
        'title': AppStrings.get('start_recording_insight'),
        'subtitle': AppStrings.get('keep_logging_patterns'),
      };
    }

    final mealCount = filteredLogs.where((l) => l.type == 'food').length;
    return {
      'title': '$catName ${AppStrings.get('had_meals_period')}'.replaceFirst(AppStrings.get('had_meals_period'), '$mealCount ${AppStrings.get('had_meals_period')}'),
      'subtitle': AppStrings.get('keep_logging_patterns'),
    };
  }

  Widget _buildFeedingTimeline(List todayFoodLogs, bool isModern) {
    if (todayFoodLogs.isEmpty) {
      return PastelCard(
        backgroundColor: isModern ? Colors.white : null,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(AppStrings.get('no_meals_logged_today'), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
        ),
      );
    }

    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(height: isModern ? 2 : 4, color: isModern ? const Color(0xFFE2E8F0) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: todayFoodLogs.take(5).map((log) {
              final time = DateFormat(isModern ? 'Hm' : 'jm').format(log.timestamp);
              return _buildTimelinePoint(time, isModern ? const Color(0xFF1E293B) : Theme.of(context).colorScheme.primary, isModern);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelinePoint(String time, Color color, bool isModern) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isModern ? 24 : 36,
          height: isModern ? 24 : 36,
          decoration: BoxDecoration(
            color: isModern ? Colors.white : color.withValues(alpha: 0.6), 
            shape: BoxShape.circle,
            border: isModern ? Border.all(color: color, width: 2) : null,
          ),
          child: Center(child: Icon(Icons.restaurant_outlined, size: isModern ? 12 : 20, color: isModern ? color : Theme.of(context).colorScheme.onSurface)),
        ),
        const SizedBox(height: 4),
        Text(time, style: TextStyle(color: isModern ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: isModern ? FontWeight.w800 : FontWeight.w900, fontSize: 10)),
      ],
    );
  }

  Widget _buildStatBox(String num, String label, IconData icon, bool isModern) {
    return PastelCard(
      backgroundColor: isModern ? Colors.white : null,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(num, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isModern ? 28 : 24, color: isModern ? const Color(0xFF1E293B) : Theme.of(context).colorScheme.onSurface)),
              const SizedBox(width: 8),
              Icon(icon, size: isModern ? 24 : 20, color: isModern ? const Color(0xFF1E293B) : Theme.of(context).colorScheme.onSurface),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isModern ? label.toUpperCase() : label, 
            style: TextStyle(
              color: isModern ? const Color(0xFF64748B) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), 
              fontWeight: isModern ? FontWeight.w800 : FontWeight.w900, 
              fontSize: isModern ? 11 : 12,
              letterSpacing: isModern ? 1.0 : 0.0,
            )
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(List filteredLogs) {
    final weightLogs = filteredLogs.where((l) => l.type == 'weight').toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (weightLogs.isEmpty) {
      return PastelCard(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(AppStrings.get('no_weight_logs_yet', fallback: 'Henüz kilo kaydı yok.'), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
        ),
      );
    }

    final spots = weightLogs.asMap().entries.map((e) {
      final log = e.value;
      final weightStr = log.value.replaceAll(',', '.');
      final weight = double.tryParse(weightStr) ?? 0.0;
      return FlSpot(e.key.toDouble(), weight);
    }).toList();

    return PastelCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Theme.of(context).colorScheme.primaryContainer,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

