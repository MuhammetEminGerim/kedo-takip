import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../providers/health_provider.dart';
import '../../../shared/models/vaccine.dart';
import '../../../shared/models/appointment.dart';
import '../../../shared/models/medication.dart';

void showAddVaccineDialog(BuildContext context, WidgetRef ref, String catId, {Vaccine? existing}) {
  final nameCtrl = TextEditingController(text: existing?.name);
  DateTime dateAdmin = existing?.dateAdministered ?? DateTime.now();
  DateTime? nextDate = existing?.nextDueDate;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24, left: 24, right: 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(existing != null ? AppStrings.get('edit', fallback: 'Düzenle') : AppStrings.get('add_vaccine'), style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('vaccine_name'),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.get('date_administered')),
                  subtitle: Text(DateFormat.yMMMd().format(dateAdmin)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(context: ctx, initialDate: dateAdmin, firstDate: DateTime(2000), lastDate: DateTime.now());
                    if (d != null) setState(() => dateAdmin = d);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.get('next_due_date')),
                  subtitle: Text(nextDate == null ? '-' : DateFormat.yMMMd().format(nextDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(context: ctx, initialDate: nextDate ?? DateTime.now().add(const Duration(days: 365)), firstDate: DateTime.now(), lastDate: DateTime(2030));
                    if (d != null) setState(() => nextDate = d);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(AppStrings.get('save'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    if (existing != null) {
                      ref.read(vaccineListProvider.notifier).updateVaccine(
                        existing.id,
                        name: nameCtrl.text.trim(),
                        dateAdministered: dateAdmin,
                        nextDueDate: nextDate,
                      );
                    } else {
                      ref.read(vaccineListProvider.notifier).addVaccine(
                        catId: catId,
                        name: nameCtrl.text.trim(),
                        dateAdministered: dateAdmin,
                        nextDueDate: nextDate,
                      );
                    }
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            ),
          );
        },
      );
    },
  );
}

void showAddAppointmentDialog(BuildContext context, WidgetRef ref, String catId, {Appointment? existing}) {
  final titleCtrl = TextEditingController(text: existing?.title);
  final clinicCtrl = TextEditingController(text: existing?.clinicName);
  DateTime date = existing?.date ?? DateTime.now().add(const Duration(days: 1));

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24, left: 24, right: 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Text(existing != null ? AppStrings.get('edit', fallback: 'Düzenle') : AppStrings.get('add_appointment'), style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('appointment_title'),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: clinicCtrl,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('clinic_name'),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.get('appointment_date')),
                  subtitle: Text(DateFormat('MMM d, yyyy - HH:mm').format(date)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime(2030));
                    if (d != null) {
                      if (!ctx.mounted) return;
                      final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(date));
                      if (t != null) {
                        setState(() => date = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                      }
                    }
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(AppStrings.get('save'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    if (existing != null) {
                      ref.read(appointmentListProvider.notifier).updateAppointment(
                        existing.id,
                        title: titleCtrl.text.trim(),
                        clinicName: clinicCtrl.text.trim(),
                        date: date,
                      );
                    } else {
                      ref.read(appointmentListProvider.notifier).addAppointment(
                        catId: catId,
                        title: titleCtrl.text.trim(),
                        clinicName: clinicCtrl.text.trim(),
                        date: date,
                      );
                    }
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            ),
          );
        },
      );
    },
  );
}

void showAddMedicationDialog(BuildContext context, WidgetRef ref, String catId, {Medication? existing}) {
  final nameCtrl = TextEditingController(text: existing?.name);
  final dosageCtrl = TextEditingController(text: existing?.dosage);
  final freqCtrl = TextEditingController(text: existing?.frequency);
  DateTime startDate = existing?.startDate ?? DateTime.now();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24, left: 24, right: 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Text(existing != null ? AppStrings.get('edit', fallback: 'Düzenle') : AppStrings.get('add_medication'), style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('medication_name'),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dosageCtrl,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('dosage'),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: freqCtrl,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('frequency'),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.get('start_date')),
                  subtitle: Text(DateFormat.yMMMd().format(startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(context: ctx, initialDate: startDate, firstDate: DateTime(2000), lastDate: DateTime(2030));
                    if (d != null) setState(() => startDate = d);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(AppStrings.get('save'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty || dosageCtrl.text.trim().isEmpty) return;
                    if (existing != null) {
                      ref.read(medicationListProvider.notifier).updateMedication(
                        existing.id,
                        name: nameCtrl.text.trim(),
                        dosage: dosageCtrl.text.trim(),
                        frequency: freqCtrl.text.trim(),
                        startDate: startDate,
                      );
                    } else {
                      ref.read(medicationListProvider.notifier).addMedication(
                        catId: catId,
                        name: nameCtrl.text.trim(),
                        dosage: dosageCtrl.text.trim(),
                        frequency: freqCtrl.text.trim(),
                        startDate: startDate,
                      );
                    }
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            ),
          );
        },
      );
    },
  );
}
