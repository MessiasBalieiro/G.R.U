import 'package:flutter/material.dart';
import '../../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/animated_svg_wave.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/liquid_button.dart';

class AreaTrabalhoScreen extends StatefulWidget {
  const AreaTrabalhoScreen({super.key});

  @override
  State<AreaTrabalhoScreen> createState() => _AreaTrabalhoScreenState();
}


class _AreaTrabalhoScreenState extends State<AreaTrabalhoScreen> {
  @override
  Widget build(BuildContext context) {
  final cargoUsuario = context.watch<AuthProvider>().usuario?.cargoUsuario;

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
              padding: EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => {
                              context.read<AuthProvider>().logout(),
                              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false)
                            },
                          icon: Icon(Icons.arrow_back_rounded,
                              color: AppColors.dark),
                          tooltip: 'Voltar para o Login',
                        ),

                        SizedBox(width: 4),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: GruMascot(size: 32),
                        ),
                        Spacer(),
                        Text(
                          'Área de Trabalho',
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 36),

                    LayoutBuilder(builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 560;

                      final cadastrarLixeira = LiquidButton(
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

                      final cadastrarColetor = LiquidButton(
                        icon: Icons.add_box_outlined,
                        label: 'Cadastrar Coletor',
                        color: AppColors.dark,
                        height: 190,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.cadastroColetor),
                      );

                      if (isMobile) {
                        return Column(children: cargoUsuario == "ADMINISTRADOR" ? [
                          cadastrarLixeira,
                        ]: [
                          cadastrarColetor,
                          SizedBox(height: 20),
                          relatorio,
                        ]);
                      }

                      return Row(children: cargoUsuario == "ADMINISTRADOR" ?  [
                        Expanded(child: cadastrarLixeira),
                      ] : [
                        Expanded(child: cadastrarColetor),
                        SizedBox(width: 20),
                        Expanded(child: relatorio)
                      ]);
                    }),

                    SizedBox(height: 20),

                    if(cargoUsuario == "CONTRATANTE") LiquidButton(
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
