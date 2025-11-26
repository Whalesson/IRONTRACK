import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../domain/dashboard_service.dart';
import '../../data/exercise_repository.dart';
import '../../data/workout_repository.dart';
import '../../data/workout_set_repository.dart';
import '../../models/dashboard_stats.dart';
import '../widgets/pixel_button.dart';
import 'exercise_list_screen.dart';
import 'workout_today_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

// Provider para DashboardService
final dashboardServiceProvider = Provider((ref) {
  return DashboardService(
    exerciseRepository: ExerciseRepository(),
    workoutRepository: WorkoutRepository(),
    workoutSetRepository: WorkoutSetRepository(),
  );
});

// Provider para estatísticas do dashboard
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return await service.calculateStats();
});

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const ExerciseListScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.surfaceMedium, width: 2),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.neonPrimary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'EXERCÍCIOS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'HISTÓRICO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'CONFIG',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo e Título
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neonPrimary, width: 4),
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 80,
                color: AppColors.neonPrimary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'IRONTRACK',
              style: TextStyle(
                color: AppColors.neonPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'GAMIFIED PIXEL HARDCORE',
              style: TextStyle(
                color: AppColors.neonSecondary,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'FOCUSED ON LOAD PROGRESSION',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'INSPIRED BY HEAVY DUTY',
              style: TextStyle(
                color: AppColors.neonAccent,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 48),
            
            // Botão Principal
            PixelButton(
              text: 'START WORKOUT',
              icon: Icons.play_arrow,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutTodayScreen()),
                );
              },
            ),
            
            const SizedBox(height: 48),
            
            // Stats Panel com dados reais
            statsAsync.when(
              data: (stats) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('NÍVEL', stats.totalLevel.toString(), AppColors.levelPurple),
                  _buildStatCard('PRs', stats.totalPRs.toString(), AppColors.prGold),
                  _buildStatCard('STREAK', stats.currentStreak.toString(), AppColors.neonSecondary),
                ],
              ),
              loading: () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('NÍVEL', '...', AppColors.levelPurple),
                  _buildStatCard('PRs', '...', AppColors.prGold),
                  _buildStatCard('STREAK', '...', AppColors.neonSecondary),
                ],
              ),
              error: (_, __) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('NÍVEL', '0', AppColors.levelPurple),
                  _buildStatCard('PRs', '0', AppColors.prGold),
                  _buildStatCard('STREAK', '0', AppColors.neonSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
