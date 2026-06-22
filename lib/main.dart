import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/models/cat.dart';
import 'shared/models/meow_record.dart';
import 'shared/models/care_log.dart';
import 'shared/providers/cat_provider.dart';
import 'features/meow_record/providers/meow_record_provider.dart';
import 'features/care_tracking/providers/care_log_provider.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(CatAdapter());
  Hive.registerAdapter(MeowRecordAdapter());
  Hive.registerAdapter(CareLogAdapter());

  final catBox = await Hive.openBox<Cat>('cats');
  final meowRecordBox = await Hive.openBox<MeowRecord>('meow_records');
  final careLogBox = await Hive.openBox<CareLog>('care_logs');

  // Check if onboarding is complete
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        catBoxProvider.overrideWithValue(catBox),
        meowRecordBoxProvider.overrideWithValue(meowRecordBox),
        careLogBoxProvider.overrideWithValue(careLogBox),
      ],
      child: PawLogApp(showOnboarding: !onboardingComplete),
    ),
  );
}

class PawLogApp extends ConsumerStatefulWidget {
  final bool showOnboarding;
  
  const PawLogApp({super.key, required this.showOnboarding});

  @override
  ConsumerState<PawLogApp> createState() => _PawLogAppState();
}

class _PawLogAppState extends ConsumerState<PawLogApp> {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.showOnboarding;
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeNotifier = ref.watch(themeProvider.notifier);

    if (_showOnboarding) {
      return MaterialApp(
        title: 'PawLog',
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.currentThemeData,
        home: OnboardingScreen(
          onComplete: () {
            setState(() => _showOnboarding = false);
          },
        ),
      );
    }

    return MaterialApp.router(
      title: 'PawLog',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.currentThemeData,
      routerConfig: router,
    );
  }
}
