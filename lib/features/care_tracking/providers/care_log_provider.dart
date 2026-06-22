import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/models/care_log.dart';
import '../../../shared/providers/cat_provider.dart';

final careLogBoxProvider = Provider<Box<CareLog>>((ref) {
  throw UnimplementedError('careLogBox not initialized');
});

final careLogListProvider = NotifierProvider<CareLogListNotifier, List<CareLog>>(CareLogListNotifier.new);

class CareLogListNotifier extends Notifier<List<CareLog>> {
  @override
  List<CareLog> build() {
    final box = ref.watch(careLogBoxProvider);
    final selectedCat = ref.watch(selectedCatProvider);
    if (selectedCat == null) return [];
    
    final logs = box.values.where((r) => r.catId == selectedCat.id).toList();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  Future<void> addLog({
    required String type,
    String? value,
  }) async {
    final selectedCat = ref.read(selectedCatProvider);
    if (selectedCat == null) return;

    final box = ref.read(careLogBoxProvider);
    final log = CareLog(
      id: const Uuid().v4(),
      catId: selectedCat.id,
      type: type,
      timestamp: DateTime.now(),
      value: value,
    );

    await box.put(log.id, log);
    ref.invalidateSelf();
  }

  Future<void> deleteLog(CareLog log) async {
    final box = ref.read(careLogBoxProvider);
    await box.delete(log.id);
    ref.invalidateSelf();
  }
}
