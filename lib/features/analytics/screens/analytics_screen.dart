import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../care_tracking/providers/care_log_provider.dart';
import '../../../shared/providers/cat_provider.dart';
import '../../../shared/widgets/pastel_card.dart';
import '../../../core/constants/app_strings.dart';

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
          children: [
            Text('${AppStrings.get('insights')} ', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
            Icon(Icons.bar_chart_outlined, color: Theme.of(context).colorScheme.onSurface, size: 28),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
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
                            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Center(
                            child: Text(
                              _localizedTab(tab),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle),
                      child: Icon(Icons.lightbulb_outline_rounded, color: Theme.of(context).colorScheme.onSurface, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(insight['title']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(insight['subtitle']!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(AppStrings.get('feeding_pattern'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              _buildFeedingTimeline(todayFoodLogs),

              const SizedBox(height: 32),

              Text(AppStrings.get('stats'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatBox('$totalMeals', AppStrings.get('meals'), Icons.restaurant_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatBox('$totalLitter', AppStrings.get('litter'), Icons.cleaning_services_outlined)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatBox('$totalWater', AppStrings.get('water'), Icons.water_drop_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatBox(latestWeight, AppStrings.get('weight'), Icons.monitor_weight_outlined)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatBox('$streak', AppStrings.get('day_streak'), Icons.local_fire_department_outlined)),
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

  Widget _buildFeedingTimeline(List todayFoodLogs) {
    if (todayFoodLogs.isEmpty) {
      return PastelCard(
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
          Container(height: 4, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: todayFoodLogs.take(5).map((log) {
              final time = DateFormat.jm().format(log.timestamp);
              return _buildTimelinePoint(time, Theme.of(context).colorScheme.primary);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelinePoint(String time, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.6), shape: BoxShape.circle),
          child: Center(child: Icon(Icons.restaurant_outlined, size: 20, color: Theme.of(context).colorScheme.onSurface)),
        ),
        const SizedBox(height: 4),
        Text(time, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w900, fontSize: 10)),
      ],
    );
  }

  Widget _buildStatBox(String num, String label, IconData icon) {
    return PastelCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(num, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
              const SizedBox(width: 6),
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w900, fontSize: 12)),
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
          child: Text('Henüz kilo kaydı yok.', style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
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

