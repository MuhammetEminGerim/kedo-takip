import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/providers/cat_provider.dart';
import '../../../shared/widgets/pastel_card.dart';
import '../providers/health_provider.dart';
import '../widgets/add_health_record_dialogs.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCat = ref.watch(selectedCatProvider);
    
    if (selectedCat == null || selectedCat.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Text(AppStrings.get('no_cat_selected'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.get('health_title'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 4,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Nunito', fontSize: 14),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          tabs: [
            Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text(AppStrings.get('tab_vaccines')))),
            Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text(AppStrings.get('tab_appointments')))),
            Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text(AppStrings.get('tab_medications')))),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _VaccinesTab(catId: selectedCat.id),
          _AppointmentsTab(catId: selectedCat.id),
          _MedicationsTab(catId: selectedCat.id),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100), // Avoid bottom nav
        child: FloatingActionButton(
          onPressed: () {
            if (_tabController.index == 0) {
              _showAddVaccineDialog(context, ref, selectedCat.id);
            } else if (_tabController.index == 1) {
              _showAddAppointmentDialog(context, ref, selectedCat.id);
            } else {
              _showAddMedicationDialog(context, ref, selectedCat.id);
            }
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  void _showAddVaccineDialog(BuildContext context, WidgetRef ref, String catId) {
    showAddVaccineDialog(context, ref, catId);
  }

  void _showAddAppointmentDialog(BuildContext context, WidgetRef ref, String catId) {
    showAddAppointmentDialog(context, ref, catId);
  }

  void _showAddMedicationDialog(BuildContext context, WidgetRef ref, String catId) {
    showAddMedicationDialog(context, ref, catId);
  }
}

class _VaccinesTab extends ConsumerWidget {
  final String catId;
  const _VaccinesTab({required this.catId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccines = ref.watch(vaccineListProvider).where((v) => v.catId == catId).toList();
    vaccines.sort((a, b) => b.dateAdministered.compareTo(a.dateAdministered));

    if (vaccines.isEmpty) {
      return Center(
        child: Text(AppStrings.get('no_vaccines'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 120),
      itemCount: vaccines.length,
      itemBuilder: (context, index) {
        final v = vaccines[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PastelCard(
            child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3), shape: BoxShape.circle),
              child: Icon(Icons.vaccines, color: Theme.of(context).colorScheme.secondaryContainer),
            ),
            title: Text(v.name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${AppStrings.get('date_administered')}: ${DateFormat.yMMMd().format(v.dateAdministered)}'),
                if (v.nextDueDate != null)
                  Text('${AppStrings.get('next_due_date')}: ${DateFormat.yMMMd().format(v.nextDueDate!)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => ref.read(vaccineListProvider.notifier).deleteVaccine(v.id),
            ),
            ),
          ),
        );
      },
    );
  }
}

class _AppointmentsTab extends ConsumerWidget {
  final String catId;
  const _AppointmentsTab({required this.catId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appts = ref.watch(appointmentListProvider).where((a) => a.catId == catId).toList();
    appts.sort((a, b) => a.date.compareTo(b.date));

    if (appts.isEmpty) {
      return Center(
        child: Text(AppStrings.get('no_appointments'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 120),
      itemCount: appts.length,
      itemBuilder: (context, index) {
        final a = appts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PastelCard(
            child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), shape: BoxShape.circle),
              child: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(a.title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMM d, yyyy - HH:mm').format(a.date)),
                if (a.clinicName != null && a.clinicName!.isNotEmpty)
                  Text(a.clinicName!),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => ref.read(appointmentListProvider.notifier).deleteAppointment(a.id),
            ),
            ),
          ),
        );
      },
    );
  }
}

class _MedicationsTab extends ConsumerWidget {
  final String catId;
  const _MedicationsTab({required this.catId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(medicationListProvider).where((m) => m.catId == catId).toList();
    meds.sort((a, b) => b.startDate.compareTo(a.startDate));

    if (meds.isEmpty) {
      return Center(
        child: Text(AppStrings.get('no_medications'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 120),
      itemCount: meds.length,
      itemBuilder: (context, index) {
        final m = meds[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PastelCard(
            child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3), shape: BoxShape.circle),
              child: Icon(Icons.medication, color: Theme.of(context).colorScheme.secondary),
            ),
            title: Text(m.name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${AppStrings.get('dosage')}: ${m.dosage}'),
                if (m.frequency != null && m.frequency!.isNotEmpty)
                  Text('${AppStrings.get('frequency')}: ${m.frequency!}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => ref.read(medicationListProvider.notifier).deleteMedication(m.id),
            ),
            ),
          ),
        );
      },
    );
  }
}
