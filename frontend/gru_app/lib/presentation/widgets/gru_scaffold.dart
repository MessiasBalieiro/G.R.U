import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import 'bottom_wave.dart';
import 'gru_mascot.dart';

/// Barra de status transparente com ícones claros (fundos escuros/verdes).
class GruSystemUi extends StatelessWidget {
  const GruSystemUi({super.key, required this.child, this.navColor});

  final Widget child;
  final Color? navColor;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: navColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: child,
    );
  }
}

/// Casca das telas internas do Figma: fundo colorido (azul-escuro para o
/// Administrador, verde para o Coletor), mascote no canto esquerdo, título
/// no canto direito e onda laranja no rodapé.
class GruScaffold extends StatelessWidget {
  const GruScaffold({
    super.key,
    required this.title,
    required this.background,
    required this.child,
    this.showBack = true,
    this.trailing,
    this.showWave = true,
  });

  final String title;
  final Color background;
  final Widget child;
  final bool showBack;
  final Widget? trailing;
  final bool showWave;

  @override
  Widget build(BuildContext context) {
    return GruSystemUi(
      navColor: background,
      child: Scaffold(
        backgroundColor: background,
        body: Stack(
          children: [
            if (showWave) const BottomWave(),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(showBack ? 4 : 20, 8, 12, 4),
                    child: Row(
                      children: [
                        if (showBack)
                          IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                size: 18, color: Colors.white),
                            tooltip: 'Voltar',
                          ),
                        const GruMascot(size: 44),
                        const Spacer(),
                        Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 1.4,
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 4),
                          trailing!,
                        ],
                      ],
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fundo padrão das telas de Admin.
const Color kFundoAdmin = AppColors.dark;

/// Fundo padrão das telas de Coletor.
const Color kFundoColetor = AppColors.green;
