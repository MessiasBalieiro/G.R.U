import 'package:flutter/material.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/animated_bottom_shape.dart';
import '../../widgets/gru_scaffold.dart';

/// Fundo das telas de login e cadastro: cor de fundo + forma SVG animada
/// sempre no rodapé da tela.
///
/// Padrão (cadastros): fundo azul-escuro com a forma verde.
/// Login: fundo verde com a forma azul-escura (`AuthBlobBackground.login`).
///
/// O teclado NÃO empurra a forma para cima: ela fica fixa no rodapé e o
/// conteúdo rola por cima.
class AuthBlobBackground extends StatelessWidget {
  const AuthBlobBackground({
    super.key,
    required this.child,
    this.background = AppColors.dark,
    this.blobAsset = AppWaves.greenBlob,
    this.blobColor = AppColors.green,
    this.navColor = AppColors.green,
    this.phase = 0,
  });

  /// Variante da tela de Login (verde com forma azul-escura).
  const AuthBlobBackground.login({super.key, required this.child})
      : background = AppColors.green,
        blobAsset = AppWaves.darkBlob,
        blobColor = AppColors.dark,
        navColor = AppColors.dark,
        phase = 1.7;

  final Widget child;
  final Color background;
  final String blobAsset;
  final Color blobColor;
  final Color navColor;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return GruSystemUi(
      navColor: navColor,
      child: Scaffold(
        backgroundColor: background,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBottomShape(
              asset: blobAsset,
              fillColor: blobColor,
              aspectRatio: 402 / 630,
              phase: phase,
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
