import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/pastel_card.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_theme.dart';

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
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              title: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.onSurface,
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
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    AppStrings.get('set_training_progress'),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, sliderVal.round()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
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
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
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
                child: Center(child: Icon(icon, size: 28, color: Theme.of(context).colorScheme.onSurface)),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: tips.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    return PastelCard(
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
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tips[i],
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
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
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }

    ref.watch(localeProvider);
    final isModern = ref.watch(themeProvider) == AppThemeType.modern;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: isModern ? MainAxisAlignment.start : MainAxisAlignment.start,
          children: [
            Text(
              isModern ? AppStrings.get('training').toUpperCase() : '${AppStrings.get('training')} ',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: isModern ? 1.5 : 0,
                    fontSize: isModern ? 20 : 24,
                  ),
            ),
            if (!isModern) Icon(Icons.school_outlined, color: Theme.of(context).colorScheme.onSurface, size: 28),
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
              if (isModern)
                _buildModernClickerSection()
              else ...[
                Text(
                  AppStrings.get('clicker_button'),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _onClickerTap,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            AppStrings.get('click'),
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onSurface,
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
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          AppStrings.get('today'),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // ─── Training Plan ───
              if (isModern)
                _buildModernTrainingPlan()
              else ...[
                Text(
                  AppStrings.get('cute_training_plan'),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildTrainingPlanCard(AppStrings.get('sit'), 'sit', Icons.chair_alt_outlined, Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 16),
                      _buildTrainingPlanCard(AppStrings.get('come'), 'come', Icons.pets_outlined, Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 16),
                      _buildTrainingPlanCard(AppStrings.get('high_five'), 'highfive', Icons.pan_tool_outlined, Theme.of(context).colorScheme.tertiary),
                      const SizedBox(width: 16),
                      _buildTrainingPlanCard(AppStrings.get('carrier'), 'carrier', Icons.inventory_2_outlined, Theme.of(context).colorScheme.primaryContainer),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ─── Streak Card ───
              if (isModern)
                _buildModernStreakCard()
              else ...[
                PastelCard(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_fire_department_outlined,
                            color: _streak > 0 ? Colors.deepOrange : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$_streak ${AppStrings.get('day_streak_label')}',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        _streak > 0 ? AppStrings.get('keep_going') : AppStrings.get('tap_clicker_to_start'),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ─── Guides ───
              Row(
                children: [
                  Text(
                    isModern ? AppStrings.get('guides').toUpperCase() : '${AppStrings.get('guides')} ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: isModern ? 16 : 18,
                      letterSpacing: isModern ? 1.0 : 0,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (!isModern) Icon(Icons.menu_book_outlined, size: 20, color: Theme.of(context).colorScheme.onSurface),
                ],
              ),
              const SizedBox(height: 16),
              _buildGuideCard(
                AppStrings.get('night_crying'),
                Icons.nights_stay_outlined,
                Theme.of(context).colorScheme.tertiary,
                AppStrings.get('night_crying_tips').split('|'),
                isModern,
              ),
              const SizedBox(height: 12),
              _buildGuideCard(
                AppStrings.get('scratching'),
                Icons.pets_outlined,
                Theme.of(context).colorScheme.primary,
                AppStrings.get('scratching_tips').split('|'),
                isModern,
              ),
              const SizedBox(height: 12),
              _buildGuideCard(
                AppStrings.get('biting'),
                Icons.mood_bad_outlined,
                Theme.of(context).colorScheme.primaryContainer,
                AppStrings.get('biting_tips').split('|'),
                isModern,
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
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4),
                Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface),
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
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Spacer(),
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

  Widget _buildGuideCard(String title, IconData icon, Color accentColor, List<String> tips, bool isModern) {
    if (isModern) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
      final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

      return GestureDetector(
        onTap: () => _showGuideBottomSheet(title, icon, accentColor, tips),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: accentColor, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor)),
                    const SizedBox(height: 2),
                    Text(AppStrings.get('read_more'), style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), size: 24),
            ],
          ),
        ),
      );
    }

    return PastelCard(
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
            child: Center(child: Icon(icon, size: 24, color: Theme.of(context).colorScheme.onSurface)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppStrings.get('read_more'),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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

  Widget _buildModernClickerSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.get('clicker_button').toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 1.0),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _onClickerTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.touch_app_outlined, color: Theme.of(context).colorScheme.primary, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.get('click'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: textColor)),
                      const SizedBox(height: 4),
                      Text('$_tapsToday ${AppStrings.get('taps')} ${AppStrings.get('today').toLowerCase()}', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTrainingPlan() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.get('cute_training_plan').toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 1.0),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildModernTrainingCard(AppStrings.get('sit'), 'sit', Icons.airline_seat_recline_normal, Colors.orange),
            _buildModernTrainingCard(AppStrings.get('come'), 'come', Icons.directions_walk, Colors.blue),
            _buildModernTrainingCard(AppStrings.get('high_five'), 'highfive', Icons.pan_tool_outlined, Colors.purple),
            _buildModernTrainingCard(AppStrings.get('carrier'), 'carrier', Icons.inventory_2_outlined, Colors.teal),
          ],
        ),
      ],
    );
  }

  Widget _buildModernTrainingCard(String title, String key, IconData icon, Color color) {
    final progress = _trainingProgress[key] ?? 0;
    final fraction = progress / 100.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return GestureDetector(
      onTap: () => _showTrainingDialog(key, title, color),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Text('$progress%', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: fraction,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStreakCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _streak > 0 ? Colors.deepOrange.withValues(alpha: 0.15) : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_fire_department_outlined, color: _streak > 0 ? Colors.deepOrange : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_streak ${AppStrings.get('day_streak_label')}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textColor)),
                const SizedBox(height: 4),
                Text(_streak > 0 ? AppStrings.get('keep_going') : AppStrings.get('tap_clicker_to_start'), style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
