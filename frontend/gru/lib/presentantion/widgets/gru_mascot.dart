import 'package:flutter/material.dart';
import '../../core/constants/app_images.dart';

/// Ícone/mascote do G.R.U.
class GruMascot extends StatelessWidget {
  const GruMascot({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImages.gruMascot,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

/// Lockup horizontal "mascote + G.R.U" usado no header da Home.
class GruLogoLockup extends StatelessWidget {
  const GruLogoLockup({
    super.key,
    this.iconSize = 34,
    this.textColor = Colors.white,
  });

  final double iconSize;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GruMascot(size: iconSize),
        const SizedBox(width: 10),
        Text(
          'G.R.U',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: iconSize * 0.75,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
