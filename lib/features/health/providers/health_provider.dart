import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/models/vaccine.dart';
import '../../../shared/models/appointment.dart';
import '../../../shared/models/medication.dart';

// --- Boxes ---
final vaccineBoxProvider = Provider<Box<Vaccine>>((ref) => throw UnimplementedError());
final appointmentBoxProvider = Provider<Box<Appointment>>((ref) => throw UnimplementedError());
final medicationBoxProvider = Provider<Box<Medication>>((ref) => throw UnimplementedError());

// --- Lists ---
final vaccineListProvider = NotifierProvider<VaccineListNotifier, List<Vaccine>>(VaccineListNotifier.new);
final appointmentListProvider = NotifierProvider<AppointmentListNotifier, List<Appointment>>(AppointmentListNotifier.new);
final medicationListProvider = NotifierProvider<MedicationListNotifier, List<Medication>>(MedicationListNotifier.new);

// --- Notifiers ---
class VaccineListNotifier extends Notifier<List<Vaccine>> {
  late Box<Vaccine> _box;
  final _uuid = const Uuid();

  @override
  List<Vaccine> build() {
    _box = ref.watch(vaccineBoxProvider);
    return _box.values.toList();
  }

  void addVaccine({
    required String catId,
    required String name,
    required DateTime dateAdministered,
    DateTime? nextDueDate,
    String? notes,
  }) {
    final v = Vaccine(
      id: _uuid.v4(),
      catId: catId,
      name: name,
      dateAdministered: dateAdministered,
      nextDueDate: nextDueDate,
      notes: notes,
    );
    _box.put(v.id, v);
    state = _box.values.toList();
  }

  void deleteVaccine(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  void updateVaccine(String id, {
    required String name,
    required DateTime dateAdministered,
    DateTime? nextDueDate,
    String? notes,
  }) {
    final v = _box.get(id);
    if (v != null) {
      final updated = Vaccine(
        id: id,
        catId: v.catId,
        name: name,
        dateAdministered: dateAdministered,
        nextDueDate: nextDueDate,
        notes: notes,
      );
      _box.put(id, updated);
      state = _box.values.toList();
    }
  }
}

class AppointmentListNotifier extends Notifier<List<Appointment>> {
  late Box<Appointment> _box;
  final _uuid = const Uuid();

  @override
  List<Appointment> build() {
    _box = ref.watch(appointmentBoxProvider);
    return _box.values.toList();
  }

  void addAppointment({
    required String catId,
    required String title,
    required DateTime date,
    String? clinicName,
    String? notes,
  }) {
    final a = Appointment(
      id: _uuid.v4(),
      catId: catId,
      title: title,
      date: date,
      clinicName: clinicName,
      notes: notes,
    );
    _box.put(a.id, a);
    state = _box.values.toList();
  }

  void deleteAppointment(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  void updateAppointment(String id, {
    required String title,
    required DateTime date,
    String? clinicName,
    String? notes,
  }) {
    final a = _box.get(id);
    if (a != null) {
      final updated = Appointment(
        id: id,
        catId: a.catId,
        title: title,
        date: date,
        clinicName: clinicName,
        notes: notes,
      );
      _box.put(id, updated);
      state = _box.values.toList();
    }
  }
}

class MedicationListNotifier extends Notifier<List<Medication>> {
  late Box<Medication> _box;
  final _uuid = const Uuid();

  @override
  List<Medication> build() {
    _box = ref.watch(medicationBoxProvider);
    return _box.values.toList();
  }

  void addMedication({
    required String catId,
    required String name,
    required String dosage,
    required DateTime startDate,
    DateTime? endDate,
    String? frequency,
    String? notes,
  }) {
    final m = Medication(
      id: _uuid.v4(),
      catId: catId,
      name: name,
      dosage: dosage,
      startDate: startDate,
      endDate: endDate,
      frequency: frequency,
      notes: notes,
    );
    _box.put(m.id, m);
    state = _box.values.toList();
  }

  void deleteMedication(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  void updateMedication(String id, {
    required String name,
    required String dosage,
    required DateTime startDate,
    DateTime? endDate,
    String? frequency,
    String? notes,
  }) {
    final m = _box.get(id);
    if (m != null) {
      final updated = Medication(
        id: id,
        catId: m.catId,
        name: name,
        dosage: dosage,
        startDate: startDate,
        endDate: endDate,
        frequency: frequency,
        notes: notes,
      );
      _box.put(id, updated);
      state = _box.values.toList();
    }
  }
}
