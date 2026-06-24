import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../shared/models/stamp.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

final stampBoxProvider = Provider<Box<Stamp>>((ref) {
  throw UnimplementedError();
});

final stampsProvider = NotifierProvider<StampNotifier, List<Stamp>>(StampNotifier.new);

class StampNotifier extends Notifier<List<Stamp>> {
  late Box<Stamp> _box;

  @override
  List<Stamp> build() {
    _box = ref.watch(stampBoxProvider);
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addStamp(String catId, String originalImagePath, String caption, {DateTime? date}) async {
    // Convert and compress to WebP
    final dir = await getApplicationDocumentsDirectory();
    final uuid = const Uuid().v4();
    final targetPath = '${dir.path}/stamp_$uuid.webp';

    final result = await FlutterImageCompress.compressAndGetFile(
      originalImagePath,
      targetPath,
      format: CompressFormat.webp,
      quality: 80,
    );

    if (result != null) {
      final stamp = Stamp(
        id: uuid,
        catId: catId,
        imagePath: result.path,
        caption: caption,
        date: date ?? DateTime.now(),
      );

      await _box.put(stamp.id, stamp);
      state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    }
  }

  Future<void> deleteStamp(String id) async {
    final stamp = _box.get(id);
    if (stamp != null) {
      final file = File(stamp.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
      await _box.delete(id);
      state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    }
  }

  List<Stamp> getStampsForCat(String catId) {
    return state.where((s) => s.catId == catId).toList();
  }
}
