import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/locale_provider.dart';
import 'shared/models/cat.dart';
import 'shared/models/care_log.dart';
import 'shared/models/vaccine.dart';
import 'shared/models/appointment.dart';
import 'shared/models/medication.dart';
import 'shared/models/stamp.dart';
import 'shared/models/reminder.dart';
import 'shared/providers/cat_provider.dart';
import 'features/stamps/providers/stamp_provider.dart';
import 'features/care_tracking/providers/care_log_provider.dart';
import 'features/health/providers/health_provider.dart';
import 'features/settings/providers/reminder_provider.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr', null);
  
  await Hive.initFlutter();
  Hive.registerAdapter(CatAdapter());
  Hive.registerAdapter(CareLogAdapter());
  Hive.registerAdapter(VaccineAdapter());
  Hive.registerAdapter(AppointmentAdapter());
  Hive.registerAdapter(MedicationAdapter());
  Hive.registerAdapter(StampAdapter());
  Hive.registerAdapter(ReminderAdapter());

  // Setup Secure Storage for Hive Encryption
  const secureStorage = FlutterSecureStorage();
  var containsEncryptionKey = await secureStorage.containsKey(key: 'pawlog_hive_key');
  if (!containsEncryptionKey) {
    var key = Hive.generateSecureKey();
    await secureStorage.write(key: 'pawlog_hive_key', value: base64UrlEncode(key));
  }
  var encryptionKey = base64Url.decode((await secureStorage.read(key: 'pawlog_hive_key'))!);

  Future<Box<T>> openSecureBox<T>(String name) async {
    try {
      return await Hive.openBox<T>(name, encryptionCipher: HiveAesCipher(encryptionKey));
    } catch (e) {
      debugPrint('Error opening secure box $name: $e');
      // If decryption fails, do not blindly delete.
      // In a real app we might prompt the user or backup the corrupted file.
      // For now, we will throw an exception instead of deleting user data silently.
      throw Exception('Failed to open secure box: $name. Encryption key might be lost or corrupted.');
    }
  }

  final catBox = await openSecureBox<Cat>('cats');
  final careLogBox = await openSecureBox<CareLog>('care_logs');
  final vaccineBox = await openSecureBox<Vaccine>('vaccines');
  final appointmentBox = await openSecureBox<Appointment>('appointments');
  final medicationBox = await openSecureBox<Medication>('medications');
  final stampBox = await openSecureBox<Stamp>('stamps');
  final reminderBox = await openSecureBox<Reminder>('reminders');

  // Initialize notification service
  await NotificationService.instance.init();

  // Check if onboarding is complete
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        catBoxProvider.overrideWithValue(catBox),
        careLogBoxProvider.overrideWithValue(careLogBox),
        vaccineBoxProvider.overrideWithValue(vaccineBox),
        appointmentBoxProvider.overrideWithValue(appointmentBox),
        medicationBoxProvider.overrideWithValue(medicationBox),
        stampBoxProvider.overrideWithValue(stampBox),
        reminderBoxProvider.overrideWithValue(reminderBox),
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
    // Watch theme and locale state to trigger rebuild on changes
    ref.watch(themeProvider);
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(localeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    if (_showOnboarding) {
      return MaterialApp(
        title: 'PawLog',
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.currentThemeData,
        darkTheme: themeNotifier.currentDarkThemeData,
        themeMode: themeMode,
        locale: Locale(ref.watch(localeProvider)),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('tr'),
        ],
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
      darkTheme: themeNotifier.currentDarkThemeData,
      themeMode: themeMode,
      locale: Locale(ref.watch(localeProvider)),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      routerConfig: router,
    );
  }
}
