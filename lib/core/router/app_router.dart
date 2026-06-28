import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Placeholder imports for screens
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/health/screens/health_screen.dart';
import '../../features/care_tracking/screens/care_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/training/screens/training_screen.dart';
import '../../features/stamps/screens/stamp_album_screen.dart';
import '../../features/cat_profile/screens/cat_form_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/reminders_screen.dart';
import '../constants/app_strings.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import '../../shared/models/cat.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/cat-form',
        pageBuilder: (context, state) {
          final cat = state.extra as Cat?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CatFormScreen(catToEdit: cat),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurveTween(curve: Curves.easeOut).animate(animation)),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurveTween(curve: Curves.easeOut).animate(animation)),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/reminders',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const RemindersScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurveTween(curve: Curves.easeOut).animate(animation)),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/health',
            builder: (context, state) => const HealthScreen(),
          ),
          GoRoute(
            path: '/care',
            builder: (context, state) => const CareScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/training',
            builder: (context, state) => const TrainingScreen(),
          ),
          GoRoute(
            path: '/stamps',
            builder: (context, state) => const StampAlbumScreen(),
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithBottomNavBar extends ConsumerWidget {
  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateSelectedIndex(context);
    final theme = Theme.of(context);
    final themeType = ref.watch(themeProvider);

    // Theme-adaptive navbar colors
    Color navBg;
    Color activeColor;
    Color inactiveColor;
    bool showActiveUnderline;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (themeType) {
      case AppThemeType.modern:
        navBg = isDark ? theme.colorScheme.surface : Colors.white;
        activeColor = isDark ? theme.colorScheme.primary : const Color(0xFF1E293B);
        inactiveColor = isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.4) : const Color(0xFF94A3B8);
        showActiveUnderline = true;
        break;
      case AppThemeType.playful:
      default:
        navBg = isDark ? theme.colorScheme.surface : const Color(0xFFFFECD6);
        activeColor = isDark ? theme.colorScheme.primary : const Color(0xFFC0A3E5);
        inactiveColor = isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.4) : const Color(0xFF3E2723);
        showActiveUnderline = false;
        break;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(context, 0, currentIndex, ({Color? color, double? size}) => AppIcons.navHome(isModern: themeType == AppThemeType.modern, color: color, size: size ?? 28), AppStrings.get('nav_home'), activeColor, inactiveColor, showActiveUnderline),
                _buildNavItem(context, 1, currentIndex, ({Color? color, double? size}) => AppIcons.navHealth(isModern: themeType == AppThemeType.modern, color: color, size: size ?? 28), AppStrings.get('nav_health'), activeColor, inactiveColor, showActiveUnderline),
                _buildNavItem(context, 2, currentIndex, ({Color? color, double? size}) => AppIcons.navCare(isModern: themeType == AppThemeType.modern, color: color, size: size ?? 28), AppStrings.get('nav_care'), activeColor, inactiveColor, showActiveUnderline),
                _buildNavItem(context, 3, currentIndex, ({Color? color, double? size}) => AppIcons.navStats(isModern: themeType == AppThemeType.modern, color: color, size: size ?? 28), AppStrings.get('nav_stats'), activeColor, inactiveColor, showActiveUnderline),
                _buildNavItem(context, 4, currentIndex, ({Color? color, double? size}) => AppIcons.navAlbum(isModern: themeType == AppThemeType.modern, color: color, size: size ?? 28), AppStrings.get('nav_album'), activeColor, inactiveColor, showActiveUnderline),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, int currentIndex, Widget Function({Color? color, double size}) iconBuilder, String label, Color activeColor, Color inactiveColor, bool showUnderline) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconBuilder(
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Nunito',
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? activeColor : inactiveColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (showUnderline) ...[
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2.5,
                width: isSelected ? 20 : 0,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/health')) return 1;
    if (location.startsWith('/care')) return 2;
    if (location.startsWith('/analytics')) return 3;
    if (location.startsWith('/stamps')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/health');
        break;
      case 2:
        context.go('/care');
        break;
      case 3:
        context.go('/analytics');
        break;
      case 4:
        context.go('/stamps');
        break;
    }
  }
}

