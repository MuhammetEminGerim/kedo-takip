import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

import '../providers/audio_record_provider.dart';
import '../providers/meow_record_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pastel_card.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  String? _selectedContext;

  final List<Map<String, dynamic>> _contexts = [
    {'text': 'Before meal', 'icon': Icons.restaurant_outlined, 'color': AppColors.playfulPrimary},
    {'text': 'After play', 'icon': Icons.videogame_asset_outlined, 'color': AppColors.playfulSecondary},
    {'text': 'Night time', 'icon': Icons.nightlight_outlined, 'color': AppColors.playfulTertiary},
    {'text': 'At door', 'icon': Icons.door_front_door_outlined, 'color': AppColors.playfulAccentPeach},
    {'text': 'Alone', 'icon': Icons.pets_outlined, 'color': AppColors.playfulAccentBlue},
    {'text': 'Other', 'icon': Icons.edit_note_outlined, 'color': Colors.grey.shade300},
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _currentlyPlayingId = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordState = ref.watch(audioRecordProvider);
    final isRecording = recordState.state == RecordState.recording;
    final hasRecorded = recordState.lastRecordedPath != null && !isRecording;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Record Meow ', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulPrimary)),
            const Icon(Icons.mic_none_outlined, color: AppColors.playfulPrimary, size: 28),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: _buildRecordArea(context, recordState, isRecording, hasRecorded),
            ),
            if (hasRecorded) _buildSaveArea(context, recordState),
            if (!hasRecorded) _buildTagsArea(),
            Expanded(
              flex: 2,
              child: _buildRecentRecords(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordArea(BuildContext context, AudioRecordState state, bool isRecording, bool hasRecorded) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Inner Ring
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.playfulPrimary.withOpacity(0.3), width: 8),
                  ),
                ),
                // Outer Ring
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.playfulPrimary.withOpacity(0.15), width: 4),
                  ),
                ),
                // Paw prints
                const Positioned(top: 20, left: 40, child: Icon(Icons.pets, size: 28, color: AppColors.playfulPrimary)),
                const Positioned(top: 20, right: 40, child: Icon(Icons.pets, size: 28, color: AppColors.playfulPrimary)),
                const Positioned(bottom: 20, left: 40, child: Icon(Icons.pets, size: 28, color: AppColors.playfulPrimary)),
                const Positioned(bottom: 20, right: 40, child: Icon(Icons.pets, size: 28, color: AppColors.playfulPrimary)),

                // The Button
                GestureDetector(
                  onTap: () {
                    if (isRecording) {
                      ref.read(audioRecordProvider.notifier).stopRecording();
                    } else if (!hasRecorded) {
                      ref.read(audioRecordProvider.notifier).startRecording();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isRecording ? 160 : 140,
                    height: isRecording ? 160 : 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasRecorded ? Colors.grey.shade300 : AppColors.playfulPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: (hasRecorded ? Colors.grey.shade400 : AppColors.playfulPrimary).withOpacity(0.4),
                          blurRadius: isRecording ? 30 : 15,
                          spreadRadius: isRecording ? 10 : 0,
                        )
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Icon(
                          isRecording ? Icons.stop_rounded : (hasRecorded ? Icons.check_rounded : Icons.mic_none_outlined),
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              _formatDuration(state.recordDuration),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.playfulPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: _contexts.map((ctx) {
          final isSelected = _selectedContext == ctx['text'];
          final color = ctx['color'] as Color;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedContext = isSelected ? null : ctx['text'] as String;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 1.0 : 0.6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(ctx['icon'] as IconData, size: 20, color: isSelected ? Colors.white : AppColors.playfulText),
                  const SizedBox(width: 8),
                  Text(
                    ctx['text'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : AppColors.playfulText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSaveArea(BuildContext context, AudioRecordState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTagsArea(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    ref.read(audioRecordProvider.notifier).reset();
                    setState(() {
                      _selectedContext = null;
                    });
                  },
                  child: const Text('Discard', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 16)),
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.playfulPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _selectedContext == null
                      ? null
                      : () async {
                          await ref.read(meowRecordListProvider.notifier).addRecord(
                                filePath: state.lastRecordedPath!,
                                durationSeconds: state.recordDuration,
                                contextTag: _selectedContext!,
                              );
                          ref.read(audioRecordProvider.notifier).reset();
                          setState(() {
                            _selectedContext = null;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved! 🐾')));
                          }
                        },
                  child: const Text('Save Record', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRecentRecords() {
    final records = ref.watch(meowRecordListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text('Recent recordings', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.playfulText)),
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text('No meows recorded yet.', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.playfulText.withOpacity(0.6))),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: records.length,
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 100.0), // Padding for floating nav bar
              itemBuilder: (context, index) {
                final record = records[index];
                final isPlaying = _currentlyPlayingId == record.id;
                
                // Find color for context
                Color chipColor = AppColors.playfulPrimary;
                for (var ctx in _contexts) {
                  if (ctx['text'] == record.contextTag) {
                    chipColor = ctx['color'] as Color;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: PastelCard(
                    backgroundColor: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fake audio waveform
                              Row(
                                children: List.generate(15, (i) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    width: 4,
                                    height: (i % 3 == 0) ? 20 : ((i % 2 == 0) ? 10 : 30),
                                    decoration: BoxDecoration(
                                      color: chipColor.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(DateFormat('h:mm a').format(record.timestamp), style: TextStyle(color: AppColors.playfulText.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: chipColor.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(record.contextTag, style: TextStyle(color: AppColors.playfulText, fontWeight: FontWeight.w900, fontSize: 11)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(_formatDuration(record.durationSeconds), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.playfulText)),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () async {
                            if (isPlaying) {
                              await _audioPlayer.stop();
                              setState(() => _currentlyPlayingId = null);
                            } else {
                              await _audioPlayer.play(DeviceFileSource(record.filePath));
                              setState(() => _currentlyPlayingId = record.id);
                            }
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.playfulSecondary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 30),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
