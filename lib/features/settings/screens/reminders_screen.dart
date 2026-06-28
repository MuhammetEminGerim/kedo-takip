import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/providers/cat_provider.dart';
import '../../../shared/models/reminder.dart';
import '../providers/reminder_provider.dart';
import '../../../core/theme/app_theme.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(reminderListProvider);
    ref.watch(catListProvider);
    ref.watch(selectedCatProvider);

    // Group reminders by type
    final mealReminders = reminders.where((r) => r.type == 'meal').toList();
    final medReminders = reminders.where((r) => r.type == 'medication').toList();
    final aptReminders = reminders.where((r) => r.type == 'appointment').toList();
    final isModern = ref.watch(themeProvider) == AppThemeType.modern;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isModern ? AppStrings.get('reminders').toUpperCase() : '${AppStrings.get('reminders')} ', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: isModern ? 1.5 : 0, fontSize: isModern ? 20 : 24)),
            if (!isModern) const Text('🔔', style: TextStyle(fontSize: 24)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: !isModern,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test Notification Button
            _buildTestNotificationButton(),
            const SizedBox(height: 24),

            // Meal Reminders Section
            _buildSectionHeader('🍽️', AppStrings.get('meal_reminder'), AppStrings.get('meal_reminder_desc')),
            const SizedBox(height: 12),
            ...mealReminders.map((r) => _buildReminderCard(r)),
            _buildAddButton(() => _showAddReminderDialog('meal')),
            const SizedBox(height: 24),

            // Medication Reminders Section
            _buildSectionHeader('💊', AppStrings.get('medication_reminder'), AppStrings.get('medication_reminder_desc')),
            const SizedBox(height: 12),
            ...medReminders.map((r) => _buildReminderCard(r)),
            _buildAddButton(() => _showAddReminderDialog('medication')),
            const SizedBox(height: 24),

            // Appointment Reminders Section
            _buildSectionHeader('📅', AppStrings.get('appointment_reminder'), AppStrings.get('appointment_reminder_desc')),
            const SizedBox(height: 12),
            ...aptReminders.map((r) => _buildReminderCard(r)),
            _buildAddButton(() => _showAddReminderDialog('appointment')),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    return GestureDetector(
      onTap: () async {
        await NotificationService.instance.showTestNotification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.get('test_notification_sent', fallback: '🔔 Test notification sent!'), style: const TextStyle(fontWeight: FontWeight.w900)),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(AppStrings.get('test_notification'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String emoji, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
              Text(subtitle, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final timeStr = '${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}';
    final isModern = ref.watch(themeProvider) == AppThemeType.modern;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showAddReminderDialog(reminder.type, existing: reminder),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isModern ? (isDark ? const Color(0xFF1E293B) : Colors.white) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isModern ? Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1.5) : null,
          boxShadow: isModern ? [] : [
            BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: reminder.isEnabled ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                timeStr,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: reminder.isEnabled ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title & Cat
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: reminder.isEnabled ? Theme.of(context).colorScheme.onSurface : Colors.grey,
                    ),
                  ),
                  Text(
                    reminder.catName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: reminder.isEnabled ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Toggle
            Switch(
              value: reminder.isEnabled,
              onChanged: (_) => ref.read(reminderListProvider.notifier).toggleReminder(reminder.id),
              activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
              thumbColor: WidgetStatePropertyAll(reminder.isEnabled ? Theme.of(context).colorScheme.primary : Colors.grey),
            ),
            // Delete
            GestureDetector(
              onTap: () => _confirmDeleteReminder(reminder),
              child: Icon(Icons.delete_outline_rounded, color: Colors.red.withValues(alpha: 0.5), size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(VoidCallback onTap) {
    final isModern = ref.watch(themeProvider) == AppThemeType.modern;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isModern ? Colors.transparent : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isModern ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), width: isModern ? 1.5 : 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: isModern ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)) : Theme.of(context).colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(AppStrings.get('add_reminder'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isModern ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)) : Theme.of(context).colorScheme.primary)),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(AppStrings.get('delete_reminder'), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
        content: Text('${reminder.title} - ${AppStrings.get('delete_confirm')}', style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.get('cancel'), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(reminderListProvider.notifier).deleteReminder(reminder.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.get('reminder_deleted'), style: const TextStyle(fontWeight: FontWeight.w900)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(AppStrings.get('delete_reminder'), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(String type, {Reminder? existing}) {
    final cats = ref.read(catListProvider);
    final selectedCat = ref.read(selectedCatProvider);

    if (cats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('add_cat_first'), style: const TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    String titleValue = '';
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
    DateTime? selectedDate = type == 'appointment' ? DateTime.now() : null;
    String chosenCatId = existing?.catId ?? (selectedCat?.id ?? cats.first.id);
    String chosenCatName = existing?.catName ?? (selectedCat?.name ?? cats.first.name);

    if (existing != null) {
      titleValue = existing.title;
      selectedTime = TimeOfDay(hour: existing.hour, minute: existing.minute);
      if (existing.specificDate != null) selectedDate = existing.specificDate;
    } else {
      // Set default title based on type
      switch (type) {
        case 'meal':
          titleValue = AppStrings.locale == 'tr' ? 'Mama zamanı' : 'Meal time';
          break;
        case 'medication':
          titleValue = AppStrings.locale == 'tr' ? 'İlaç zamanı' : 'Medication time';
          break;
        case 'appointment':
          titleValue = AppStrings.locale == 'tr' ? 'Veteriner randevusu' : 'Vet appointment';
          break;
      }
    }

    final titleController = TextEditingController(text: titleValue);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Row(
            children: [
              Text(
                type == 'meal' ? '🍽️' : type == 'medication' ? '💊' : '📅',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(existing != null ? AppStrings.get('edit', fallback: 'Düzenle') : AppStrings.get('add_reminder'), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cat Selector
                if (cats.length > 1) ...[
                  Text(AppStrings.get('cat_profile', fallback: 'Cat').split(' ').first, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: chosenCatId,
                        isExpanded: true,
                        items: cats.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w800)))).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            chosenCatId = val!;
                            chosenCatName = cats.firstWhere((c) => c.id == val).name;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Title
                Text(AppStrings.get('reminder_title'), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: AppStrings.get('reminder_title_hint'),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
                
                if (type == 'appointment') ...[
                  Text('Tarih', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate != null ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}' : '',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
                          ),
                          Icon(Icons.calendar_today_rounded, color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Time Picker
                Text(AppStrings.get('reminder_time'), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Theme.of(context).colorScheme.primary,
                              onPrimary: Colors.white,
                              surface: Theme.of(context).scaffoldBackgroundColor,
                              onSurface: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setDialogState(() => selectedTime = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        Icon(Icons.access_time_rounded, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.get('cancel'), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;

                if (existing != null) {
                  ref.read(reminderListProvider.notifier).updateReminderDetails(
                    existing.id,
                    catId: chosenCatId,
                    catName: chosenCatName,
                    title: title,
                    hour: selectedTime.hour,
                    minute: selectedTime.minute,
                    specificDate: selectedDate,
                  );
                } else {
                  ref.read(reminderListProvider.notifier).addReminder(
                    catId: chosenCatId,
                    catName: chosenCatName,
                    type: type,
                    title: title,
                    hour: selectedTime.hour,
                    minute: selectedTime.minute,
                    specificDate: selectedDate,
                  );
                }

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(existing != null ? AppStrings.get('saved', fallback: 'Kaydedildi') : AppStrings.get('reminder_added'), style: const TextStyle(fontWeight: FontWeight.w900)),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(AppStrings.get('save', fallback: 'Kaydet'), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
