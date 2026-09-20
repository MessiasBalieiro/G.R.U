import 'package:flutter/material.dart';

import '../../core/constants/app_images.dart';

/// Mascote do G.R.U.
class GruMascot extends StatelessWidget {
  const GruMascot({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImages.mascot,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
