import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/providers/cat_provider.dart';
import '../../../shared/widgets/pastel_card.dart';
import '../providers/health_provider.dart';
import '../widgets/add_health_record_dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';

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
    final isModern = ref.watch(themeProvider) == AppThemeType.modern;
    
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
        centerTitle: !isModern,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: isModern ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Text(
              isModern ? AppStrings.get('health_title').toUpperCase() : AppStrings.get('health_title'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: isModern ? FontWeight.w900 : FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: isModern ? 20 : null,
                letterSpacing: isModern ? 1.5 : 0,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: isModern 
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
                  unselectedLabelColor: const Color(0xFF64748B),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Inter', fontSize: 12, letterSpacing: 0.5),
                  tabs: [
                    Tab(child: Text(AppStrings.get('tab_vaccines').toUpperCase(), overflow: TextOverflow.ellipsis)),
                    Tab(child: Text(AppStrings.get('tab_appointments').toUpperCase(), overflow: TextOverflow.ellipsis)),
                    Tab(child: Text(AppStrings.get('tab_medications').toUpperCase(), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              )
            : TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorWeight: 4,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800, 
                  fontFamily: 'Nunito', 
                  fontSize: 14,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                tabs: [
                  Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text(AppStrings.get('tab_vaccines')))),
                  Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text(AppStrings.get('tab_appointments')))),
                  Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text(AppStrings.get('tab_medications')))),
                ],
              ),
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
          backgroundColor: isModern ? const Color(0xFF1E293B) : Theme.of(context).colorScheme.primary,
          child: AppIcons.add(color: Colors.white, size: 32),
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
    final isModern = ref.watch(themeProvider) == AppThemeType.modern;
    vaccines.sort((a, b) => b.dateAdministered.compareTo(a.dateAdministered));

    if (vaccines.isEmpty) {
      return Center(
        child: Text(AppStrings.get('no_vaccines'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
      );
    }

    if (isModern) {
      return _buildModernHealthTimeline(context, vaccines, 'vaccine', catId, ref);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 120),
      itemCount: vaccines.length,
      itemBuilder: (context, index) {
        final v = vaccines[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PastelCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              onTap: () => showAddVaccineDialog(context, ref, catId, existing: v),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: AppIcons.vaccine(color: Theme.of(context).colorScheme.secondaryContainer),
              ),
              title: Text(v.name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('${AppStrings.get('date_administered')}: ${DateFormat.yMMMd().format(v.dateAdministered)}'),
                  if (v.nextDueDate != null)
                    Text('${AppStrings.get('next_due_date')}: ${DateFormat.yMMMd().format(v.nextDueDate!)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                ],
              ),
              trailing: IconButton(
                icon: AppIcons.delete(color: Colors.red),
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
    final isModern = ref.watch(themeProvider) == AppThemeType.modern;
    appts.sort((a, b) => a.date.compareTo(b.date));

    if (appts.isEmpty) {
      return Center(
        child: Text(AppStrings.get('no_appointments'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
      );
    }

    if (isModern) {
      return _buildModernHealthTimeline(context, appts, 'appointment', catId, ref);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 120),
      itemCount: appts.length,
      itemBuilder: (context, index) {
        final a = appts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PastelCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              onTap: () => showAddAppointmentDialog(context, ref, catId, existing: a),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: AppIcons.calendar(color: Theme.of(context).colorScheme.primary),
              ),
              title: Text(a.title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(DateFormat('MMM d, yyyy - HH:mm').format(a.date)),
                  if (a.clinicName != null && a.clinicName!.isNotEmpty)
                    Text(a.clinicName!),
                ],
              ),
              trailing: IconButton(
                icon: AppIcons.delete(color: Colors.red),
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
    final isModern = ref.watch(themeProvider) == AppThemeType.modern;
    meds.sort((a, b) => b.startDate.compareTo(a.startDate));

    if (meds.isEmpty) {
      return Center(
        child: Text(AppStrings.get('no_medications'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
      );
    }

    if (isModern) {
      return _buildModernHealthTimeline(context, meds, 'medication', catId, ref);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 120),
      itemCount: meds.length,
      itemBuilder: (context, index) {
        final m = meds[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PastelCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              onTap: () => showAddMedicationDialog(context, ref, catId, existing: m),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: AppIcons.medication(color: Theme.of(context).colorScheme.secondary),
              ),
              title: Text(m.name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('${AppStrings.get('dosage')}: ${m.dosage}'),
                  if (m.frequency != null && m.frequency!.isNotEmpty)
                    Text('${AppStrings.get('frequency')}: ${m.frequency!}'),
                ],
              ),
              trailing: IconButton(
                icon: AppIcons.delete(color: Colors.red),
                onPressed: () => ref.read(medicationListProvider.notifier).deleteMedication(m.id),
              ),
            ),
          ),
        );
      },
    );
  }
}

  Widget _buildModernHealthTimeline(BuildContext context, List<dynamic> items, String type, String catId, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isLast = index == items.length - 1;

        Widget iconWidget;
        String title;
        String dateStr;
        String? subtitle;
        VoidCallback onDelete;
        VoidCallback onTap;

        if (type == 'vaccine') {
          iconWidget = Icon(Icons.vaccines_outlined, color: textColor, size: 24);
          title = item.name;
          dateStr = DateFormat.yMMMd().format(item.dateAdministered);
          subtitle = item.nextDueDate != null ? '${AppStrings.get('next_due_date')}: ${DateFormat.yMMMd().format(item.nextDueDate!)}' : null;
          onDelete = () => ref.read(vaccineListProvider.notifier).deleteVaccine(item.id);
          onTap = () => showAddVaccineDialog(context, ref, catId, existing: item);
        } else if (type == 'appointment') {
          iconWidget = Icon(Icons.calendar_month_outlined, color: textColor, size: 24);
          title = item.title;
          dateStr = DateFormat('MMM d, yyyy - HH:mm').format(item.date);
          subtitle = item.clinicName;
          onDelete = () => ref.read(appointmentListProvider.notifier).deleteAppointment(item.id);
          onTap = () => showAddAppointmentDialog(context, ref, catId, existing: item);
        } else {
          iconWidget = Icon(Icons.medication_outlined, color: textColor, size: 24);
          title = item.name;
          dateStr = '${AppStrings.get('dosage')}: ${item.dosage}';
          subtitle = item.frequency;
          onDelete = () => ref.read(medicationListProvider.notifier).deleteMedication(item.id);
          onTap = () => showAddMedicationDialog(context, ref, catId, existing: item);
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          iconWidget,
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor, letterSpacing: 0.5)),
                                const SizedBox(height: 4),
                                Text(dateStr, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                                if (subtitle != null && subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(subtitle, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                                ]
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: onDelete,
                            child: Icon(Icons.delete_outline, color: textColor.withValues(alpha: 0.3), size: 20),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
