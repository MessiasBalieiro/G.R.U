import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

/// Protege as telas da Área de Trabalho: enquanto confere o login salvo mostra
/// um carregamento; sem login, mostra a tela de Login.
class RotaProtegida extends StatelessWidget {
  const RotaProtegida({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.restaurando) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.green),
        ),
      );
    }
    if (auth.usuario == null) return const LoginScreen();
    return child;
  }
}
