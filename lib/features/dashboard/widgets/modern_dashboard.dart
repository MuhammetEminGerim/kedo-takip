import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/providers/cat_provider.dart';
import '../../care_tracking/providers/care_log_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/locale_provider.dart';

class ModernDashboard extends ConsumerWidget {
  const ModernDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final cats = ref.watch(catListProvider);
    final selectedCat = ref.watch(selectedCatProvider);

    if (cats.isEmpty) return _buildEmptyState(context);
    if (selectedCat == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar: App name + Date
          _buildTopBar(context),
          const SizedBox(height: 20),

          // Cat Selector
          _buildCatSelector(context, ref, cats, selectedCat),
          const SizedBox(height: 20),

          // Hero Card: Today's Overview
          _buildHeroCard(context, ref, selectedCat),
          const SizedBox(height: 16),

          // 2x2 Grid: Food, Water, Litter, Activity
          _buildBentoGrid(context, ref),
          const SizedBox(height: 16),

          // Recent Activity
          _buildRecentActivity(context, ref),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 64, color: Color(0xFF1E293B)),
            const SizedBox(height: 24),
            Text(
              AppStrings.get('welcome'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.get('add_furry_friend'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/cat-form'),
              icon: const Icon(Icons.add_rounded),
              label: Text(AppStrings.get('add_cat')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMM').format(now).toUpperCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.pets, size: 20, color: Color(0xFF1E293B)),
            SizedBox(width: 8),
            Text(
              'PAWLOG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        Text(
          dateStr,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCatSelector(BuildContext context, WidgetRef ref, List cats, selectedCat) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length + 1,
        itemBuilder: (context, index) {
          if (index == cats.length) {
            return GestureDetector(
              onTap: () => context.push('/cat-form'),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF1F5F9),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                      ),
                      child: const Icon(Icons.add_rounded, size: 24, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.get('add'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            );
          }
          final cat = cats[index];
          final isSelected = selectedCat?.id == cat.id;
          return GestureDetector(
            onTap: () => ref.read(selectedCatProvider.notifier).setCat(cat),
            onLongPress: () => context.push('/cat-form', extra: cat),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 56 : 48,
                    height: isSelected ? 56 : 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      image: cat.photoPath != null && cat.photoPath!.isNotEmpty
                          ? DecorationImage(image: ResizeImage(FileImage(File(cat.photoPath!)), width: 150), fit: BoxFit.cover)
                          : const DecorationImage(image: AssetImage('assets/images/cat_avatar.png'), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, WidgetRef ref, selectedCat) {
    final now = DateTime.now();
    final timeStr = DateFormat.jm().format(now);

    return _ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.locale == 'tr' ? "BUGÜNÜN ÖZETİ" : "TODAY'S OVERVIEW",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    image: selectedCat.photoPath != null && selectedCat.photoPath!.isNotEmpty
                        ? DecorationImage(image: ResizeImage(FileImage(File(selectedCat.photoPath!)), width: 150), fit: BoxFit.cover)
                        : const DecorationImage(image: AssetImage('assets/images/cat_avatar.png'), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedCat.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppStrings.locale == 'tr' ? 'İlerleme' : 'Progress'}: $timeStr',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: const Icon(Icons.settings_outlined, size: 22, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(careLogListProvider);
    final today = DateTime.now();

    final foodLogs = logs.where((m) => m.type == 'food' && m.timestamp.day == today.day && m.timestamp.month == today.month).toList();
    final waterLogs = logs.where((m) => m.type == 'water' && m.timestamp.day == today.day && m.timestamp.month == today.month).toList();
    final litterLogs = logs.where((m) => m.type == 'litter' && m.timestamp.day == today.day && m.timestamp.month == today.month).toList();

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _BentoCard(
                  icon: Icons.restaurant_outlined,
                  title: AppStrings.locale == 'tr' ? 'MAMA' : 'FOOD',
                  subtitle: AppStrings.locale == 'tr' ? 'Yaş & Kuru' : 'Wet & Dry',
                  details: [
                    foodLogs.isEmpty
                        ? AppStrings.get('no_meals_fed_yet')
                        : '${foodLogs.length} ${AppStrings.locale == 'tr' ? 'Öğün Verildi' : 'meals fed'}',
                    if (foodLogs.isNotEmpty)
                      '${AppStrings.locale == 'tr' ? 'Son' : 'Last'}: ${DateFormat.Hm().format(foodLogs.last.timestamp)}',
                  ],
                  onTap: () => _addCareLog(ref, 'food', AppStrings.get('fed')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BentoCard(
                  icon: Icons.water_drop_outlined,
                  title: AppStrings.locale == 'tr' ? 'SU' : 'WATER',
                  subtitle: AppStrings.locale == 'tr' ? 'Hidrasyon' : 'Hydration',
                  details: [
                    waterLogs.isEmpty
                        ? (AppStrings.locale == 'tr' ? 'Henüz su verilmedi' : 'No water yet')
                        : '${waterLogs.length}x ${AppStrings.locale == 'tr' ? 'yenilendi' : 'refilled'}',
                    if (waterLogs.isNotEmpty)
                      '${AppStrings.locale == 'tr' ? 'Son' : 'Last'}: ${DateFormat.Hm().format(waterLogs.last.timestamp)}',
                  ],
                  circularValue: waterLogs.isEmpty ? null : (waterLogs.length / 5 * 100).clamp(0, 100).toInt(),
                  onTap: () => _addCareLog(ref, 'water', AppStrings.get('refilled')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _BentoCard(
                  icon: Icons.inventory_2_outlined,
                  title: AppStrings.locale == 'tr' ? 'KUM' : 'LITTER',
                  subtitle: AppStrings.locale == 'tr' ? 'Aktivite' : 'Activity',
                  details: [
                    litterLogs.isEmpty
                        ? AppStrings.get('not_cleaned_today')
                        : '${AppStrings.locale == 'tr' ? 'Temizlendi' : 'Scooped'}: ${litterLogs.length}x',
                    if (litterLogs.isNotEmpty)
                      '${AppStrings.locale == 'tr' ? 'Son' : 'Last'}: ${DateFormat.Hm().format(litterLogs.last.timestamp)}',
                  ],
                  onTap: () => _addCareLog(ref, 'litter', AppStrings.get('cleaned')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BentoCard(
                  icon: Icons.monitor_heart_outlined,
                  title: AppStrings.locale == 'tr' ? 'AKTİVİTE' : 'ACTIVITY',
                  subtitle: AppStrings.locale == 'tr' ? 'Takip & Sağlık' : 'Track & Health',
                  details: [
                    '${AppStrings.locale == 'tr' ? 'Bugünkü kayıt' : "Today's logs"}: ${logs.where((l) => l.timestamp.day == today.day && l.timestamp.month == today.month).length}',
                  ],
                  onTap: () => GoRouter.of(context).go('/analytics'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(careLogListProvider);
    final today = DateTime.now();
    final todayLogs = logs
        .where((l) => l.timestamp.day == today.day && l.timestamp.month == today.month)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final displayLogs = todayLogs.take(5).toList();

    return _ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.locale == 'tr' ? 'SON AKTİVİTELER' : 'RECENT ACTIVITY',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            if (displayLogs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  AppStrings.locale == 'tr' ? 'Henüz kayıt yok' : 'No records yet',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
              )
            else
              ...displayLogs.map((log) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        DateFormat.Hm().format(log.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            _getLogIcon(log.type),
                            size: 16,
                            color: const Color(0xFF1E293B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getLogLabel(log.type, log.value ?? ''),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  String _getLogLabel(String type, String value) {
    final isTr = AppStrings.locale == 'tr';
    switch (type) {
      case 'food':
        return isTr ? 'Mama verildi' : 'Fed';
      case 'water':
        return isTr ? 'Su yenilendi' : 'Water Refill';
      case 'litter':
        return isTr ? 'Kum temizlendi' : 'Litter Cleaned';
      default:
        return value;
    }
  }

  IconData _getLogIcon(String type) {
    switch (type) {
      case 'food':
        return Icons.restaurant_outlined;
      case 'water':
        return Icons.water_drop_outlined;
      case 'litter':
        return Icons.cleaning_services_outlined;
      case 'weight':
        return Icons.monitor_weight_outlined;
      default:
        return Icons.check;
    }
  }

  void _addCareLog(WidgetRef ref, String type, String value) {
    ref.read(careLogListProvider.notifier).addLog(type: type, value: value);
  }
}

/// Clean white card with subtle border — core of the modern bento design
class _ModernCard extends StatelessWidget {
  final Widget child;
  const _ModernCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: child,
    );
  }
}

/// Individual bento grid card (Food, Water, Litter, Activity)
class _BentoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> details;
  final int? circularValue;
  final VoidCallback? onTap;

  const _BentoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.details,
    this.circularValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF1E293B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (circularValue != null) ...[
              Center(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: circularValue! / 100,
                        strokeWidth: 4,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E293B)),
                      ),
                      Text(
                        '$circularValue%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            ...details.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                d,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
