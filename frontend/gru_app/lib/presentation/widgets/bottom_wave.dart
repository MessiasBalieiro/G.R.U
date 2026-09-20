import 'package:flutter/material.dart';

import '../../core/constants/app_images.dart';
import '../../core/theme/app_colors.dart';
import 'animated_bottom_shape.dart';

/// Onda laranja do rodapé (Frame_1.svg do Figma), animada.
/// Deve ser filho direto de um `Stack` com `StackFit.expand`.
class BottomWave extends StatelessWidget {
  const BottomWave({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedBottomShape(
      asset: AppWaves.orangeBottom,
      fillColor: AppColors.orange,
      height: height,
      drift: 0.06,
      bob: 8,
      duration: const Duration(seconds: 9),
    );
  }
}
