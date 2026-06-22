import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../shared/models/meow_record.dart';
import '../../../shared/providers/cat_provider.dart';

final meowRecordBoxProvider = Provider<Box<MeowRecord>>((ref) {
  throw UnimplementedError('meowRecordBox not initialized');
});

final meowRecordListProvider = NotifierProvider<MeowRecordListNotifier, List<MeowRecord>>(MeowRecordListNotifier.new);

class MeowRecordListNotifier extends Notifier<List<MeowRecord>> {
  @override
  List<MeowRecord> build() {
    final box = ref.watch(meowRecordBoxProvider);
    final selectedCat = ref.watch(selectedCatProvider);
    if (selectedCat == null) return [];
    
    // Sadece seçili kedinin kayıtlarını döndür ve yeninden eskiye sırala
    final records = box.values.where((r) => r.catId == selectedCat.id).toList();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  Future<void> addRecord({
    required String filePath,
    required int durationSeconds,
    required String contextTag,
  }) async {
    final selectedCat = ref.read(selectedCatProvider);
    if (selectedCat == null) return;

    final box = ref.read(meowRecordBoxProvider);
    final record = MeowRecord(
      id: const Uuid().v4(),
      catId: selectedCat.id,
      filePath: filePath,
      durationSeconds: durationSeconds,
      timestamp: DateTime.now(),
      contextTag: contextTag,
    );

    await box.put(record.id, record);
    ref.invalidateSelf(); // Listeyi güncelle
  }

  Future<void> deleteRecord(MeowRecord record) async {
    // Ses dosyasını cihazdan da sil
    final file = File(record.filePath);
    if (await file.exists()) {
      await file.delete();
    }
    
    final box = ref.read(meowRecordBoxProvider);
    await box.delete(record.id);
    ref.invalidateSelf();
  }
}
