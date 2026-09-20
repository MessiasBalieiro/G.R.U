import 'package:flutter/material.dart';

import '../../core/constants/app_images.dart';

/// Google / Microsoft / Apple (apenas visuais, como na versão web).
class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key, this.iconSize = 26});

  final double iconSize;

  void _emBreve(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login social em breve.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget item(String asset) => InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _emBreve(context),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Image.asset(asset,
                width: iconSize, height: iconSize, fit: BoxFit.contain),
          ),
        );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: iconSize * 0.8,
        vertical: iconSize * 0.4,
      ),
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
          item(AppImages.googleLogo),
          SizedBox(width: iconSize * 0.7),
          item(AppImages.microsoftLogo),
          SizedBox(width: iconSize * 0.7),
          item(AppImages.appleLogo),
        ],
      ),
    );
  }
}
