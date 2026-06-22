import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/pastel_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isPlayful = themeMode == 'playful';

    return Scaffold(
      backgroundColor: AppColors.playfulBackground,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Settings ', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.playfulText)),
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
            const Text('Appearance', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.playfulText)),
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
                      const Expanded(
                        child: Text('Theme', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.playfulText)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!isPlayful) ref.read(themeProvider.notifier).toggleTheme();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isPlayful ? AppColors.playfulPrimary : AppColors.playfulSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isPlayful ? AppColors.playfulPrimary : AppColors.playfulText.withOpacity(0.1), width: 2),
                            ),
                            child: Column(
                              children: [
                                const Text('🐱', style: TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
                                Text('Playful', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: isPlayful ? Colors.white : AppColors.playfulText)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (isPlayful) ref.read(themeProvider.notifier).toggleTheme();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: !isPlayful ? AppColors.playfulPrimary : AppColors.playfulSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: !isPlayful ? AppColors.playfulPrimary : AppColors.playfulText.withOpacity(0.1), width: 2),
                            ),
                            child: Column(
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
                                Text('Modern', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: !isPlayful ? Colors.white : AppColors.playfulText)),
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
            const Text('About', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.playfulText)),
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
                  const Text('PawLog', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.playfulText)),
                  const SizedBox(height: 4),
                  Text('Version 1.0.0', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.playfulText.withOpacity(0.6))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.playfulPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Made with ❤️ for cat lovers', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.playfulText)),
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
}
