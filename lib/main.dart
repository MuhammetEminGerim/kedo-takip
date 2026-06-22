import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/models/cat.dart';
import 'shared/models/meow_record.dart';
import 'shared/models/care_log.dart';
import 'shared/providers/cat_provider.dart';
import 'features/meow_record/providers/meow_record_provider.dart';
import 'features/care_tracking/providers/care_log_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(CatAdapter());
  Hive.registerAdapter(MeowRecordAdapter());
  Hive.registerAdapter(CareLogAdapter());

  final catBox = await Hive.openBox<Cat>('cats');
  final meowRecordBox = await Hive.openBox<MeowRecord>('meow_records');
  final careLogBox = await Hive.openBox<CareLog>('care_logs');

  runApp(
    ProviderScope(
      overrides: [
        catBoxProvider.overrideWithValue(catBox),
        meowRecordBoxProvider.overrideWithValue(meowRecordBox),
        careLogBoxProvider.overrideWithValue(careLogBox),
      ],
      child: const PawLogApp(),
    ),
  );
}

class PawLogApp extends ConsumerWidget {
  const PawLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeNotifier = ref.watch(themeProvider.notifier);

    return MaterialApp.router(
      title: 'PawLog',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.currentThemeData,
      routerConfig: router,
    );
  }
}
