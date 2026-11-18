import 'package:flutter/material.dart';
import 'package:gru_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';

/// Botão "Sair" usado no canto do header das Homes.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Sair',
      icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
      onPressed: () {
        context.read<AuthProvider>().logout();
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
      },
    );
  }
}
