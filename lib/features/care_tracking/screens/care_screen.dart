import 'dart:io';
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
                                image: cat.photoPath != null && cat.photoPath!.isNotEmpty
                                    ? DecorationImage(image: FileImage(File(cat.photoPath!)), fit: BoxFit.cover)
                                    : const DecorationImage(image: AssetImage('assets/images/cat_avatar.png'), fit: BoxFit.cover),
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
                ref: ref,
                title: 'Food',
                emoji: '🥣',
                bgColor: AppColors.playfulPrimary,
                lastLog: _getLastLog(logs, 'food'),
                allLogs: _getAllLogs(logs, 'food'),
                statusText: _getFoodStatus(logs),
                onAdd: () => _addLog(ref, 'food', 'Fed'),
              ),
              const SizedBox(height: 16),
              _buildCareCard(
                context: context,
                ref: ref,
                title: 'Water',
                emoji: '💧',
                bgColor: AppColors.playfulAccentBlue,
                lastLog: _getLastLog(logs, 'water'),
                allLogs: _getAllLogs(logs, 'water'),
                statusText: _getWaterStatus(logs),
                onAdd: () => _addLog(ref, 'water', 'Refilled'),
              ),
              const SizedBox(height: 16),
              _buildCareCard(
                context: context,
                ref: ref,
                title: 'Litter',
                emoji: '🚽',
                bgColor: AppColors.playfulSecondary,
                lastLog: _getLastLog(logs, 'litter'),
                allLogs: _getAllLogs(logs, 'litter'),
                statusText: _getLitterStatus(logs),
                onAdd: () => _addLog(ref, 'litter', 'Cleaned'),
              ),
              const SizedBox(height: 16),
              _buildMoodCard(context, ref, _getLastLog(logs, 'mood')),
              const SizedBox(height: 16),
              _buildWeightCard(context, ref, selectedCat, _getAllLogs(logs, 'weight')),
              const SizedBox(height: 100), // padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  CareLog? _getLastLog(List<CareLog> logs, String type) {
    try {
      final filtered = logs.where((l) => l.type == type).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return filtered.isNotEmpty ? filtered.first : null;
    } catch (_) {
      return null;
    }
  }

  List<CareLog> _getAllLogs(List<CareLog> logs, String type) {
    return logs.where((l) => l.type == type).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  String _getFoodStatus(List<CareLog> logs) {
    final last = _getLastLog(logs, 'food');
    if (last == null) return 'No meals yet';
    return 'Last fed: ${_getTimeAgo(last.timestamp)}';
  }

  String _getWaterStatus(List<CareLog> logs) {
    final last = _getLastLog(logs, 'water');
    if (last == null) return 'Not refilled yet';
    return 'Last refilled: ${_getTimeAgo(last.timestamp)}';
  }

  String _getLitterStatus(List<CareLog> logs) {
    final last = _getLastLog(logs, 'litter');
    if (last == null) return 'Not cleaned today';
    return 'Last cleaned: ${_getTimeAgo(last.timestamp)}';
  }

  void _addLog(WidgetRef ref, String type, String value) {
    ref.read(careLogListProvider.notifier).addLog(type: type, value: value);
  }

  void _showCareHistory(BuildContext context, String title, String emoji, List<CareLog> allLogs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.playfulBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.playfulText.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('$emoji $title History', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.playfulText)),
            const SizedBox(height: 16),
            if (allLogs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No $title logs yet', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.playfulText.withOpacity(0.4))),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allLogs.length > 20 ? 20 : allLogs.length,
                  itemBuilder: (ctx, index) {
                    final log = allLogs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log.value ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.playfulText)),
                                Text(
                                  DateFormat('MMM d, yyyy • h:mm a').format(log.timestamp),
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.playfulText.withOpacity(0.6)),
                                ),
                              ],
                            ),
                          ),
                          Text(_getTimeAgo(log.timestamp), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.playfulText.withOpacity(0.4))),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareCard({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String emoji,
    required Color bgColor,
    required CareLog? lastLog,
    required List<CareLog> allLogs,
    required String statusText,
    required VoidCallback onAdd,
  }) {
    return GestureDetector(
      onTap: () => _showCareHistory(context, title, emoji, allLogs),
      child: PastelCard(
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
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
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
      ),
    );
  }

  Widget _buildWeightCard(BuildContext context, WidgetRef ref, dynamic selectedCat, List<CareLog> weightLogs) {
    final currentWeight = selectedCat?.weight?.toString() ?? '--';

    return GestureDetector(
      onTap: () => _showCareHistory(context, 'Weight', '⚖️', weightLogs),
      child: PastelCard(
        backgroundColor: AppColors.playfulAccentPeach.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.playfulAccentPeach.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Text('⚖️', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weight', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.playfulText, letterSpacing: 1.1)),
                  const SizedBox(height: 4),
                  Text('$currentWeight kg', style: TextStyle(color: AppColors.playfulText.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showWeightDialog(context, ref, selectedCat),
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
      ),
    );
  }

  void _showWeightDialog(BuildContext context, WidgetRef ref, dynamic selectedCat) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.playfulBackground,
        title: const Text('Update Weight ⚖️', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.playfulText)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.playfulText),
          decoration: InputDecoration(
            hintText: selectedCat?.weight?.toString() ?? '0.0',
            suffixText: 'kg',
            suffixStyle: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.playfulText),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.playfulText)),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(controller.text);
              if (weight != null && selectedCat != null) {
                selectedCat.weight = weight;
                ref.read(catListProvider.notifier).updateCat(selectedCat);
                ref.read(careLogListProvider.notifier).addLog(type: 'weight', value: '${weight}kg');
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.playfulPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context, WidgetRef ref, CareLog? lastLog) {
    final moods = [
      {'val': 'very_happy', 'emoji': '😻'},
      {'val': 'happy', 'emoji': '😺'},
      {'val': 'neutral', 'emoji': '😐'},
      {'val': 'sad', 'emoji': '😿'},
      {'val': 'angry', 'emoji': '🙀'},
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
                child: const Text('😸', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Text('Mood', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.playfulText, letterSpacing: 1.1)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: moods.map((m) {
              final isSelected = lastLog?.value == m['val'];
              return GestureDetector(
                onTap: () => _addLog(ref, 'mood', m['val'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: AppColors.playfulTertiary, width: 3) : Border.all(color: Colors.transparent, width: 3),
                    boxShadow: isSelected ? [BoxShadow(color: AppColors.playfulTertiary.withOpacity(0.3), blurRadius: 8)] : [],
                  ),
                  child: Text(m['emoji'] as String, style: const TextStyle(fontSize: 32)),
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
}
