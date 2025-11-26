import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_colors.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: IronTrackApp(),
    ),
  );
}

class IronTrackApp extends StatefulWidget {
  const IronTrackApp({super.key});

  @override
  State<IronTrackApp> createState() => _IronTrackAppState();
}

class _IronTrackAppState extends State<IronTrackApp> {
  bool _showOnboarding = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final shouldShow = await OnboardingScreen.shouldShow();
    setState(() {
      _showOnboarding = shouldShow;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.neonPrimary),
          ),
        ),
      );
    }
    return MaterialApp(
      title: 'IRONTRACK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.neonPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonPrimary,
          secondary: AppColors.neonSecondary,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.neonPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          bodySmall: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      home: _showOnboarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
