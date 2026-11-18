import 'package:flutter/material.dart';
import 'package:gru_app/providers/lixeira_provider.dart';
import 'package:gru_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/domain_styles.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gru_scaffold.dart';
import '../../widgets/white_card.dart';

/// "Tela Histórico - Coletor": quando o coletor já esteve em cada lixeira.
class ColetorHistoricoScreen extends StatelessWidget {
  const ColetorHistoricoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final providerWatch = context.watch<LixeiraProvider>();
    // final providerRead = context.read<LixeiraProvider>();
    // final providerReadUsuario = context.read<AuthProvider>();
    final providerWatchUsuario = context.watch<AuthProvider>();
    
    final usuario = providerWatchUsuario.usuario;
    final history = usuario?.history;
    // final db = MockDataService.instance;

    String calcularDiferenca(String dataInformada) {
      final partes = dataInformada.split(', ');
      final data = partes[0].split('/');
      final horario = partes[1].split(':');

      final dataUsuario = DateTime(
        int.parse(data[2]), // Ano
        int.parse(data[1]), // Mês
        int.parse(data[0]), // Dia
        int.parse(horario[0]), // Hora
        int.parse(horario[1]), // Minuto
      );

      final dataAtual = DateTime.now();
      final diferenca = dataAtual.difference(dataUsuario);

      final horas = diferenca.inHours;
      final dias = diferenca.inDays;

      if (horas < 24) {
        return '$horas hora(s)';
      } else {
        return '$dias dia(s)';
      }
    }

    return ListenableBuilder(
      listenable: providerWatchUsuario,
      builder: (context, _) {
        final visitas = usuario?.coletasRealizadas;

        if (visitas == 0 || visitas != null) {
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

        // final limite = DateTime.now().subtract(const Duration(days: 30));

        // Agrupa por dia (a lista já vem ordenada da mais recente).
        final itens = <Object>[];
        String? diaAtual;
        for (final v in history!) {
          // final rotulo = v['time_action'].split(", ")[1];
          final chave = v['time_action'].split(", ")[0];
          if (chave != diaAtual) {
            diaAtual = chave;
            itens.add(chave);
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
                      child: _Resumo(valor: '${usuario?.coletasRealizadas}', rotulo: 'Coletas')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _Resumo(valor: calcularDiferenca(history[0]['time_action']), rotulo: 'Última\nvisita')),
                ],
              ),
              const SizedBox(height: 18),
              for (final item in itens)
                if (item is Map)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _VisitaCard(
                      visita: item,
                      onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.lixeira,
                          arguments: item['trash_id']),
                      provider: providerWatch
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
  const _VisitaCard({required this.visita, required this.onTap, required this.provider});

  final Map<dynamic, dynamic> visita;
  final VoidCallback onTap;
  final LixeiraProvider provider;

  @override
  Widget build(BuildContext context) {
    final v = visita;
    
    final cor = corDoStatus(provider.buscarLixeira(v["trash_id"])!.statusLixeira);

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
                        v['trash_name'],
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
                    Text(v['time_action'].split(", ")[1],
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
                      child: Text(provider.buscarLixeira(v["trash_id"])!.enderecoLixeira,
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
                        v['action'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9A6A0E),
                        ),
                      ),
                    ),
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
