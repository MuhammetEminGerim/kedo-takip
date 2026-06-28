import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/care_log_provider.dart';
import '../../../shared/providers/cat_provider.dart';
import '../../../shared/models/care_log.dart';
import '../../../shared/widgets/pastel_card.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';

class CareScreen extends ConsumerWidget {
  const CareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(careLogListProvider);
    final cats = ref.watch(catListProvider);
    final selectedCat = ref.watch(selectedCatProvider);
    final isModern = ref.watch(themeProvider) == AppThemeType.modern;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Row(
              mainAxisAlignment: isModern ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Text(
                  isModern ? AppStrings.get('care_log').toUpperCase() : '${AppStrings.get('care_log')} ', 
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: isModern ? FontWeight.w900 : FontWeight.w900, 
                    color: Theme.of(context).colorScheme.onSurface, 
                    fontSize: isModern ? 20 : 26,
                    letterSpacing: isModern ? 1.5 : 0,
                  )
                ),
                if (!isModern) AppIcons.paw(color: Theme.of(context).colorScheme.onSurface, size: 24),
              ],
            ),
            if (!isModern) const SizedBox(height: 4),
            if (!isModern) Text(DateFormat("EEEE, d MMMM").format(DateTime.now()), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        toolbarHeight: isModern ? 60 : 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: !isModern,
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
                height: isModern ? 80 : 100,
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
                              width: isModern ? 56 : 70,
                              height: isModern ? 56 : 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).cardColor,
                                border: isSelected 
                                    ? Border.all(color: isModern ? const Color(0xFF1E293B) : Theme.of(context).colorScheme.primary, width: isModern ? 2 : 4) 
                                    : Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), width: isModern ? 1 : 2),
                                image: cat.photoPath != null && cat.photoPath!.isNotEmpty
                                    ? DecorationImage(image: ResizeImage(FileImage(File(cat.photoPath!)), width: 150), fit: BoxFit.cover)
                                    : const DecorationImage(image: AssetImage('assets/images/cat_avatar.png'), fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.name,
                              style: isModern 
                                ? TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                                  )
                                : TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
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

              if (isModern) ...[
                _buildModernDashboard(context, ref, logs, selectedCat),
              ] else ...[
                _buildCareCard(
                  context: context, ref: ref,
                  title: AppStrings.get('food'),
                  iconWidget: AppIcons.bowl(size: 40),
                  bgColor: Theme.of(context).colorScheme.primary,
                  lastLog: _getLastLog(logs, 'food'),
                  allLogs: _getAllLogs(logs, 'food'),
                  statusText: _getFoodStatus(logs),
                  onAdd: () => _addLog(ref, 'food', AppStrings.get('fed')),
                  historyKey: 'food',
                ),
                const SizedBox(height: 16),
                _buildCareCard(
                  context: context, ref: ref,
                  title: AppStrings.get('water'),
                  iconWidget: AppIcons.water(size: 40),
                  bgColor: Theme.of(context).colorScheme.secondaryContainer,
                  lastLog: _getLastLog(logs, 'water'),
                  allLogs: _getAllLogs(logs, 'water'),
                  statusText: _getWaterStatus(logs),
                  onAdd: () => _addLog(ref, 'water', AppStrings.get('refilled')),
                  historyKey: 'water',
                ),
                const SizedBox(height: 16),
                _buildCareCard(
                  context: context, ref: ref,
                  title: AppStrings.get('litter'),
                  iconWidget: AppIcons.litter(size: 40),
                  bgColor: Theme.of(context).colorScheme.secondary,
                  lastLog: _getLastLog(logs, 'litter'),
                  allLogs: _getAllLogs(logs, 'litter'),
                  statusText: _getLitterStatus(logs),
                  onAdd: () => _addLog(ref, 'litter', AppStrings.get('cleaned')),
                  historyKey: 'litter',
                ),
                const SizedBox(height: 16),
                _buildWeightCard(context, ref, selectedCat, _getAllLogs(logs, 'weight')),
              ],
              
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
    if (last == null) return AppStrings.get('no_meals_yet');
    return '${AppStrings.get('last_fed')} ${_getTimeAgo(last.timestamp)}';
  }

  String _getWaterStatus(List<CareLog> logs) {
    final last = _getLastLog(logs, 'water');
    if (last == null) return AppStrings.get('not_refilled_yet');
    return '${AppStrings.get('last_refilled')} ${_getTimeAgo(last.timestamp)}';
  }

  String _getLitterStatus(List<CareLog> logs) {
    final last = _getLastLog(logs, 'litter');
    if (last == null) return AppStrings.get('not_cleaned_today');
    return '${AppStrings.get('last_cleaned')} ${_getTimeAgo(last.timestamp)}';
  }

  void _addLog(WidgetRef ref, String type, String value) {
    ref.read(careLogListProvider.notifier).addLog(type: type, value: value);
  }

  void _showCareHistory(BuildContext context, WidgetRef ref, String historyKey, Widget iconWidget, List<CareLog> allLogs) {
    final historyTitle = AppStrings.get('${historyKey}_history');
    final noLogsText = AppStrings.get('no_${historyKey}_logs_yet');

    final displayLogs = allLogs.take(30).toList();
    final groupedLogs = <DateTime, List<CareLog>>{};
    for (var log in displayLogs) {
      final date = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      groupedLogs.putIfAbsent(date, () => []).add(log);
    }
    final sortedDates = groupedLogs.keys.toList()..sort((a, b) => b.compareTo(a));
    final listItems = <dynamic>[];
    for (var date in sortedDates) {
      listItems.add(date);
      listItems.addAll(groupedLogs[date]!);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 32, height: 32, child: iconWidget),
                const SizedBox(width: 8),
                Text(historyTitle, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 16),
            if (allLogs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(noLogsText, style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: listItems.length,
                  itemBuilder: (ctx, index) {
                    final item = listItems[index];
                    
                    if (item is DateTime) {
                      final now = DateTime.now();
                      String dateStr;
                      if (item.year == now.year && item.month == now.month && item.day == now.day) {
                        dateStr = AppStrings.get('today') == 'today' ? 'Bugün' : AppStrings.get('today');
                      } else if (item.year == now.year && item.month == now.month && item.day == now.day - 1) {
                        dateStr = AppStrings.get('yesterday') == 'yesterday' ? 'Dün' : AppStrings.get('yesterday');
                      } else {
                        dateStr = DateFormat('MMM d, yyyy').format(item);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
                        child: Text(dateStr, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                      );
                    }

                    final log = item as CareLog;
                    return Dismissible(
                      key: Key(log.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        child: AppIcons.delete(color: Colors.white, size: 24),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                            title: Text(AppStrings.get('delete_log'), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
                            content: Text(AppStrings.get('cannot_be_undone'), style: const TextStyle(fontWeight: FontWeight.w700)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: Text(AppStrings.get('cancel'), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface))),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(c, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                child: Text(AppStrings.get('delete'), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                              ),
                            ],
                          ),
                        ) ?? false;
                      },
                      onDismissed: (_) {
                        ref.read(careLogListProvider.notifier).deleteLog(log);
                        // Trigger hot reload implicitly or notify state
                        // Actually provider handles state update.
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 32, height: 32, child: iconWidget),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(log.value ?? '', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                                  Text(
                                    DateFormat('h:mm a').format(log.timestamp),
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                                  ),
                                ],
                              ),
                            ),
                            Text(_getTimeAgo(log.timestamp), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
                          ],
                        ),
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
    required Widget iconWidget,
    required Color bgColor,
    required CareLog? lastLog,
    required List<CareLog> allLogs,
    required String statusText,
    required VoidCallback onAdd,
    required String historyKey,
  }) {
    return GestureDetector(
      onTap: () => _showCareHistory(context, ref, historyKey, iconWidget, allLogs),
      child: PastelCard(
        backgroundColor: bgColor.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 36, height: 36, child: iconWidget),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.1)),
                  const SizedBox(height: 4),
                  Text(statusText, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w800)),
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
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: AppIcons.add(color: Theme.of(context).colorScheme.onSurface, size: 28),
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
      onTap: () => _showCareHistory(context, ref, 'weight', AppIcons.paw(size: 32), weightLogs),
      child: PastelCard(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 36, height: 36, child: AppIcons.paw(size: 36)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.get('weight'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.1)),
                  const SizedBox(height: 4),
                  Text('$currentWeight ${AppStrings.get('kg')}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w800)),
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
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: AppIcons.add(color: Theme.of(context).colorScheme.onSurface, size: 28),
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(AppStrings.get('update_weight'), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: selectedCat?.weight?.toString() ?? '0.0',
            suffixText: AppStrings.get('kg'),
            suffixStyle: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.get('cancel'), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(controller.text);
              if (weight != null && selectedCat != null) {
                selectedCat.weight = weight;
                ref.read(catListProvider.notifier).updateCat(selectedCat);
                ref.read(careLogListProvider.notifier).addLog(type: 'weight', value: '$weight${AppStrings.get('kg')}');
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(AppStrings.get('save'), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }



  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}${AppStrings.get('d_ago')}';
    if (diff.inHours > 0) return '${diff.inHours}${AppStrings.get('h_ago')}';
    if (diff.inMinutes > 0) return '${diff.inMinutes}${AppStrings.get('m_ago')}';
    return AppStrings.get('just_now');
  }

  Widget _buildModernDashboard(BuildContext context, WidgetRef ref, List<CareLog> logs, dynamic selectedCat) {
    final foodLogs = _getAllLogs(logs, 'food');
    final waterLogs = _getAllLogs(logs, 'water');
    final litterLogs = _getAllLogs(logs, 'litter');
    final weightLogs = _getAllLogs(logs, 'weight');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildBentoCard(
              context: context,
              title: AppStrings.locale == 'tr' ? 'Mama' : 'Food',
              iconWidget: Icon(Icons.restaurant_outlined, color: Theme.of(context).colorScheme.onSurface, size: 24),
              iconColor: Theme.of(context).colorScheme.onSurface,
              statusText: _getFoodStatus(logs),
              onAdd: () => _addLog(ref, 'food', AppStrings.get('fed')),
              onTap: () => _showCareHistory(context, ref, 'food', Icon(Icons.restaurant_outlined, color: Theme.of(context).colorScheme.onSurface, size: 24), foodLogs),
            ),
            const SizedBox(width: 16),
            _buildBentoCard(
              context: context,
              title: AppStrings.locale == 'tr' ? 'Su' : 'Water',
              iconWidget: Icon(Icons.water_drop_outlined, color: Theme.of(context).colorScheme.onSurface, size: 24),
              iconColor: Theme.of(context).colorScheme.onSurface,
              statusText: _getWaterStatus(logs),
              onAdd: () => _addLog(ref, 'water', AppStrings.get('refilled')),
              onTap: () => _showCareHistory(context, ref, 'water', Icon(Icons.water_drop_outlined, color: Theme.of(context).colorScheme.onSurface, size: 24), waterLogs),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildBentoCard(
              context: context,
              title: AppStrings.locale == 'tr' ? 'Kum' : 'Litter',
              iconWidget: Icon(Icons.cleaning_services_outlined, color: Theme.of(context).colorScheme.onSurface, size: 24),
              iconColor: Theme.of(context).colorScheme.onSurface,
              statusText: _getLitterStatus(logs),
              onAdd: () => _addLog(ref, 'litter', AppStrings.get('cleaned')),
              onTap: () => _showCareHistory(context, ref, 'litter', Icon(Icons.cleaning_services_outlined, color: Theme.of(context).colorScheme.onSurface, size: 24), litterLogs),
            ),
            const SizedBox(width: 16),
            _buildBentoCard(
              context: context,
              title: AppStrings.locale == 'tr' ? 'Kilo' : 'Weight',
              iconWidget: Icon(Icons.monitor_weight_outlined, color: Theme.of(context).colorScheme.onSurface, size: 24),
              iconColor: Theme.of(context).colorScheme.onSurface,
              statusText: '${selectedCat?.weight?.toString() ?? '--'} ${AppStrings.get('kg')}',
              onAdd: () => _showWeightDialog(context, ref, selectedCat),
              onTap: () => _showCareHistory(context, ref, 'weight', Icon(Icons.monitor_weight_outlined, color: Theme.of(context).colorScheme.onSurface, size: 24), weightLogs),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildModernTimeline(context, ref, logs),
      ],
    );
  }

  Widget _buildBentoCard({
    required BuildContext context,
    required String title,
    required Widget iconWidget,
    required String statusText,
    required VoidCallback onAdd,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: isDark ? Border.all(color: const Color(0xFF334155), width: 1.5) : Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: iconWidget,
                  ),
                  GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: AppIcons.add(color: textColor, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textColor, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(statusText, style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTimeline(BuildContext context, WidgetRef ref, List<CareLog> logs) {
    final now = DateTime.now();
    final todayLogs = logs.where((l) => l.timestamp.year == now.year && l.timestamp.month == now.month && l.timestamp.day == now.day).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    if (todayLogs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.get('today'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textColor)),
        const SizedBox(height: 16),
        ...todayLogs.map((log) {
          Widget iconWidget;
          Color color;
          final iconColor = Theme.of(context).colorScheme.onSurface;
          switch (log.type) {
            case 'food': iconWidget = Icon(Icons.restaurant_outlined, color: iconColor, size: 20); color = iconColor; break;
            case 'water': iconWidget = Icon(Icons.water_drop_outlined, color: iconColor, size: 20); color = iconColor; break;
            case 'litter': iconWidget = Icon(Icons.cleaning_services_outlined, color: iconColor, size: 20); color = iconColor; break;
            case 'weight': iconWidget = Icon(Icons.monitor_weight_outlined, color: iconColor, size: 20); color = iconColor; break;
            default: iconWidget = Icon(Icons.check, color: iconColor, size: 20); color = iconColor;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: iconWidget,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.value ?? '', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textColor)),
                      Text(DateFormat('HH:mm').format(log.timestamp), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
