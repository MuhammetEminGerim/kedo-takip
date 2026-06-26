import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/pastel_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isTurkish = ref.watch(localeProvider) == 'tr';

    return Scaffold(
      backgroundColor: AppColors.playfulBackground,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${AppStrings.get('settings')} ', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulText)),
            const Text('⚙️', style: TextStyle(fontSize: 24)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.playfulText),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme Toggle
            Text(AppStrings.get('appearance'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.playfulText)),
            const SizedBox(height: 12),
            PastelCard(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.playfulTertiary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('🎨', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(AppStrings.get('theme'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.playfulText)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildThemeOption(
                        context,
                        title: AppStrings.get('playful'),
                        icon: '🐱',
                        isSelected: themeMode == AppThemeType.playful,
                        onTap: () => ref.read(themeProvider.notifier).setTheme(AppThemeType.playful),
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOption(
                        context,
                        title: AppStrings.get('modern'),
                        icon: '✨',
                        isSelected: themeMode == AppThemeType.modern,
                        onTap: () => ref.read(themeProvider.notifier).setTheme(AppThemeType.modern),
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOption(
                        context,
                        title: AppStrings.get('dark_mode'),
                        icon: '🌙',
                        isSelected: themeMode == AppThemeType.dark,
                        onTap: () => ref.read(themeProvider.notifier).setTheme(AppThemeType.dark),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notifications / Reminders
            Text(AppStrings.get('notifications'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.playfulText)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.push('/reminders'),
              child: PastelCard(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.playfulPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('🔔', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.get('reminders'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.playfulText)),
                          const SizedBox(height: 2),
                          Text(AppStrings.get('no_reminders_desc'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.playfulText.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.playfulTextLight, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(AppStrings.get('language'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.playfulText)),
            const SizedBox(height: 12),
            PastelCard(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.playfulSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('🌐', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(AppStrings.get('language'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.playfulText)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref.read(localeProvider.notifier).setLocale('tr');
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isTurkish ? AppColors.playfulPrimary : AppColors.playfulSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isTurkish ? AppColors.playfulPrimary : AppColors.playfulText.withOpacity(0.1), width: 2),
                            ),
                            child: Column(
                              children: [
                                const Text('🇹🇷', style: TextStyle(fontSize: 28)),
                                const SizedBox(height: 4),
                                Text('Türkçe', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: isTurkish ? Colors.white : AppColors.playfulText)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref.read(localeProvider.notifier).setLocale('en');
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: !isTurkish ? AppColors.playfulPrimary : AppColors.playfulSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: !isTurkish ? AppColors.playfulPrimary : AppColors.playfulText.withOpacity(0.1), width: 2),
                            ),
                            child: Column(
                              children: [
                                const Text('🇬🇧', style: TextStyle(fontSize: 28)),
                                const SizedBox(height: 4),
                                Text('English', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: !isTurkish ? Colors.white : AppColors.playfulText)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About
            Text(AppStrings.get('about'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.playfulText)),
            const SizedBox(height: 12),
            PastelCard(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.playfulPrimary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(child: Text('🐾', style: TextStyle(fontSize: 40))),
                  ),
                  const SizedBox(height: 16),
                  Text(AppStrings.get('app_name'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.playfulText)),
                  const SizedBox(height: 4),
                  Text(AppStrings.get('version_number'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.playfulText.withOpacity(0.6))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.playfulPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(AppStrings.get('made_with_love'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.playfulText)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.playfulPrimary : AppColors.playfulSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.playfulPrimary : AppColors.playfulText.withOpacity(0.1), width: 2),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: isSelected ? Colors.white : AppColors.playfulText)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
