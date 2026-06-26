import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/cat.dart';

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
    final box = ref.read(catBoxProvider);
    await cat.delete();
    state = box.values.toList();
  }
}
