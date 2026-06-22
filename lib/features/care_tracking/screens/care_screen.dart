import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/care_log_provider.dart';
import '../../../shared/providers/cat_provider.dart';
import '../../../shared/models/care_log.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pastel_card.dart';

class CareScreen extends ConsumerWidget {
  const CareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(careLogListProvider);
    final cats = ref.watch(catListProvider);
    final selectedCat = ref.watch(selectedCatProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Care Log ', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulText, fontSize: 26)),
                const Icon(Icons.pets, color: AppColors.playfulText, size: 24),
              ],
            ),
            const SizedBox(height: 4),
            Text(DateFormat("EEEE, d MMMM").format(DateTime.now()), style: TextStyle(color: AppColors.playfulText.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cat Selector
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cats.length,
                  itemBuilder: (context, index) {
                    final cat = cats[index];
                    final isSelected = selectedCat?.id == cat.id;

                    return GestureDetector(
                      onTap: () => ref.read(selectedCatProvider.notifier).setCat(cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.playfulSurface,
                                border: isSelected ? Border.all(color: AppColors.playfulPrimary, width: 4) : Border.all(color: AppColors.playfulText.withOpacity(0.1), width: 2),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/cat_avatar.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                color: AppColors.playfulText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              _buildCareCard(
                context: context,
                title: 'Food',
                icon: Icons.restaurant_outlined,
                bgColor: AppColors.playfulPrimary,
                lastLog: _getLastLog(logs, 'food'),
                onAdd: () => _addLog(ref, 'food', 'Fed'),
              ),
              const SizedBox(height: 16),
              _buildCareCard(
                context: context,
                title: 'Water',
                icon: Icons.water_drop_outlined,
                bgColor: AppColors.playfulAccentBlue,
                lastLog: _getLastLog(logs, 'water'),
                onAdd: () => _addLog(ref, 'water', 'Refilled'),
              ),
              const SizedBox(height: 16),
              _buildCareCard(
                context: context,
                title: 'Litter',
                icon: Icons.cleaning_services_outlined,
                bgColor: AppColors.playfulSecondary,
                lastLog: _getLastLog(logs, 'litter'),
                onAdd: () => _addLog(ref, 'litter', 'Cleaned'),
              ),
              const SizedBox(height: 16),
              _buildMoodCard(context, ref, _getLastLog(logs, 'mood')),
              const SizedBox(height: 16),
              _buildCareCard(
                context: context,
                title: 'Weight',
                icon: Icons.monitor_weight_outlined,
                bgColor: AppColors.playfulAccentPeach,
                lastLog: _getLastLog(logs, 'weight'),
                onAdd: () {}, // Future task: Add weight popup
              ),
              const SizedBox(height: 100), // padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  CareLog? _getLastLog(List<CareLog> logs, String type) {
    try {
      return logs.firstWhere((l) => l.type == type);
    } catch (_) {
      return null;
    }
  }

  void _addLog(WidgetRef ref, String type, String value) {
    ref.read(careLogListProvider.notifier).addLog(type: type, value: value);
  }

  Widget _buildCareCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color bgColor,
    required CareLog? lastLog,
    required VoidCallback onAdd,
  }) {
    final String statusText = lastLog == null
        ? 'No logs yet'
        : title == 'Weight' 
            ? '${selectedCatWeight() ?? "4.2"} kg ↗'
            : 'Last ${title == 'Litter' ? 'cleaned' : title == 'Water' ? 'refilled' : 'fed'}: ${_getTimeAgo(lastLog.timestamp)}';

    return PastelCard(
      backgroundColor: bgColor.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.playfulText),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.playfulText, letterSpacing: 1.1)),
                const SizedBox(height: 4),
                Text(statusText, style: TextStyle(color: AppColors.playfulText.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.playfulText, size: 28),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context, WidgetRef ref, CareLog? lastLog) {
    final moods = [
      {'val': 'very_happy', 'icon': Icons.sentiment_very_satisfied_outlined},
      {'val': 'happy', 'icon': Icons.sentiment_satisfied_outlined},
      {'val': 'neutral', 'icon': Icons.sentiment_neutral_outlined},
      {'val': 'sad', 'icon': Icons.sentiment_dissatisfied_outlined},
      {'val': 'angry', 'icon': Icons.sentiment_very_dissatisfied_outlined},
    ];
    
    return PastelCard(
      backgroundColor: AppColors.playfulTertiary.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.playfulTertiary.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mood_outlined, size: 32, color: AppColors.playfulText),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Text('Mood', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.playfulText, letterSpacing: 1.1)),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.add_rounded, color: AppColors.playfulText, size: 28),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: moods.map((m) {
              final isSelected = lastLog?.value == m['val'];
              return GestureDetector(
                onTap: () => _addLog(ref, 'mood', m['val'] as String),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: AppColors.playfulText, width: 2) : Border.all(color: Colors.transparent, width: 2),
                  ),
                  child: Icon(m['icon'] as IconData, size: 36, color: isSelected ? AppColors.playfulPrimary : AppColors.playfulText.withOpacity(0.6)),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  // Dummy weight for UI
  String? selectedCatWeight() {
    return "4.2";
  }
}
