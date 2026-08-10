import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../routes/app_routes.dart';

/// Rodapé simples usado nas páginas públicas.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.dark,
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        children: [
          const GruMascotFooterMark(),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.appDownload),
            icon: const Icon(Icons.phone_android_rounded,
                color: AppColors.green, size: 16),
            label: const Text(
              'Baixe nosso aplicativo',
              style: TextStyle(color: AppColors.green, fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '© ${DateTime.now().year} ${AppStrings.appFullName}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class GruMascotFooterMark extends StatelessWidget {
  const GruMascotFooterMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G.R.U',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
