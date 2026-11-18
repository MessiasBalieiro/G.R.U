import 'package:flutter/material.dart';
import 'package:gru_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/usuario_model.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gru_scaffold.dart';
import '../../widgets/white_card.dart';

/// "Tela Coletores - Admin": coletores vinculados à instituição e os que
/// se cadastraram e aguardam vínculo.
class AdminColetoresScreen extends StatelessWidget {
  const AdminColetoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final providerWatch = context.watch<LixeiraProvider>();
    // final providerRead = context.read<LixeiraProvider>();
    // final providerReadUsuario = context.read<AuthProvider>();
    final providerWatchUsuario = context.watch<AuthProvider>();

    final usuario = providerWatchUsuario.usuario;

    return ListenableBuilder(
      listenable: providerWatchUsuario,
      builder: (context, _) {
        final vinculados = providerWatchUsuario.coletores;
        // final inst = usuario.instituicao;

        return GruScaffold(
          title: 'Coletores',
          background: kFundoAdmin,
          child: (vinculados.isEmpty)
              ? const EmptyState(
                  icon: Icons.groups_rounded,
                  titulo: 'Nenhum coletor ainda',
                  mensagem:
                      'Quando um coletor se cadastrar, ele aparece aqui para você vincular.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 150),
                  children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 14),
                        child: Text(
                          usuario?.instituicao == null ? "" : usuario!.instituicao,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12.5),
                        ),
                      ),
                    _Titulo('Vinculados (${vinculados.length})'),
                    if (vinculados.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Nenhum coletor vinculado ainda.',
                          style: TextStyle(color: Colors.white54, fontSize: 12.5),
                        ),
                      ),
                    for (final c in vinculados) ...[
                      _ColetorCard(
                        coletor: c,
                        vinculado: true,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ColetorCard extends StatelessWidget {
  const _ColetorCard({
    required this.coletor,
    required this.vinculado,
  });

  final UsuarioModel coletor;
  final bool vinculado;

  @override
  Widget build(BuildContext context) {
    // final db = MockDataService.instance;

    return WhiteCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: vinculado ? AppColors.dark : AppColors.orange,
            child: Text(
              coletor.nomeUsuario.substring(0, 2).toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coletor.nomeUsuario,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.dark),
                ),
                const SizedBox(height: 2),
                Text(
                  coletor.emailUsuario,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          // if (vinculado)
          //   PopupMenuButton<String>(
          //     icon: const Icon(Icons.more_vert_rounded,
          //         color: AppColors.textMuted),
          //     onSelected: (_) {
          //       db.desvincularColetor(coletor.id, instituicaoId);
          //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //           content: Text('${coletor.nomeUsuario} foi desvinculado.')));
          //     },
          //     itemBuilder: (_) => const [
          //       PopupMenuItem(value: 'desvincular', child: Text('Desvincular')),
          //     ],
          //   )
          // else
          //   ElevatedButton(
          //     onPressed: () {
          //       db.vincularColetor(coletor.id, instituicaoId);
          //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //           content: Text('${coletor.primeiroNome} foi vinculado!')));
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: AppColors.green,
          //       minimumSize: const Size(0, 36),
          //       padding: const EdgeInsets.symmetric(horizontal: 16),
          //       textStyle:
          //           const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          //     ),
          //     child: const Text('Vincular'),
          //   ),
        ],
      ),
    );
  }
}
