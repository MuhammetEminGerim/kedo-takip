import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/meow_record_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pastel_card.dart';
import '../../../core/constants/app_strings.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> with SingleTickerProviderStateMixin {
  String? _selectedContext;
  int? _selectedIntensity;
  late AnimationController _pulseController;

  List<Map<String, dynamic>> get _contexts => [
    {'text': AppStrings.get('before_meal'), 'icon': Icons.restaurant_outlined, 'emoji': '🍽️', 'color': AppColors.playfulPrimary},
    {'text': AppStrings.get('after_play'), 'icon': Icons.videogame_asset_outlined, 'emoji': '🎮', 'color': AppColors.playfulSecondary},
    {'text': AppStrings.get('night_time'), 'icon': Icons.nightlight_outlined, 'emoji': '🌙', 'color': AppColors.playfulTertiary},
    {'text': AppStrings.get('at_door'), 'icon': Icons.door_front_door_outlined, 'emoji': '🚪', 'color': AppColors.playfulAccentPeach},
    {'text': AppStrings.get('alone'), 'icon': Icons.pets_outlined, 'emoji': '🐱', 'color': AppColors.playfulAccentBlue},
    {'text': AppStrings.get('other'), 'icon': Icons.edit_note_outlined, 'emoji': '📝', 'color': Colors.grey.shade400},
  ];

  final List<Map<String, dynamic>> _intensities = [
    {'emoji': '😺', 'label': 'Hafif', 'value': 1},
    {'emoji': '😸', 'label': 'Normal', 'value': 2},
    {'emoji': '😻', 'label': 'Yoğun', 'value': 3},
    {'emoji': '🙀', 'label': 'Çok Yoğun', 'value': 4},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${AppStrings.get('record_meow')} ', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulPrimary)),
            const Text('🐾', style: TextStyle(fontSize: 24)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            // Big Meow Button
            _buildMeowButton(),
            const SizedBox(height: 24),

            // Context selector
            Text(AppStrings.get('context'), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.playfulText)),
            const SizedBox(height: 12),
            _buildContextGrid(),
            const SizedBox(height: 24),

            // Intensity selector
            Text(AppStrings.get('intensity'), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.playfulText)),
            const SizedBox(height: 12),
            _buildIntensityRow(),
            const SizedBox(height: 32),

            // Recent logs
            Text(AppStrings.get('recent_recordings'), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.playfulText)),
            const SizedBox(height: 12),
            _buildRecentLogs(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMeowButton() {
    return Center(
      child: GestureDetector(
        onTap: _logMeow,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.05);
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.playfulPrimary, AppColors.playfulSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.playfulPrimary.withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: 4,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🐱', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 4),
                Text(
                  AppStrings.get('meow_button'),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContextGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _contexts.map((ctx) {
        final isSelected = _selectedContext == ctx['text'];
        final color = ctx['color'] as Color;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedContext = isSelected ? null : ctx['text'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(ctx['emoji'] as String, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  ctx['text'] as String,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: isSelected ? Colors.white : AppColors.playfulText,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIntensityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _intensities.map((item) {
        final isSelected = _selectedIntensity == item['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIntensity = isSelected ? null : item['value'] as int;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.playfulPrimary.withOpacity(0.2) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.playfulPrimary : Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(item['emoji'] as String, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 2),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    color: isSelected ? AppColors.playfulPrimary : AppColors.playfulText.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentLogs() {
    final records = ref.watch(meowRecordListProvider);
    
    if (records.isEmpty) {
      return PastelCard(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const Text('😿', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('no_recordings_yet'),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  color: AppColors.playfulText.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: records.take(10).map((record) {
        // Find context color
        Color chipColor = AppColors.playfulPrimary;
        String emoji = '🐱';
        for (var ctx in _contexts) {
          if (ctx['text'] == record.contextTag) {
            chipColor = ctx['color'] as Color;
            emoji = ctx['emoji'] as String;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: Key(record.id),
            direction: DismissDirection.endToStart,
            background: Container(
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
            ),
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  backgroundColor: AppColors.playfulBackground,
                  title: Text(AppStrings.get('delete_recording'), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.playfulText)),
                  content: Text(AppStrings.get('delete_recording_confirm'), style: const TextStyle(fontWeight: FontWeight.w700)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: Text(AppStrings.get('cancel'), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.playfulText))),
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
              ref.read(meowRecordListProvider.notifier).deleteRecord(record);
            },
            child: PastelCard(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: chipColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.contextTag,
                          style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.playfulText),
                        ),
                        Text(
                          DateFormat('d MMM, HH:mm').format(record.timestamp),
                          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.playfulText.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                  if (record.durationSeconds > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: chipColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _intensityEmoji(record.durationSeconds),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _intensityEmoji(int val) {
    if (val <= 1) return '😺';
    if (val == 2) return '😸';
    if (val == 3) return '😻';
    return '🙀';
  }

  void _logMeow() {
    final context = _selectedContext ?? AppStrings.get('other');
    final intensity = _selectedIntensity ?? 2;
    
    ref.read(meowRecordListProvider.notifier).addRecord(
      filePath: '',
      durationSeconds: intensity,
      contextTag: context,
    );

    // Quick feedback animation
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🐱 ', style: TextStyle(fontSize: 20)),
            Text(
              '${AppStrings.get('meow_logged')}!',
              style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900),
            ),
          ],
        ),
        backgroundColor: AppColors.playfulPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
