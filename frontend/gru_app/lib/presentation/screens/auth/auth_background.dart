import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/gru_scaffold.dart';

/// Fundo das telas de cadastro: azul-escuro com a forma verde (Vector.svg)
/// subindo do rodapé.
class AuthBlobBackground extends StatelessWidget {
  const AuthBlobBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GruSystemUi(
      navColor: AppColors.green,
      child: Scaffold(
        backgroundColor: AppColors.dark,
        body: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: AspectRatio(
                  aspectRatio: 402 / 630,
                  child: SvgPicture.asset(AppWaves.greenBlob, fit: BoxFit.fill),
                ),
              ),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}
