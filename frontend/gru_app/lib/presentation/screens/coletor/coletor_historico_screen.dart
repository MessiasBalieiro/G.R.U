import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/domain_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/lixeira_model.dart';
import '../../../data/models/visita_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/capacity.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gru_scaffold.dart';
import '../../widgets/white_card.dart';

/// "Tela Histórico - Coletor": quando o coletor já esteve em cada lixeira.
class ColetorHistoricoScreen extends StatelessWidget {
  const ColetorHistoricoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = SessionService.instance.usuario!;
    final db = MockDataService.instance;

    return ListenableBuilder(
      listenable: db,
      builder: (context, _) {
        final visitas = db.visitasDoColetor(usuario.id);

        if (visitas.isEmpty) {
          return const GruScaffold(
            title: 'Histórico',
            background: kFundoColetor,
            child: EmptyState(
              icon: Icons.history_rounded,
              titulo: 'Nenhuma coleta ainda',
              mensagem:
                  'Quando você registrar uma coleta em uma lixeira, ela aparece aqui.',
            ),
          );
        }

        final limite = DateTime.now().subtract(const Duration(days: 30));
        final recentes = visitas.where((v) => v.dataHora.isAfter(limite)).length;
        final distintas = visitas.map((v) => v.lixeiraId).toSet().length;

        // Agrupa por dia (a lista já vem ordenada da mais recente).
        final itens = <Object>[];
        String? diaAtual;
        for (final v in visitas) {
          final rotulo = Fmt.rotuloDia(v.dataHora);
          final chave = '${v.dataHora.year}-${v.dataHora.month}-${v.dataHora.day}';
          if (chave != diaAtual) {
            diaAtual = chave;
            itens.add(rotulo);
          }
          itens.add(v);
        }

        return GruScaffold(
          title: 'Histórico',
          background: kFundoColetor,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 150),
            children: [
              Row(
                children: [
                  Expanded(
                      child: _Resumo(
                          valor: '$recentes', rotulo: 'Coletas\n(30 dias)')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _Resumo(
                          valor: '$distintas', rotulo: 'Lixeiras\nvisitadas')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _Resumo(
                          valor: Fmt.relativo(visitas.first.dataHora)
                              .replaceFirst('Há ', ''),
                          rotulo: 'Última\nvisita')),
                ],
              ),
              const SizedBox(height: 18),
              for (final item in itens)
                if (item is VisitaModel)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _VisitaCard(
                      visita: item,
                      onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.lixeira,
                          arguments: item.lixeiraId),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 0, 10),
                    child: Text(
                      item.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({required this.valor, required this.rotulo});

  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rotulo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _VisitaCard extends StatelessWidget {
  const _VisitaCard({required this.visita, required this.onTap});

  final VisitaModel visita;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final v = visita;
    final cor = corDoStatus(StatusLixeira.fromOcupacao(v.ocupacao));

    return WhiteCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 64,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        v.lixeiraNome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.dark),
                      ),
                    ),
                    const Icon(Icons.schedule_rounded,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text(Fmt.hora(v.dataHora),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.place_rounded,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(v.endereco,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Estava ${v.ocupacao}% cheia',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: v.ocupacao >= 40 && v.ocupacao < 70
                              ? const Color(0xFF9A6A0E)
                              : cor,
                        ),
                      ),
                    ),
                    if (v.material != null) MaterialChip(tipo: v.material!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
