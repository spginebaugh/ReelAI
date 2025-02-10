import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:reel_ai/router/app_router.dart';
import 'package:reel_ai/utils/app_theme.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stack) {
    debugPrint('Error initializing app: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Reel AI',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Force light mode
      routerConfig: router,
    );
  }
}
