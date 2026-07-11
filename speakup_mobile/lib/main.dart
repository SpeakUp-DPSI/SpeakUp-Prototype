import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/network/firebase_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await FirebaseApi().initNotifications();
  } catch (e) {
    debugPrint('Firebase not configured: $e');
  }

  runApp(
    const ProviderScope(
      child: SpeakUpApp(),
    ),
  );
}

class SpeakUpApp extends ConsumerWidget {
  const SpeakUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SpeakUp',
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // Breakpoint disamakan dengan Design_System.md §8.3 supaya konsisten
      // dengan dokumentasi — dipakai MainWrapperScreen untuk switch
      // sidebar (web/desktop) vs bottom nav (mobile).
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: const [
          Breakpoint(start: 0, end: 767, name: MOBILE),
          Breakpoint(start: 768, end: 1023, name: TABLET),
          Breakpoint(start: 1024, end: 1279, name: DESKTOP),
          Breakpoint(start: 1280, end: double.infinity, name: 'WIDE'),
        ],
      ),
    );
  }
}