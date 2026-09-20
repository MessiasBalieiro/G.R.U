import 'package:flutter/material.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/gru_scaffold.dart';

/// "Tela de Loading": símbolo de reciclagem girando no fundo azul-escuro.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GruSystemUi(
      navColor: AppColors.dark,
      child: Scaffold(
        backgroundColor: AppColors.dark,
        body: Center(
          child: RotationTransition(
            turns: _c,
            child: Opacity(
              opacity: 0.9,
              child: Image.asset(AppImages.recyclingSymbol, width: 170),
            ),
          ),
        ),
      ),
    );
  }
}
