import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/animated_svg_wave.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/liquid_button.dart';

class AreaTrabalhoScreen extends StatelessWidget {
  const AreaTrabalhoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Onda SVG animada no canto superior esquerdo (verde)
            Positioned(
              top: 0,
              left: 0,
              child: AnimatedSvgWave(
                assetPath: AppWaves.topGreen,
                width: 180,
                height: 100,
                fit: BoxFit.fill,
                amplitude: 8,
                period: const Duration(seconds: 5),
              ),
            ),
            PageContainer(
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

                      final cadastrar = LiquidButton(
                        icon: Icons.add_box_outlined,
                        label: 'Cadastrar Lixeira Inteligente',
                        color: AppColors.dark,
                        height: 190,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.cadastroLixeira),
                      );
                      final relatorio = LiquidButton(
                        icon: Icons.description_outlined,
                        label: 'Gerar Relatório',
                        color: AppColors.orange,
                        height: 190,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.gerarRelatorio),
                      );

                      if (isMobile) {
                        return Column(children: [
                          cadastrar,
                          const SizedBox(height: 20),
                          relatorio,
                        ]);
                      }

                      return Row(children: [
                        Expanded(child: cadastrar),
                        const SizedBox(width: 20),
                        Expanded(child: relatorio),
                      ]);
                    }),
                    const SizedBox(height: 20),
                    LiquidButton(
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
          ],
        ),
      ),
    );
  }
}
