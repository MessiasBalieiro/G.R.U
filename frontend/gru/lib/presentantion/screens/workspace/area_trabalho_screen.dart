import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/gru_mascot.dart';

class AreaTrabalhoScreen extends StatelessWidget {
  const AreaTrabalhoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageContainer(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                              AppRoutes.login, (_) => false),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.dark),
                      tooltip: 'Voltar para o Login',
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const GruMascot(size: 32),
                    ),
                    const Spacer(),
                    const Text(
                      'Área de Trabalho',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                LayoutBuilder(builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 560;
                  final cadastrar = _MenuCard(
                    icon: Icons.add_box_outlined,
                    label: 'Cadastrar Lixeira Inteligente',
                    color: AppColors.dark,
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.cadastroLixeira),
                  );
                  final relatorio = _MenuCard(
                    icon: Icons.description_outlined,
                    label: 'Gerar Relatório',
                    color: AppColors.orange,
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.gerarRelatorio),
                  );

                  if (isMobile) {
                    return Column(
                      children: [
                        SizedBox(height: 170, child: cadastrar),
                        const SizedBox(height: 20),
                        SizedBox(height: 170, child: relatorio),
                      ],
                    );
                  }

                  return SizedBox(
                    height: 190,
                    child: Row(
                      children: [
                        Expanded(child: cadastrar),
                        const SizedBox(width: 20),
                        Expanded(child: relatorio),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                _MenuCard(
                  icon: Icons.bar_chart_rounded,
                  label: 'Dashboard',
                  color: AppColors.green,
                  height: 100,
                  alignStart: true,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.dashboard),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.height,
    this.alignStart = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double? height;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: alignStart
              ? Row(
                  children: [
                    Icon(icon, color: color, size: 30),
                    const SizedBox(width: 14),
                    Text(
                      label,
                      style: const TextStyle(
                          color: AppColors.dark,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: color, size: 30),
                    Text(
                      label,
                      style: const TextStyle(
                          color: AppColors.dark,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
