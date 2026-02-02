import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reports/firebase_options.dart';
import 'package:reports/providers/providers.dart';
import 'package:reports/view/widgets/general_loading.dart';
import 'package:reports/view/login_view.dart';
import 'package:reports/view/reports_view.dart';
import 'package:reports/viewModel/theme_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: constant_identifier_names
const int ANIMATION_DURATION_MS = 860;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
      // App already exists native side kept it.
    }
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getBool('rememberMePreference') == null) {
    prefs.setBool('rememberMePreference', true);
  }
  bool rememberMe = prefs.getBool('rememberMePreference') ?? true;

  if (!rememberMe) {
    await FirebaseAuth.instance.signOut();
  }

  ThemeMode savedThemeMode = ThemeMode.values.firstWhere((mode) => mode.toString() == prefs.getString('themePreference'), orElse: () => ThemeMode.system);

  runApp(
    ProviderScope(
      overrides: [themeViewModelProvider.overrideWith((ref) => ThemeViewModel(initialMode: savedThemeMode))],
      child: const MyApp(),
    ),
  );

  FlutterNativeSplash.remove();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeViewModelProvider).themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reports',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: ANIMATION_DURATION_MS),
              child: const GeneralLoadingScreen(),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
            );
          }

          if (snapshot.hasData) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: ANIMATION_DURATION_MS),
              child: const ReportsView(),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: ANIMATION_DURATION_MS),
            child: const LoginView(),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
    );
  }
}

ThemeData buildLightTheme() {
  const Color scaffoldAndAppBarColor = Color.fromARGB(255, 255, 255, 255);
  return ThemeData.light().copyWith(
    //textTheme: GoogleFonts.robotoMonoTextTheme(ThemeData.light().textTheme),
    scaffoldBackgroundColor: scaffoldAndAppBarColor,
    canvasColor: const Color.fromARGB(176, 221, 213, 213),
    appBarTheme: const AppBarTheme(backgroundColor: scaffoldAndAppBarColor),
    cardTheme: CardThemeData(
      color: const Color(0xFFF8FAFC),
      elevation: 0,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.blueAccent)),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(foregroundColor: Colors.white)),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    //textTheme: GoogleFonts.robotoMonoTextTheme(ThemeData.dark().textTheme),
    primaryColor: Colors.blue,
    iconTheme: IconThemeData(color: Colors.grey[300]),
    canvasColor: Colors.black,
    cardTheme: CardThemeData(
      color: const Color(0xFF1E293B),
      elevation: 0,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.white)),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(foregroundColor: Colors.white)),
  );
}
