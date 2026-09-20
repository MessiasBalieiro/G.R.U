import 'package:flutter/material.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/floating.dart';
import '../../widgets/gru_button.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/gru_scaffold.dart';

/// "App G.R.U": boas-vindas com mascote, Login e Cadastre-se.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GruSystemUi(
      navColor: AppColors.dark,
      child: Scaffold(
        backgroundColor: AppColors.dark,
        body: Stack(
          children: [
            Positioned(
              top: -6,
              left: -10,
              child: SafeArea(
                child: Opacity(
                  opacity: 0.75,
                  child: Image.asset(AppImages.fern, width: 150),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Column(
                  children: [
                    const Spacer(flex: 4),
                    const Floating(child: GruMascot(size: 200)),
                    const SizedBox(height: 20),
                    const Text(
                      'Bem-vindo ao app do G.R.U',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Gerenciador de Resíduos Urbanos',
                      style: TextStyle(color: Colors.white60, fontSize: 12.5),
                    ),
                    const Spacer(flex: 3),
                    GruButton(
                      label: 'Login',
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.login),
                    ),
                    const SizedBox(height: 14),
                    GruButton(
                      label: 'Cadastre-se',
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.cadastro),
                    ),
                    const Spacer(flex: 2),
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
