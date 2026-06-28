import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/providers/cat_provider.dart';
import '../../care_tracking/providers/care_log_provider.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/pastel_card.dart';
import '../../../shared/widgets/pastel_action_button.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/locale_provider.dart';
import '../widgets/modern_dashboard.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final themeType = ref.watch(themeProvider);

    // Modern theme uses bento-box dashboard
    if (themeType == AppThemeType.modern) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: const SafeArea(child: ModernDashboard()),
      );
    }

    // Playful & Dark themes use existing kawaii dashboard
    final cats = ref.watch(catListProvider);
    final selectedCat = ref.watch(selectedCatProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 32,
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: cats.isEmpty ? _buildEmptyState(context) : _buildDashboard(context, ref, selectedCat, cats),
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
            Icon(Icons.pets, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              AppStrings.get('welcome'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.get('add_furry_friend'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/cat-form'),
              icon: const Icon(Icons.add_rounded),
              label: Text(AppStrings.get('add_cat'), style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, selectedCat, cats) {
    if (selectedCat == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cat Selector (horizontal scroll)
          if (cats.isNotEmpty) ...[
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cats.length + 1, // +1 for add button
                itemBuilder: (context, index) {
                  if (index == cats.length) {
                    // Add cat button
                    return GestureDetector(
                      onTap: () => context.push('/cat-form'),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).cardColor,
                                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15), width: 2, style: BorderStyle.solid),
                              ),
                              child: Icon(Icons.add_rounded, size: 28, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                            ),
                            const SizedBox(height: 6),
                            Text(AppStrings.get('add'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
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
                            width: isSelected ? 64 : 56,
                            height: isSelected ? 64 : 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                              border: Border.all(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                                width: isSelected ? 3 : 2,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                                  : [],
                              image: cat.photoPath != null && cat.photoPath!.isNotEmpty
                                  ? DecorationImage(image: ResizeImage(FileImage(File(cat.photoPath!)), width: 150), fit: BoxFit.cover)
                                  : const DecorationImage(image: AssetImage('assets/images/cat_avatar.png'), fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Kawaii Cat Profile Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => context.push('/cat-form', extra: selectedCat),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                    image: selectedCat.photoPath != null && selectedCat.photoPath!.isNotEmpty
                        ? DecorationImage(image: ResizeImage(FileImage(File(selectedCat.photoPath!)), width: 250), fit: BoxFit.cover)
                        : const DecorationImage(image: AssetImage('assets/images/cat_avatar.png'), fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCat.name,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 36,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (selectedCat.breed != null && selectedCat.breed!.isNotEmpty)
                    Text(
                      selectedCat.breed!,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  Text(
                    _calculateAge(selectedCat.birthDate),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(Icons.pets, color: Theme.of(context).colorScheme.secondary, size: 28),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Quick Actions
          Text(AppStrings.get('quick_actions'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 22, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PastelActionButton(
                title: AppStrings.get('fed_action'),
                icon: AppIcons.bowl(),
                color: Theme.of(context).colorScheme.secondary,
                onTap: () => _addCareLog(ref, 'food', AppStrings.get('fed')),
              ),
              PastelActionButton(
                title: AppStrings.get('litter_action'),
                icon: AppIcons.litter(),
                color: Theme.of(context).colorScheme.tertiary,
                onTap: () => _addCareLog(ref, 'litter', AppStrings.get('cleaned')),
              ),
              PastelActionButton(
                title: AppStrings.get('water_action'),
                icon: AppIcons.water(),
                color: Theme.of(context).colorScheme.secondaryContainer,
                onTap: () => _addCareLog(ref, 'water', AppStrings.get('refilled')),
              ),
            ],
          ),

          const SizedBox(height: 24),
          
          // Today Summary with Peeking Cats
          Text(AppStrings.get('today_summary'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 22, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 16),
          
          KawaiiSummaryCard(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
            icon: AppIcons.bowl(),
            title: AppStrings.get('meals_label'),
            valueBuilder: (ref) {
              final logs = ref.watch(careLogListProvider);
              final today = DateTime.now();
              final todayLogs = logs.where((m) => m.type == 'food' && m.timestamp.day == today.day).toList();
              if (todayLogs.isEmpty) return AppStrings.get('no_meals_fed_yet');
              return '${todayLogs.length} ${AppStrings.get('meals_fed')}\n${AppStrings.get('last')} ${DateFormat.jm().format(todayLogs.last.timestamp)}';
            },
          ),
          const SizedBox(height: 16),
          KawaiiSummaryCard(
            color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5),
            icon: AppIcons.litter(),
            title: AppStrings.get('litter_label'),
            valueBuilder: (ref) {
              final logs = ref.watch(careLogListProvider);
              final today = DateTime.now();
              final todayLogs = logs.where((m) => m.type == 'litter' && m.timestamp.day == today.day).toList();
              if (todayLogs.isEmpty) return AppStrings.get('not_cleaned_today');
              return '${AppStrings.get('status_clean')}\n${AppStrings.get('checked')} ${DateFormat.jm().format(todayLogs.last.timestamp)}';
            },
          ),
          const SizedBox(height: 16),
          
          // Water Tracking
          KawaiiSummaryCard(
            color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
            icon: AppIcons.water(),
            title: AppStrings.get('water'),
            valueBuilder: (ref) {
              final logs = ref.watch(careLogListProvider);
              final today = DateTime.now();
              final todayLogs = logs.where((m) => m.type == 'water' && m.timestamp.day == today.day).toList();
              if (todayLogs.isEmpty) return AppStrings.get('not_refilled_yet');
              return '${AppStrings.get('refilled')}\n${AppStrings.get('last')} ${DateFormat.jm().format(todayLogs.last.timestamp)}';
            },
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }



  ImageProvider _getCatImage(WidgetRef ref) {
    final cat = ref.read(selectedCatProvider);
    if (cat != null && cat.photoPath != null && cat.photoPath!.isNotEmpty) {
      return ResizeImage(FileImage(File(cat.photoPath!)), width: 150);
    }
    return const AssetImage('assets/images/cat_avatar.png');
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    if (months < 0) {
      years--;
      months += 12;
    }
    if (now.day < birthDate.day) {
      months--;
      if (months < 0) {
        years--;
        months += 12;
      }
    }
    if (years > 0 && months > 0) return '$years ${AppStrings.get('yrs')} $months ${AppStrings.get('mo')}';
    if (years > 0) return '$years ${AppStrings.get('years_old')}';
    if (months > 0) return '$months ${AppStrings.get('months_old')}';
    return AppStrings.get('newborn');
  }

  void _addCareLog(WidgetRef ref, String type, String value) {
    ref.read(careLogListProvider.notifier).addLog(type: type, value: value);
  }
}

class KawaiiSummaryCard extends ConsumerWidget {
  final Color color;
  final Widget icon;
  final String title;
  final String Function(WidgetRef ref) valueBuilder;

  const KawaiiSummaryCard({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.valueBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = valueBuilder(ref);
    final parts = text.split('\n');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        PastelCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.2)),
                    const SizedBox(height: 2),
                    Text(parts[0], style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                    if (parts.length > 1)
                      Text(parts[1], style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: -15,
          right: 10,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
              image: DecorationImage(
                image: _getCatImage(ref),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  ImageProvider _getCatImage(WidgetRef ref) {
    final cat = ref.read(selectedCatProvider);
    if (cat != null && cat.photoPath != null && cat.photoPath!.isNotEmpty) {
      return ResizeImage(FileImage(File(cat.photoPath!)), width: 150);
    }
    return const AssetImage('assets/images/cat_avatar.png');
  }
}
