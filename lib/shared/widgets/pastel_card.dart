import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

class PastelCard extends ConsumerWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const PastelCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeProvider);
    final isModern = themeType == AppThemeType.modern;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveColor = isModern 
        ? (isDark ? Theme.of(context).colorScheme.surface : Colors.white)
        : (backgroundColor ?? Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface);

    return Container(
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(isModern ? 16 : 32),
        border: isModern ? Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1.5) : null,
        boxShadow: isModern 
            ? [] 
            : [
                BoxShadow(
                  color: effectiveColor.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isModern ? 16 : 32),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
