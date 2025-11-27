import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import '../widgets/pixel_button.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('onboarding_completed') ?? false);
  }
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'BEM-VINDO AO\nIRONTRACK',
      description: 'Seu aplicativo de treino gamificado com estética pixel art hardcore',
      icon: Icons.fitness_center,
      color: AppColors.neonPrimary,
    ),
    OnboardingPage(
      title: 'FILOSOFIA\nHEAVY DUTY',
      description: 'Inspirado em Mike Mentzer e Dorian Yates. Foco em intensidade, não volume.',
      icon: Icons.flash_on,
      color: AppColors.neonSecondary,
      details: [
        'Séries até a falha muscular',
        'Progressão de carga constante',
        'Menos séries, mais intensidade',
        'Recuperação adequada',
      ],
    ),
    OnboardingPage(
      title: 'SISTEMA DE\nPROGRESSÃO',
      description: 'Ganhe XP e suba de nível a cada treino. Bata PRs e torne-se uma lenda!',
      icon: Icons.trending_up,
      color: AppColors.levelPurple,
      details: [
        'XP por série completada',
        'Level up ao atingir metas',
        'PRs (Personal Records)',
        'Streak de dias consecutivos',
      ],
    ),
    OnboardingPage(
      title: 'CONQUISTAS E\nRECOMPENSAS',
      description: 'Desbloqueie conquistas épicas e acompanhe seu progresso',
      icon: Icons.emoji_events,
      color: AppColors.prGold,
      details: [
        '19 conquistas para desbloquear',
        'Categorias: Progressão, Consistência, Força e PRs',
        'Notificações ao desbloquear',
        'Acompanhe seu percentual de conclusão',
      ],
    ),
    OnboardingPage(
      title: 'PRONTO PARA\nCOMEÇAR?',
      description: 'Crie seus exercícios, monte seus treinos e comece sua jornada rumo ao topo!',
      icon: Icons.rocket_launch,
      color: AppColors.neonAccent,
      isLast: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Indicador de página
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.neonPrimary
                          : AppColors.surfaceMedium,
                      border: Border.all(
                        color: _currentPage == index
                            ? AppColors.neonAccent
                            : AppColors.surfaceMedium,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Conteúdo
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Botões de navegação
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: PixelButton(
                        text: 'VOLTAR',
                        icon: Icons.arrow_back,
                        isPrimary: false,
                        onPressed: _previousPage,
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: _currentPage == 0 ? 1 : 1,
                    child: PixelButton(
                      text: _currentPage == _pages.length - 1 ? 'COMEÇAR' : 'PRÓXIMO',
                      icon: _currentPage == _pages.length - 1 ? Icons.check : Icons.arrow_forward,
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),

            // Botão pular
            if (_currentPage < _pages.length - 1)
              TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'PULAR TUTORIAL',
                  style: AppTypography.pixelCaption(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: page.color, width: 4),
            ),
            child: Icon(
              page.icon,
              size: 100,
              color: page.color,
            ),
          ),

          const SizedBox(height: 48),

          // Título
          Text(
            page.title,
            style: AppTypography.pixelTitle(
              color: page.color,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Descrição
          Text(
            page.description,
            style: AppTypography.normalBody(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          if (page.details != null) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border.all(color: AppColors.surfaceMedium, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: page.details!.map((detail) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: page.color,
                            border: Border.all(color: AppColors.neonAccent, width: 2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            detail,
                            style: AppTypography.normalBody(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String>? details;
  final bool isLast;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.details,
    this.isLast = false,
  });
}
