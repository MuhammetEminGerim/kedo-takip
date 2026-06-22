import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Placeholder imports for screens
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/meow_record/screens/record_screen.dart';
import '../../features/care_tracking/screens/care_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/training/screens/training_screen.dart';
import '../../features/cat_profile/screens/cat_form_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../theme/app_icons.dart';
import '../../shared/models/cat.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/cat-form',
        builder: (context, state) {
          final cat = state.extra as Cat?;
          return CatFormScreen(catToEdit: cat);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
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
            path: '/record',
            builder: (context, state) => const RecordScreen(),
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

    return Scaffold(
      body: Stack(
        children: [
          child,
          // Floating Pill Nav Bar
          Positioned(
            left: 12,
            right: 12,
            bottom: 24,
            child: Container(
              height: 85,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6ED), // Match the cream background of the mockup nav
                borderRadius: BorderRadius.circular(42),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8D6E63).withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(context, 0, currentIndex, AppIcons.navHome, 'Home'),
                  _buildNavItem(context, 1, currentIndex, AppIcons.navRecord, 'Record'),
                  _buildNavItem(context, 2, currentIndex, AppIcons.navCare, 'Care'),
                  _buildNavItem(context, 3, currentIndex, AppIcons.navStats, 'Stats'),
                  _buildNavItem(context, 4, currentIndex, AppIcons.navLearn, 'Learn'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, int currentIndex, Widget Function({Color? color, double size}) iconBuilder, String label) {
    final isSelected = index == currentIndex;
    const selectedColor = Color(0xFFFF9E80); // Lighter coral to match mockup
    final iconColor = isSelected ? Colors.white : const Color(0xFF5D4037);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index, context),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(35),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconBuilder(color: iconColor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  color: iconColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/record')) return 1;
    if (location.startsWith('/care')) return 2;
    if (location.startsWith('/analytics')) return 3;
    if (location.startsWith('/training')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/record');
        break;
      case 2:
        context.go('/care');
        break;
      case 3:
        context.go('/analytics');
        break;
      case 4:
        context.go('/training');
        break;
    }
  }
}
