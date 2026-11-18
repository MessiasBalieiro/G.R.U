import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

/// Faixa que avisa que os dados são de exemplo (modo demonstração).
class AvisoModoDemo extends StatelessWidget {
  const AvisoModoDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_rounded, color: AppColors.green),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Modo demonstração: dados de exemplo, nada é salvo no servidor.',
              style: TextStyle(fontSize: 13, color: AppColors.dark),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
            child: const Text('Sair da demo'),
          ),
        ],
      ),
    );
  }
}

/// Avisa (e retorna `true`) quando uma ação que grava no servidor é tentada
/// no modo demonstração.
bool bloquearNaDemo(BuildContext context) {
  if (!context.read<AuthProvider>().modoDemo) return false;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(
        content: Text('No modo demonstração os cadastros não são salvos.')));
  return true;
}
