import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../shared/providers/cat_provider.dart';
import '../../meow_record/providers/meow_record_provider.dart';
import '../../care_tracking/providers/care_log_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../shared/widgets/pastel_card.dart';
import '../../../shared/widgets/pastel_action_button.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(catListProvider);
    final selectedCat = ref.watch(selectedCatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.playfulText),
            onPressed: () {},
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
            const Icon(Icons.pets, size: 80, color: AppColors.playfulPrimary),
            const SizedBox(height: 24),
            Text(
              'Welcome to PawLog!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add your furry friend to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/cat-form'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Cat', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, selectedCat, cats) {
    if (selectedCat == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kawaii Cat Profile Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.playfulSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: AppColors.playfulPrimary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/cat_avatar.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                selectedCat.name,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 42,
                  color: AppColors.playfulText,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.pets, color: AppColors.playfulSecondary, size: 28),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Quick Actions
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.playfulText)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PastelActionButton(
                title: 'Record',
                icon: AppIcons.mic(),
                color: AppColors.playfulPrimary,
                onTap: () => context.go('/record'),
              ),
              PastelActionButton(
                title: 'Fed',
                icon: AppIcons.bowl(),
                color: AppColors.playfulSecondary,
                onTap: () => _addCareLog(ref, 'food', 'Fed'),
              ),
              PastelActionButton(
                title: 'Litter',
                icon: AppIcons.litter(),
                color: AppColors.playfulTertiary,
                onTap: () => _addCareLog(ref, 'litter', 'Cleaned'),
              ),
              PastelActionButton(
                title: 'Water',
                icon: AppIcons.water(),
                color: AppColors.playfulAccentBlue,
                onTap: () => _addCareLog(ref, 'water', 'Refilled'),
              ),
            ],
          ),

          const SizedBox(height: 24),
          
          // Today Summary with Peeking Cats
          Text('Today Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.playfulText)),
          const SizedBox(height: 16),
          
          _buildKawaiiSummaryCard(
            context,
            ref,
            color: AppColors.playfulPrimary.withOpacity(0.4),
            icon: AppIcons.meow(),
            title: 'MEOWS',
            valueBuilder: () {
              final meows = ref.watch(meowRecordListProvider);
              final today = DateTime.now();
              final todayMeows = meows.where((m) => m.timestamp.day == today.day).toList();
              if (todayMeows.isEmpty) return 'No meows yet';
              return '${todayMeows.length} Meows Recorded\nLast: ${DateFormat.jm().format(todayMeows.last.timestamp)}';
            },
          ),
          const SizedBox(height: 16),
          _buildKawaiiSummaryCard(
            context,
            ref,
            color: AppColors.playfulSecondary.withOpacity(0.5),
            icon: AppIcons.bowl(),
            title: 'MEALS',
            valueBuilder: () {
              final logs = ref.watch(careLogListProvider);
              final today = DateTime.now();
              final todayLogs = logs.where((m) => m.type == 'food' && m.timestamp.day == today.day).toList();
              if (todayLogs.isEmpty) return 'No meals fed yet';
              return '${todayLogs.length} Meals Fed\nLast: ${DateFormat.jm().format(todayLogs.last.timestamp)}';
            },
          ),
          const SizedBox(height: 16),
          _buildKawaiiSummaryCard(
            context,
            ref,
            color: AppColors.playfulTertiary.withOpacity(0.5),
            icon: AppIcons.litter(),
            title: 'LITTER',
            valueBuilder: () {
              final logs = ref.watch(careLogListProvider);
              final today = DateTime.now();
              final todayLogs = logs.where((m) => m.type == 'litter' && m.timestamp.day == today.day).toList();
              if (todayLogs.isEmpty) return 'Not cleaned today';
              return 'Status: Clean\nChecked: ${DateFormat.jm().format(todayLogs.last.timestamp)}';
            },
          ),
          const SizedBox(height: 120), // Padding to ensure content is visible above floating nav bar
        ],
      ),
    );
  }

  Widget _buildKawaiiSummaryCard(BuildContext context, WidgetRef ref, {required Color color, required Widget icon, required String title, required String Function() valueBuilder}) {
    final text = valueBuilder();
    final parts = text.split('\n');
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PastelCard(
          backgroundColor: Colors.white, // In mockup cards are white with colored inner parts
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
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.playfulText, letterSpacing: 1.2)),
                    const SizedBox(height: 2),
                    Text(parts[0], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.playfulText)),
                    if (parts.length > 1)
                      Text(parts[1], style: TextStyle(color: AppColors.playfulText.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
              image: const DecorationImage(
                image: AssetImage('assets/images/cat_avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addCareLog(WidgetRef ref, String type, String value) {
    ref.read(careLogListProvider.notifier).addLog(type: type, value: value);
  }
}
