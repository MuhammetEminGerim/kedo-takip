import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../meow_record/providers/meow_record_provider.dart';
import '../../care_tracking/providers/care_log_provider.dart';
import '../../../shared/providers/cat_provider.dart';
import '../../../core/theme/app_colors.dart';
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
    final meowRecords = ref.watch(meowRecordListProvider);
    final careLogs = ref.watch(careLogListProvider);
    final selectedCat = ref.watch(selectedCatProvider);
    final catName = selectedCat?.name ?? AppStrings.get('your_cat');

    // Calculate time range
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int daysBack = _selectedTab == 'Week' ? 7 : _selectedTab == 'Month' ? 30 : 365;
    final startDate = today.subtract(Duration(days: daysBack - 1));

    // Filter records by time range
    final filteredMeows = meowRecords.where((m) => m.timestamp.isAfter(startDate)).toList();
    final filteredLogs = careLogs.where((l) => l.timestamp.isAfter(startDate)).toList();

    // Calculate real stats
    final totalMeows = filteredMeows.length;
    final totalMeals = filteredLogs.where((l) => l.type == 'food').length;
    final streak = _calculateStreak(meowRecords, careLogs);

    // Build daily meow counts for chart
    final chartDays = _selectedTab == 'Week' ? 7 : _selectedTab == 'Month' ? 7 : 7; // Always show 7 bars
    final chartData = _buildChartData(meowRecords, chartDays);

    // Get today's food logs for timeline
    final todayFoodLogs = careLogs
        .where((l) => l.type == 'food' && l.timestamp.day == now.day && l.timestamp.month == now.month && l.timestamp.year == now.year)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Get mood logs for trend
    final moodLogs = careLogs.where((l) => l.type == 'mood').toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final recentMoods = moodLogs.take(7).toList();

    // Generate insight
    final insight = _generateInsight(catName, filteredMeows, filteredLogs);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${AppStrings.get('insights')} ', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulText)),
            const Icon(Icons.bar_chart_outlined, color: AppColors.playfulText, size: 28),
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
                    BoxShadow(color: AppColors.playfulText.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
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
                            color: isSelected ? AppColors.playfulPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Center(
                            child: Text(
                              _localizedTab(tab),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.white : AppColors.playfulText.withOpacity(0.6),
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
              
              // Bar Chart
              SizedBox(
                height: 200,
                child: filteredMeows.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart_outlined, size: 48, color: AppColors.playfulText.withOpacity(0.2)),
                            const SizedBox(height: 8),
                            Text(AppStrings.get('no_meow_data_yet'), style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.playfulText.withOpacity(0.4))),
                          ],
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxY(chartData),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${rod.toY.toInt()} ${AppStrings.get('meows_tooltip')}',
                                  const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value < 0 || value >= chartData.length) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      chartData[value.toInt()]['label'] as String,
                                      style: TextStyle(color: AppColors.playfulText.withOpacity(0.6), fontWeight: FontWeight.w900, fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 2,
                            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.playfulText.withOpacity(0.05), strokeWidth: 2),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(chartData.length, (index) {
                            final val = (chartData[index]['count'] as int).toDouble();
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: val,
                                  gradient: LinearGradient(
                                    colors: [AppColors.playfulPrimary.withOpacity(0.5), AppColors.playfulAccentPeach],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  width: 24,
                                  borderRadius: BorderRadius.circular(6),
                                )
                              ],
                            );
                          }),
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // Insight Card
              PastelCard(
                backgroundColor: AppColors.playfulAccentPeach.withOpacity(0.5),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
                      child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.playfulText, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(insight['title']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(insight['subtitle']!, style: TextStyle(color: AppColors.playfulText.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
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
              
              Text(AppStrings.get('mood_trends'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              _buildMoodTrend(recentMoods),

              const SizedBox(height: 32),

              Text(AppStrings.get('stats'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatBox('$totalMeows', AppStrings.get('recordings'), Icons.mic_none_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatBox('$totalMeals', AppStrings.get('meals'), Icons.restaurant_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatBox('$streak', AppStrings.get('day_streak'), Icons.local_fire_department_outlined)),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildChartData(List meowRecords, int displayDays) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    if (_selectedTab == 'Week') {
      // Last 7 days
      return List.generate(7, (i) {
        final day = today.subtract(Duration(days: 6 - i));
        final count = meowRecords.where((m) {
          final d = m.timestamp;
          return d.year == day.year && d.month == day.month && d.day == day.day;
        }).length;
        return {'label': dayLabels[day.weekday - 1], 'count': count};
      });
    } else if (_selectedTab == 'Month') {
      // Last 4 weeks, grouped by week
      return List.generate(4, (i) {
        final weekEnd = today.subtract(Duration(days: (3 - i) * 7));
        final weekStart = weekEnd.subtract(const Duration(days: 6));
        final count = meowRecords.where((m) {
          return m.timestamp.isAfter(weekStart.subtract(const Duration(days: 1))) && m.timestamp.isBefore(weekEnd.add(const Duration(days: 1)));
        }).length;
        return {'label': 'W${i + 1}', 'count': count};
      });
    } else {
      // All time - group by last 6 months
      return List.generate(6, (i) {
        final month = DateTime(now.year, now.month - (5 - i), 1);
        final nextMonth = DateTime(month.year, month.month + 1, 1);
        final count = meowRecords.where((m) {
          return m.timestamp.isAfter(month.subtract(const Duration(days: 1))) && m.timestamp.isBefore(nextMonth);
        }).length;
        final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return {'label': monthNames[month.month - 1], 'count': count};
      });
    }
  }

  double _getMaxY(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 10;
    final maxVal = data.map((d) => d['count'] as int).reduce((a, b) => a > b ? a : b);
    return maxVal == 0 ? 5 : (maxVal + 2).toDouble();
  }

  int _calculateStreak(List meowRecords, List careLogs) {
    final now = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final day = DateTime(now.year, now.month, now.day - i);
      final hasMeow = meowRecords.any((m) => m.timestamp.year == day.year && m.timestamp.month == day.month && m.timestamp.day == day.day);
      final hasLog = careLogs.any((l) => l.timestamp.year == day.year && l.timestamp.month == day.month && l.timestamp.day == day.day);
      if (hasMeow || hasLog) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Map<String, String> _generateInsight(String catName, List filteredMeows, List filteredLogs) {
    if (filteredMeows.isEmpty && filteredLogs.isEmpty) {
      return {
        'title': AppStrings.get('start_recording_insight'),
        'subtitle': AppStrings.get('record_meows_and_log'),
      };
    }

    // Determine most active time of day
    final hourCounts = <int, int>{};
    for (final m in filteredMeows) {
      final hour = m.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    if (hourCounts.isNotEmpty) {
      final peakHour = hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      final timeOfDay = peakHour < 12 ? 'morning' : peakHour < 17 ? 'afternoon' : 'evening';
      final mealCount = filteredLogs.where((l) => l.type == 'food').length;
      
      String timeInsight;
      switch (timeOfDay) {
        case 'morning':
          timeInsight = AppStrings.get('meows_most_morning');
          break;
        case 'afternoon':
          timeInsight = AppStrings.get('meows_most_afternoon');
          break;
        default:
          timeInsight = AppStrings.get('meows_most_evening');
      }

      return {
        'title': '$catName $timeInsight',
        'subtitle': '$mealCount ${AppStrings.get('meals_logged_period')}',
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
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(AppStrings.get('no_meals_logged_today'), style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.playfulText.withOpacity(0.4))),
        ),
      );
    }

    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(height: 4, color: AppColors.playfulPrimary.withOpacity(0.2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: todayFoodLogs.take(5).map((log) {
              final time = DateFormat.jm().format(log.timestamp);
              return _buildTimelinePoint(time, AppColors.playfulPrimary);
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
          decoration: BoxDecoration(color: color.withOpacity(0.6), shape: BoxShape.circle),
          child: const Center(child: Icon(Icons.restaurant_outlined, size: 20, color: AppColors.playfulText)),
        ),
        const SizedBox(height: 4),
        Text(time, style: TextStyle(color: AppColors.playfulText.withOpacity(0.6), fontWeight: FontWeight.w900, fontSize: 10)),
      ],
    );
  }

  Widget _buildMoodTrend(List recentMoods) {
    if (recentMoods.isEmpty) {
      return PastelCard(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(AppStrings.get('no_mood_data_yet'), style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.playfulText.withOpacity(0.4))),
        ),
      );
    }

    final moodIcons = {
      'very_happy': Icons.sentiment_very_satisfied_outlined,
      'happy': Icons.sentiment_satisfied_outlined,
      'neutral': Icons.sentiment_neutral_outlined,
      'sad': Icons.sentiment_dissatisfied_outlined,
      'angry': Icons.sentiment_very_dissatisfied_outlined,
    };

    final moodColors = {
      'very_happy': AppColors.playfulSecondary,
      'happy': AppColors.playfulSecondary,
      'neutral': AppColors.playfulAccentPeach,
      'sad': AppColors.playfulTertiary,
      'angry': AppColors.playfulPrimary,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: recentMoods.map((log) {
        final icon = moodIcons[log.value] ?? Icons.sentiment_neutral_outlined;
        final color = moodColors[log.value] ?? AppColors.playfulSecondary;
        return _buildMoodCircle(icon, color);
      }).toList(),
    );
  }

  Widget _buildMoodCircle(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color.withOpacity(0.3), shape: BoxShape.circle),
      child: Center(child: Icon(icon, size: 24, color: AppColors.playfulText)),
    );
  }

  Widget _buildStatBox(String num, String label, IconData icon) {
    return PastelCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(num, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
              const SizedBox(width: 6),
              Icon(icon, size: 20, color: AppColors.playfulText),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: AppColors.playfulText.withOpacity(0.6), fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }
}
