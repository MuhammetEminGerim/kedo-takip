import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pastel_card.dart';
import '../../../core/constants/app_strings.dart';

class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  int _tapsToday = 0;
  int _streak = 0;
  bool _loaded = false;

  final Map<String, int> _trainingProgress = {
    'sit': 0,
    'come': 0,
    'highfive': 0,
    'carrier': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  String _todayString() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final storedDate = prefs.getString('clicker_date') ?? '';

    if (storedDate == today) {
      _tapsToday = prefs.getInt('clicker_count') ?? 0;
    } else {
      if (storedDate.isNotEmpty) {
        final historyRaw = prefs.getString('clicker_history') ?? '[]';
        final List<String> history = List<String>.from(jsonDecode(historyRaw));
        if (!history.contains(storedDate)) {
          history.add(storedDate);
        }
        await prefs.setString('clicker_history', jsonEncode(history));
      }
      _tapsToday = 0;
      await prefs.setString('clicker_date', today);
      await prefs.setInt('clicker_count', 0);
    }

    for (final key in _trainingProgress.keys) {
      _trainingProgress[key] = prefs.getInt('training_$key') ?? 0;
    }

    _streak = _calculateStreak(prefs);

    setState(() {
      _loaded = true;
    });
  }

  int _calculateStreak(SharedPreferences prefs) {
    final historyRaw = prefs.getString('clicker_history') ?? '[]';
    final List<String> history = List<String>.from(jsonDecode(historyRaw));

    final today = _todayString();
    final storedDate = prefs.getString('clicker_date') ?? '';
    final storedCount = prefs.getInt('clicker_count') ?? 0;
    if (storedDate == today && storedCount > 0 && !history.contains(today)) {
      history.add(today);
    }

    if (history.isEmpty) return 0;

    final dates = history.map((s) => DateTime.parse(s)).toList()
      ..sort((a, b) => b.compareTo(a));

    final uniqueDates = <DateTime>[];
    for (final d in dates) {
      if (uniqueDates.isEmpty || uniqueDates.last != d) {
        uniqueDates.add(d);
      }
    }

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    int streak = 0;
    DateTime checkDate = todayDate;

    if (uniqueDates.isNotEmpty && _isSameDay(uniqueDates.first, todayDate)) {
      streak = 1;
      checkDate = todayDate.subtract(const Duration(days: 1));
      for (int i = 1; i < uniqueDates.length; i++) {
        if (_isSameDay(uniqueDates[i], checkDate)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    } else {
      final yesterday = todayDate.subtract(const Duration(days: 1));
      if (uniqueDates.isNotEmpty && _isSameDay(uniqueDates.first, yesterday)) {
        streak = 1;
        checkDate = yesterday.subtract(const Duration(days: 1));
        for (int i = 1; i < uniqueDates.length; i++) {
          if (_isSameDay(uniqueDates[i], checkDate)) {
            streak++;
            checkDate = checkDate.subtract(const Duration(days: 1));
          } else {
            break;
          }
        }
      }
    }

    return streak;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _onClickerTap() async {
    final prefs = await SharedPreferences.getInstance();
    _tapsToday++;
    await prefs.setInt('clicker_count', _tapsToday);
    await prefs.setString('clicker_date', _todayString());

    _streak = _calculateStreak(prefs);
    setState(() {});
  }

  Future<void> _showTrainingDialog(String key, String title, Color color) async {
    final prefs = await SharedPreferences.getInstance();
    double currentVal = (_trainingProgress[key] ?? 0).toDouble();

    if (!mounted) return;

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        double sliderVal = currentVal;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.playfulBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              title: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.playfulText,
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${sliderVal.round()}%',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: AppColors.playfulText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.get('set_training_progress'),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: AppColors.playfulText.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: color,
                      inactiveTrackColor: color.withValues(alpha: 0.2),
                      thumbColor: Colors.white,
                      overlayColor: color.withValues(alpha: 0.15),
                      trackHeight: 10,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                    ),
                    child: Slider(
                      value: sliderVal,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      onChanged: (v) {
                        setDialogState(() {
                          sliderVal = v;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    AppStrings.get('cancel'),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      color: AppColors.playfulText.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, sliderVal.round()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: AppColors.playfulText,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(
                    AppStrings.get('save'),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      _trainingProgress[key] = result;
      await prefs.setInt('training_$key', result);
      setState(() {});
    }
  }

  void _showGuideBottomSheet(String title, IconData icon, Color accentColor, List<String> tips) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
          ),
          decoration: const BoxDecoration(
            color: AppColors.playfulBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.playfulText.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Icon(icon, size: 28, color: AppColors.playfulText)),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.playfulText,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: tips.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    return PastelCard(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: AppColors.playfulText,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tips[i],
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: AppColors.playfulText,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.playfulPrimary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              '${AppStrings.get('training')} ',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.playfulText,
                  ),
            ),
            const Icon(Icons.school_outlined, color: AppColors.playfulText, size: 28),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Clicker Section ───
              Text(
                AppStrings.get('clicker_button'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.playfulText,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: _onClickerTap,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.playfulSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.playfulSecondary.withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          AppStrings.get('click'),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: AppColors.playfulText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_tapsToday ${AppStrings.get('taps')}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          color: AppColors.playfulText,
                        ),
                      ),
                      Text(
                        AppStrings.get('today'),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: AppColors.playfulText.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ─── Training Plan ───
              Text(
                AppStrings.get('cute_training_plan'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.playfulText,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildTrainingPlanCard(AppStrings.get('sit'), 'sit', Icons.chair_alt_outlined, AppColors.playfulSecondary),
                    const SizedBox(width: 16),
                    _buildTrainingPlanCard(AppStrings.get('come'), 'come', Icons.pets_outlined, AppColors.playfulPrimary),
                    const SizedBox(width: 16),
                    _buildTrainingPlanCard(AppStrings.get('high_five'), 'highfive', Icons.pan_tool_outlined, AppColors.playfulTertiary),
                    const SizedBox(width: 16),
                    _buildTrainingPlanCard(AppStrings.get('carrier'), 'carrier', Icons.inventory_2_outlined, AppColors.playfulAccentPeach),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Streak Card ───
              PastelCard(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department_outlined,
                          color: _streak > 0 ? Colors.deepOrange : AppColors.playfulText.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_streak ${AppStrings.get('day_streak_label')}',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: AppColors.playfulText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _streak > 0 ? AppStrings.get('keep_going') : AppStrings.get('tap_clicker_to_start'),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: AppColors.playfulText.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ─── Guides ───
              Row(
                children: [
                  Text(
                    '${AppStrings.get('guides')} ',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.playfulText,
                    ),
                  ),
                  const Icon(Icons.menu_book_outlined, size: 20, color: AppColors.playfulText),
                ],
              ),
              const SizedBox(height: 16),
              _buildGuideCard(
                AppStrings.get('night_crying'),
                Icons.nights_stay_outlined,
                AppColors.playfulTertiary,
                AppStrings.get('night_crying_tips').split('|'),
              ),
              const SizedBox(height: 12),
              _buildGuideCard(
                AppStrings.get('scratching'),
                Icons.pets_outlined,
                AppColors.playfulPrimary,
                AppStrings.get('scratching_tips').split('|'),
              ),
              const SizedBox(height: 12),
              _buildGuideCard(
                AppStrings.get('biting'),
                Icons.mood_bad_outlined,
                AppColors.playfulAccentPeach,
                AppStrings.get('biting_tips').split('|'),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingPlanCard(String title, String key, IconData icon, Color color) {
    final progress = _trainingProgress[key] ?? 0;
    final fraction = progress / 100.0;

    return GestureDetector(
      onTap: () => _showTrainingDialog(key, title, color),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.playfulText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, size: 16, color: AppColors.playfulText),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: fraction.clamp(0.0, 1.0),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$progress%',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: AppColors.playfulText,
              ),
            ),
            const Spacer(),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  progress >= 100 ? '⭐' : '🐱',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard(String title, IconData icon, Color accentColor, List<String> tips) {
    return PastelCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: () => _showGuideBottomSheet(title, icon, accentColor, tips),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Icon(icon, size: 24, color: AppColors.playfulText)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.playfulText,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppStrings.get('read_more'),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: AppColors.playfulText.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
