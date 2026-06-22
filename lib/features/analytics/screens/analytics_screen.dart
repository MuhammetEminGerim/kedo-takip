import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../meow_record/providers/meow_record_provider.dart';
import '../../care_tracking/providers/care_log_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pastel_card.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedTab = 'Week';

  @override
  Widget build(BuildContext context) {
    final meowRecords = ref.watch(meowRecordListProvider);
    final careLogs = ref.watch(careLogListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Insights ', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulText)),
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
                  children: ['Week', 'Month', 'All'].map((tab) {
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
                              tab,
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
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 10,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            if (value < 0 || value >= days.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(days[value.toInt()], style: TextStyle(color: AppColors.playfulText.withOpacity(0.6), fontWeight: FontWeight.w900, fontSize: 12)),
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
                    barGroups: List.generate(7, (index) {
                      final val = (index % 3 == 0) ? 6.0 : (index % 2 == 0) ? 4.0 : 8.0;
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
                          const Text('Pamuk meows most before meals!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Evening activity up 30% this week', style: TextStyle(color: AppColors.playfulText.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text('Feeding pattern', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              _buildTimeline(),

              const SizedBox(height: 32),
              
              Text('Mood trends', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMoodCircle(Icons.sentiment_very_satisfied_outlined, AppColors.playfulPrimary),
                  _buildMoodCircle(Icons.sentiment_satisfied_outlined, AppColors.playfulPrimary),
                  _buildMoodCircle(Icons.sentiment_satisfied_outlined, AppColors.playfulSecondary),
                  _buildMoodCircle(Icons.sentiment_neutral_outlined, AppColors.playfulSecondary),
                  _buildMoodCircle(Icons.sentiment_neutral_outlined, AppColors.playfulSecondary),
                  _buildMoodCircle(Icons.sentiment_dissatisfied_outlined, AppColors.playfulTertiary),
                  _buildMoodCircle(Icons.sentiment_very_dissatisfied_outlined, AppColors.playfulTertiary),
                ],
              ),

              const SizedBox(height: 32),

              Text('Stats', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatBox('47', 'recordings', Icons.mic_none_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatBox('21', 'meals', Icons.restaurant_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatBox('7', 'day streak', Icons.local_fire_department_outlined)),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(height: 4, color: AppColors.playfulPrimary.withOpacity(0.2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelinePoint('8am', AppColors.playfulPrimary),
              _buildTimelinePoint('1pm', AppColors.playfulAccentPeach),
              _buildTimelinePoint('7pm', AppColors.playfulSecondary),
            ],
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
        Text(time, style: TextStyle(color: AppColors.playfulText.withOpacity(0.6), fontWeight: FontWeight.w900, fontSize: 12)),
      ],
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
