import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../core/app_colors.dart';
import '../../domain/backup_service.dart';
import '../../data/exercise_repository.dart';
import '../../data/workout_repository.dart';
import '../../data/workout_set_repository.dart';
import '../../data/workout_template_repository.dart';
import '../widgets/pixel_button.dart';

// Provider para BackupService
final backupServiceProvider = Provider((ref) {
  return BackupService(
    exerciseRepository: ExerciseRepository(),
    workoutRepository: WorkoutRepository(),
    workoutSetRepository: WorkoutSetRepository(),
    templateRepository: WorkoutTemplateRepository(),
  );
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupService = ref.watch(backupServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CONFIGURAÇÕES'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Seção de Backup
          _buildSectionTitle('BACKUP E DADOS'),
          const SizedBox(height: 16),

          _buildSettingCard(
            title: 'EXPORTAR DADOS',
            description: 'Salvar backup de todos os dados em arquivo JSON',
            icon: Icons.upload_file,
            iconColor: AppColors.neonPrimary,
            onTap: () => _exportBackup(context, backupService),
          ),

          const SizedBox(height: 12),

          _buildSettingCard(
            title: 'IMPORTAR DADOS',
            description: 'Restaurar dados de um arquivo de backup',
            icon: Icons.download,
            iconColor: AppColors.neonSecondary,
            onTap: () => _importBackup(context, backupService),
          ),

          const SizedBox(height: 32),

          // Seção de Informações
          _buildSectionTitle('SOBRE'),
          const SizedBox(height: 16),

          _buildInfoCard(
            title: 'IRONTRACK',
            items: [
              'Versão: 1.0.0',
              'Gamified Pixel Hardcore',
              'Focused on Load Progression',
              'Inspired by Heavy Duty',
            ],
          ),

          const SizedBox(height: 32),

          // Rodapé
          Center(
            child: Column(
              children: [
                const Text(
                  'Desenvolvido com 💪 e 🔥',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© ${DateTime.now().year} IRONTRACK',
                  style: const TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.neonPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border.all(color: AppColors.surfaceMedium, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: iconColor, width: 2),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textDisabled,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border.all(color: AppColors.surfaceMedium, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.neonPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check,
                      color: AppColors.neonSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, BackupService backupService) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.neonPrimary),
        ),
      );

      final file = await backupService.saveBackupToFile();

      if (context.mounted) {
        Navigator.pop(context); // Fechar loading

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: const Text(
              'BACKUP CRIADO',
              style: TextStyle(
                color: AppColors.neonPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Backup salvo em:\n${file.path}',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            actions: [
              PixelButton(
                text: 'OK',
                isPrimary: false,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fechar loading

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: const Text(
              'ERRO',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Erro ao criar backup: $e',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            actions: [
              PixelButton(
                text: 'OK',
                isPrimary: false,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _importBackup(BuildContext context, BackupService backupService) async {
    try {
      // Selecionar arquivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);

      // Validar arquivo
      final isValid = await backupService.validateBackupFile(file);
      if (!isValid) {
        if (context.mounted) {
          _showErrorDialog(context, 'Arquivo de backup inválido');
        }
        return;
      }

      // Confirmar importação
      if (context.mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: const Text(
              'CONFIRMAR IMPORTAÇÃO',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Isso irá importar os dados do backup.\nDados duplicados serão ignorados.\nDeseja continuar?',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            actions: [
              PixelButton(
                text: 'CANCELAR',
                isPrimary: false,
                onPressed: () => Navigator.pop(context, false),
              ),
              const SizedBox(width: 8),
              PixelButton(
                text: 'IMPORTAR',
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );

        if (confirmed != true) return;
      }

      // Mostrar loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.neonPrimary),
          ),
        );
      }

      final result2 = await backupService.importFromFile(file);

      if (context.mounted) {
        Navigator.pop(context); // Fechar loading

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: Text(
              result2.success ? 'SUCESSO' : 'ERRO',
              style: TextStyle(
                color: result2.success ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              result2.toString(),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            actions: [
              PixelButton(
                text: 'OK',
                isPrimary: false,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Erro ao importar: $e');
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          'ERRO',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          PixelButton(
            text: 'OK',
            isPrimary: false,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
