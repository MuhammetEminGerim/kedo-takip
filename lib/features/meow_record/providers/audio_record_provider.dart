import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

enum RecordState { idle, recording, paused }

class AudioRecordState {
  final RecordState state;
  final int recordDuration;
  final String? lastRecordedPath;

  AudioRecordState({
    this.state = RecordState.idle,
    this.recordDuration = 0,
    this.lastRecordedPath,
  });

  AudioRecordState copyWith({
    RecordState? state,
    int? recordDuration,
    String? lastRecordedPath,
  }) {
    return AudioRecordState(
      state: state ?? this.state,
      recordDuration: recordDuration ?? this.recordDuration,
      lastRecordedPath: lastRecordedPath ?? this.lastRecordedPath,
    );
  }
}

final audioRecordProvider = NotifierProvider<AudioRecordNotifier, AudioRecordState>(AudioRecordNotifier.new);

class AudioRecordNotifier extends Notifier<AudioRecordState> {
  late final AudioRecorder _audioRecorder;
  Timer? _timer;
  
  @override
  AudioRecordState build() {
    _audioRecorder = AudioRecorder();
    ref.onDispose(() {
      _timer?.cancel();
      _audioRecorder.dispose();
    });
    return AudioRecordState();
  }

  Future<void> startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/meow_${const Uuid().v4()}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
          path: filePath,
        );

        state = state.copyWith(state: RecordState.recording, recordDuration: 0);
        _startTimer();
      }
    } catch (e) {
      print('Error starting record: \$e');
    }
  }

  Future<void> stopRecording() async {
    try {
      _timer?.cancel();
      final path = await _audioRecorder.stop();
      state = state.copyWith(
        state: RecordState.idle,
        lastRecordedPath: path,
      );
    } catch (e) {
      print('Error stopping record: \$e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      state = state.copyWith(recordDuration: state.recordDuration + 1);
    });
  }
  
  void reset() {
    state = AudioRecordState();
  }
}
