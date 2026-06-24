import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/models/cat.dart';
import 'shared/models/care_log.dart';
import 'shared/models/vaccine.dart';
import 'shared/models/appointment.dart';
import 'shared/models/medication.dart';
import 'shared/models/stamp.dart';
import 'shared/providers/cat_provider.dart';
import 'features/stamps/providers/stamp_provider.dart';
import 'features/care_tracking/providers/care_log_provider.dart';
import 'features/health/providers/health_provider.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(CatAdapter());
  Hive.registerAdapter(CareLogAdapter());
  Hive.registerAdapter(VaccineAdapter());
  Hive.registerAdapter(AppointmentAdapter());
  Hive.registerAdapter(MedicationAdapter());
  Hive.registerAdapter(StampAdapter());

  final catBox = await Hive.openBox<Cat>('cats');
  final careLogBox = await Hive.openBox<CareLog>('care_logs');
  final vaccineBox = await Hive.openBox<Vaccine>('vaccines');
  final appointmentBox = await Hive.openBox<Appointment>('appointments');
  final medicationBox = await Hive.openBox<Medication>('medications');
  final stampBox = await Hive.openBox<Stamp>('stamps');

  // Check if onboarding is complete
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        catBoxProvider.overrideWithValue(catBox),
        careLogBoxProvider.overrideWithValue(careLogBox),
        vaccineBoxProvider.overrideWithValue(vaccineBox),
        appointmentBoxProvider.overrideWithValue(appointmentBox),
        medicationBoxProvider.overrideWithValue(medicationBox),
        stampBoxProvider.overrideWithValue(stampBox),
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
