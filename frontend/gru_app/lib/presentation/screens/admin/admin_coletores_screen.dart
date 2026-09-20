import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/session_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gru_scaffold.dart';
import '../../widgets/white_card.dart';

/// "Tela Coletores - Admin": coletores vinculados à instituição e os que
/// se cadastraram e aguardam vínculo.
class AdminColetoresScreen extends StatelessWidget {
  const AdminColetoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = SessionService.instance.usuario!;
    final db = MockDataService.instance;
    final instId = usuario.instituicaoPrincipalId;

    return ListenableBuilder(
      listenable: db,
      builder: (context, _) {
        final vinculados =
            instId == null ? <UsuarioModel>[] : db.coletoresDaInstituicao(instId);
        final pendentes = db.coletoresSemVinculo();
        final inst = instId == null ? null : db.instituicaoPorId(instId);

        return GruScaffold(
          title: 'Coletores',
          background: kFundoAdmin,
          child: (vinculados.isEmpty && pendentes.isEmpty)
              ? const EmptyState(
                  icon: Icons.groups_rounded,
                  titulo: 'Nenhum coletor ainda',
                  mensagem:
                      'Quando um coletor se cadastrar, ele aparece aqui para você vincular.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 150),
                  children: [
                    if (inst != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 14),
                        child: Text(
                          inst.nome,
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
                        instituicaoId: instId!,
                        vinculado: true,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (pendentes.isNotEmpty && instId != null) ...[
                      const SizedBox(height: 10),
                      _Titulo('Aguardando vínculo (${pendentes.length})'),
                      for (final c in pendentes) ...[
                        _ColetorCard(
                          coletor: c,
                          instituicaoId: instId,
                          vinculado: false,
                        ),
                        const SizedBox(height: 12),
                      ],
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
    required this.instituicaoId,
    required this.vinculado,
  });

  final UsuarioModel coletor;
  final String instituicaoId;
  final bool vinculado;

  @override
  Widget build(BuildContext context) {
    final db = MockDataService.instance;
    final visitas = db.visitasDoColetor(coletor.id)
        .where((v) => v.instituicaoId == instituicaoId)
        .toList();
    final ultima = visitas.isEmpty ? null : visitas.first.dataHora;

    return WhiteCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: vinculado ? AppColors.dark : AppColors.orange,
            child: Text(
              coletor.iniciais,
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
                  coletor.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.dark),
                ),
                const SizedBox(height: 2),
                Text(
                  coletor.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
                if (vinculado) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_rounded,
                          size: 13, color: AppColors.green),
                      const SizedBox(width: 4),
                      Text(
                        '${visitas.length} coletas'
                        '${ultima != null ? ' · ${Fmt.relativo(ultima)}' : ''}',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (vinculado)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: AppColors.textMuted),
              onSelected: (_) {
                db.desvincularColetor(coletor.id, instituicaoId);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${coletor.primeiroNome} foi desvinculado.')));
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'desvincular', child: Text('Desvincular')),
              ],
            )
          else
            ElevatedButton(
              onPressed: () {
                db.vincularColetor(coletor.id, instituicaoId);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${coletor.primeiroNome} foi vinculado!')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              child: const Text('Vincular'),
            ),
        ],
      ),
    );
  }
}
