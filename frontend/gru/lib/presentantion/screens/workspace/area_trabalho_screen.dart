import 'package:flutter/material.dart';
import '../../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/usuario_model.dart';
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
  void _sair() {
    context.read<AuthProvider>().logout();
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
  final auth = context.watch<AuthProvider>();
  final cargoUsuario = auth.usuario?.cargoUsuario;
  final usuario = auth.usuario;

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
                          onPressed: _sair,
                          icon: Icon(Icons.arrow_back_rounded,
                              color: AppColors.dark),
                          tooltip: 'Sair e voltar para o Login',
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
                        SizedBox(width: 12),
                        Expanded(child: _BarraUsuario(usuario: usuario)),
                        SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _sair,
                          icon: Icon(Icons.logout_rounded, size: 18),
                          label: Text('Sair'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.dark,
                            side: BorderSide(color: AppColors.dark.withValues(alpha: 0.4)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),
                    Text(
                      'Área de Trabalho',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 20),

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

/// "Olá, Nome" + instituição (e selo de demonstração) no topo.
class _BarraUsuario extends StatelessWidget {
  const _BarraUsuario({required this.usuario});

  final UsuarioModel? usuario;

  @override
  Widget build(BuildContext context) {
    final nome = (usuario?.nomeUsuario ?? '').trim();
    final primeiro = nome.isEmpty ? '' : nome.split(' ').first;
    final inst = (usuario?.instituicao ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          primeiro.isEmpty ? 'Olá!' : 'Olá, $primeiro',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: AppColors.dark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (inst.isNotEmpty)
          Text(
            inst,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
      ],
    );
  }
}
