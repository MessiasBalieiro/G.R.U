import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Faixa exibida quando o servidor falhou e a tela usa dados de exemplo.
class AvisoModoDemo extends StatelessWidget {
  const AvisoModoDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.orange),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Servidor indisponível: mostrando dados de exemplo. '
              'Cadastros ficam desativados até a conexão voltar.',
              style: TextStyle(fontSize: 13, color: AppColors.dark),
            ),
          ),
          if (auth.carregandoConta)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.orange),
            )
          else
            TextButton(
              onPressed: () => context.read<AuthProvider>().carregarConta(),
              child: const Text('Tentar de novo'),
            ),
        ],
      ),
    );
  }
}

/// Avisa (e retorna `true`) quando uma ação que grava no servidor é tentada
/// enquanto a tela mostra dados de exemplo.
bool bloquearNaDemo(BuildContext context) {
  if (!context.read<AuthProvider>().usandoDadosExemplo) return false;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(
        content: Text(
            'Servidor indisponível: não é possível salvar agora. Tente de novo em instantes.')));
  return true;
}
