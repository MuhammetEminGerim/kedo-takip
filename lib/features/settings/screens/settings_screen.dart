import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isModern = themeMode == AppThemeType.modern;
    final isTurkish = ref.watch(localeProvider) == 'tr';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.get('settings').toUpperCase(), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: isModern ? 1.5 : 0, fontSize: 20)),
            if (!isModern) const Text(' ⚙️', style: TextStyle(fontSize: 20)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme Toggle
            Text(AppStrings.get('appearance'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            _buildSectionCard(
              isModern: isModern,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('🎨', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(AppStrings.get('theme'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
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
                        isSelected: ref.watch(themeProvider) == AppThemeType.playful,
                        onTap: () => ref.read(themeProvider.notifier).setTheme(AppThemeType.playful),
                        isModern: isModern,
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOption(
                        context,
                        title: AppStrings.get('modern'),
                        icon: '✨',
                        isSelected: ref.watch(themeProvider) == AppThemeType.modern,
                        onTap: () => ref.read(themeProvider.notifier).setTheme(AppThemeType.modern),
                        isModern: isModern,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('🌗', style: TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 16),
                          Text(AppStrings.get('mode', fallback: 'Mod'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                      _buildModeToggle(context, ref),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notifications / Reminders
            Text(AppStrings.get('notifications'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.push('/reminders'),
              child: _buildSectionCard(
                isModern: isModern,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('🔔', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.get('reminders'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                          const SizedBox(height: 2),
                          Text(AppStrings.get('no_reminders_desc'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(AppStrings.get('language'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            _buildSectionCard(
              isModern: isModern,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('🌐', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(AppStrings.get('language'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildLanguageOption(
                        context,
                        title: 'Türkçe',
                        icon: '🇹🇷',
                        isSelected: isTurkish,
                        onTap: () => ref.read(localeProvider.notifier).setLocale('tr'),
                        isModern: isModern,
                      ),
                      const SizedBox(width: 12),
                      _buildLanguageOption(
                        context,
                        title: 'English',
                        icon: '🇬🇧',
                        isSelected: !isTurkish,
                        onTap: () => ref.read(localeProvider.notifier).setLocale('en'),
                        isModern: isModern,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About
            Text(AppStrings.get('about'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            _buildSectionCard(
              isModern: isModern,
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(child: Text('🐾', style: TextStyle(fontSize: 40))),
                  ),
                  const SizedBox(height: 16),
                  Text(AppStrings.get('app_name'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text(AppStrings.get('version_number'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(AppStrings.get('made_with_love'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
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

  Widget _buildModeToggle(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        ref.read(themeModeProvider.notifier).setMode(isDark ? ThemeMode.light : ThemeMode.dark);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1), width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: isDark ? 30 : 0,
              right: isDark ? 0 : 30,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Center(
                  child: Text(isDark ? '🌙' : '☀️', style: const TextStyle(fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child, required bool isModern}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isModern
        ? (isDark ? const Color(0xFF1E293B) : Colors.white)
        : (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(isModern ? 24 : 32),
      ),
      child: child,
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isModern,
  }) {
    if (isModern) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? (isDark ? Colors.white : const Color(0xFF1E293B)) : (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.transparent, width: 2),
            ),
            child: Column(
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isSelected ? (isDark ? const Color(0xFF1E293B) : Colors.white) : (isDark ? Colors.white : const Color(0xFF1E293B)))),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), width: 2),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface)),
              ),
            ],
          ),
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
    required bool isModern,
  }) {
    if (isModern) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? (isDark ? Colors.white : const Color(0xFF1E293B)) : (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.transparent, width: 2),
            ),
            child: Column(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isSelected ? (isDark ? const Color(0xFF1E293B) : Colors.white) : (isDark ? Colors.white : const Color(0xFF1E293B)))),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), width: 2),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
