import 'package:flutter/material.dart';
import '../../core/constants/app_images.dart';

/// Linha com os botões de login social (Google / Apple / Microsoft)
class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
    this.onMicrosoftPressed,
    this.iconSize = 26,
  });

  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final VoidCallback? onMicrosoftPressed;

  /// Tamanho de cada logo - permite deixar a linha maior em telas largas.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final gap = iconSize * 0.9;
    final padH = iconSize * 0.9;
    final padV = iconSize * 0.55;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SocialIcon(
              asset: AppImages.googleLogo, onTap: onGooglePressed, size: iconSize),
          SizedBox(width: gap),
          _SocialIcon(
              asset: AppImages.appleLogo, onTap: onApplePressed, size: iconSize),
          SizedBox(width: gap),
          _SocialIcon(
              asset: AppImages.microsoftLogo,
              onTap: onMicrosoftPressed,
              size: iconSize),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.asset, required this.size, this.onTap});

  final String asset;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login social em breve.')),
            );
          },
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset(asset, width: size, height: size, fit: BoxFit.contain),
      ),
    );
  }
}
