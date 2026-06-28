import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/cat.dart';
import '../../features/care_tracking/providers/care_log_provider.dart';
import '../../features/health/providers/health_provider.dart';
import '../../features/stamps/providers/stamp_provider.dart';
import '../../features/settings/providers/reminder_provider.dart';
final catBoxProvider = Provider<Box<Cat>>((ref) {
  throw UnimplementedError('catBox is not initialized');
});

final catListProvider = NotifierProvider<CatListNotifier, List<Cat>>(CatListNotifier.new);

final selectedCatProvider = NotifierProvider<SelectedCatNotifier, Cat?>(SelectedCatNotifier.new);

class SelectedCatNotifier extends Notifier<Cat?> {
  @override
  Cat? build() {
    final cats = ref.read(catListProvider);
    
    ref.listen<List<Cat>>(catListProvider, (previous, next) {
      final currentCat = state;
      if (currentCat == null) {
        if (next.isNotEmpty) state = next.first;
      } else {
        // Check if the current cat still exists
        final exists = next.any((c) => c.id == currentCat.id);
        if (!exists) {
          state = next.isNotEmpty ? next.first : null;
        } else {
          // Update the selected cat with the new data from the list (in case it was updated)
          state = next.firstWhere((c) => c.id == currentCat.id);
        }
      }
    });

    return cats.isNotEmpty ? cats.first : null;
  }
  
  void setCat(Cat? cat) {
    state = cat;
  }
}

class CatListNotifier extends Notifier<List<Cat>> {
  @override
  List<Cat> build() {
    final box = ref.watch(catBoxProvider);
    return box.values.toList();
  }

  Future<void> addCat({
    required String name,
    required String breed,
    required DateTime birthDate,
    required String gender,
    bool isNeutered = false,
    double? weight,
    String? photoPath,
  }) async {
    final cat = Cat(
      id: const Uuid().v4(),
      name: name,
      breed: breed,
      birthDate: birthDate,
      gender: gender,
      isNeutered: isNeutered,
      weight: weight,
      photoPath: photoPath,
    );
    final box = ref.read(catBoxProvider);
    await box.put(cat.id, cat);
    state = box.values.toList();
  }

  Future<void> updateCat(Cat cat) async {
    final box = ref.read(catBoxProvider);
    await cat.save();
    state = box.values.toList();
  }

  Future<void> deleteCat(Cat cat) async {
    // Cascading delete
    final careLogBox = ref.read(careLogBoxProvider);
    final careLogsToDelete = careLogBox.values.where((e) => e.catId == cat.id).map((e) => e.id).toList();
    await careLogBox.deleteAll(careLogsToDelete);

    final vaccineBox = ref.read(vaccineBoxProvider);
    final vaccinesToDelete = vaccineBox.values.where((e) => e.catId == cat.id).map((e) => e.id).toList();
    await vaccineBox.deleteAll(vaccinesToDelete);

    final appointmentBox = ref.read(appointmentBoxProvider);
    final appointmentsToDelete = appointmentBox.values.where((e) => e.catId == cat.id).map((e) => e.id).toList();
    await appointmentBox.deleteAll(appointmentsToDelete);

    final medicationBox = ref.read(medicationBoxProvider);
    final medicationsToDelete = medicationBox.values.where((e) => e.catId == cat.id).map((e) => e.id).toList();
    await medicationBox.deleteAll(medicationsToDelete);

    final stampBox = ref.read(stampBoxProvider);
    final stampsToDelete = stampBox.values.where((e) => e.catId == cat.id).map((e) => e.id).toList();
    for (var id in stampsToDelete) {
      await ref.read(stampsProvider.notifier).deleteStamp(id);
    }

    final reminderBox = ref.read(reminderBoxProvider);
    final remindersToDelete = reminderBox.values.where((e) => e.catId == cat.id).map((e) => e.id).toList();
    for (var id in remindersToDelete) {
      await ref.read(reminderListProvider.notifier).deleteReminder(id);
    }

    final box = ref.read(catBoxProvider);
    await box.delete(cat.id);
    state = box.values.toList();
  }
}
