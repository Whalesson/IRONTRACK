import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_colors.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: IronTrackApp(),
    ),
  );
}

class IronTrackApp extends StatelessWidget {
  const IronTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: const HomeScreen(),
    );
  }
}
