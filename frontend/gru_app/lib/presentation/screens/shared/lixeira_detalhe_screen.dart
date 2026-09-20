import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/domain_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/map_launcher.dart';
import '../../../data/models/lixeira_model.dart';
import '../../../data/models/residuo_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/session_service.dart';
import '../../widgets/capacity.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gru_button.dart';
import '../../widgets/gru_scaffold.dart';
import '../../widgets/white_card.dart';

/// Detalhe da lixeira (recebe o `id` em `arguments`).
///
/// Mostra capacidade, material mais concentrado, localização e coletas.
/// O Coletor ainda vê "Suas visitas aqui" e o botão "Registrar coleta".
class LixeiraDetalheScreen extends StatelessWidget {
  const LixeiraDetalheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    final usuario = SessionService.instance.usuario!;
    final db = MockDataService.instance;
    final fundo = usuario.ehAdmin ? kFundoAdmin : kFundoColetor;

    return ListenableBuilder(
      listenable: db,
      builder: (context, _) {
        final l = id == null ? null : db.lixeiraPorId(id);
        if (l == null) {
          return GruScaffold(
            title: 'Lixeira',
            background: fundo,
            child: const EmptyState(
              icon: Icons.search_off_rounded,
              titulo: 'Lixeira não encontrada',
              mensagem: 'Ela pode ter sido removida.',
            ),
          );
        }

        final inst = db.instituicaoPorId(l.instituicaoId);
        final visitas = db.visitasDaLixeira(l.id);
        final minhas = visitas.where((v) => v.coletorId == usuario.id).toList();
        final lista = usuario.ehColetor ? minhas : visitas;

        return GruScaffold(
          title: 'Lixeira',
          background: fundo,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 150),
            children: [
              _CapacidadeCard(lixeira: l, instituicao: inst?.nome),
              const SizedBox(height: 14),
              _MaterialCard(lixeira: l),
              const SizedBox(height: 14),
              _LocalizacaoCard(lixeira: l),
              const SizedBox(height: 14),
              WhiteCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Titulo(
                      icone: Icons.history_rounded,
                      texto: usuario.ehColetor
                          ? 'Suas visitas aqui'
                          : 'Coletas nesta lixeira',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.ultimaColeta == null
                          ? 'Nenhuma coleta registrada ainda.'
                          : 'Última coleta: ${Fmt.dataHora(l.ultimaColeta!)} '
                              '(${Fmt.relativo(l.ultimaColeta!)})',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    if (lista.isEmpty)
                      Text(
                        usuario.ehColetor
                            ? 'Você ainda não coletou nesta lixeira.'
                            : 'Sem coletas para mostrar.',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.dark),
                      ),
                    for (final v in lista.take(4))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 18, color: AppColors.green),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                usuario.ehColetor
                                    ? '${Fmt.rotuloDia(v.dataHora)} · ${Fmt.hora(v.dataHora)}'
                                    : '${v.coletorNome.split(' ').first} · '
                                        '${Fmt.rotuloDia(v.dataHora)} ${Fmt.hora(v.dataHora)}',
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.dark),
                              ),
                            ),
                            Text('${v.ocupacao}%',
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (usuario.ehColetor) ...[
                const SizedBox(height: 20),
                Center(
                  child: GruButton(
                    label: 'Registrar coleta',
                    icon: Icons.local_shipping_rounded,
                    width: double.infinity,
                    onPressed: () => _confirmar(context, l),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmar(BuildContext context, LixeiraModel l) async {
    final usuario = SessionService.instance.usuario!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Registrar coleta?'),
        content: Text(
          'A ${l.nome} está ${l.ocupacao}% ocupada. Ao confirmar, a coleta '
          'entra no seu histórico e a lixeira volta a 0%.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmar',
                style: TextStyle(
                    color: AppColors.orange, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      MockDataService.instance.registrarColeta(l, usuario);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coleta registrada no seu histórico!')),
      );
    }
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 18, color: AppColors.dark),
        const SizedBox(width: 8),
        Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }
}

// ── Capacidade ──────────────────────────────────────────────────────────────
class _CapacidadeCard extends StatelessWidget {
  const _CapacidadeCard({required this.lixeira, required this.instituicao});

  final LixeiraModel lixeira;
  final String? instituicao;

  @override
  Widget build(BuildContext context) {
    final l = lixeira;
    final cor = corDoStatus(l.status);
    final precisaColeta = l.status.codigo >= 3;

    return WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.nome,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 19,
              color: AppColors.dark,
            ),
          ),
          if (instituicao != null) ...[
            const SizedBox(height: 2),
            Text(instituicao!,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textMuted)),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              CapacityRing(ocupacao: l.ocupacao),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Capacidade',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '${l.livre}% livre',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatusChip(status: l.status),
                    if (precisaColeta) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 16, color: cor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Coleta recomendada',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: cor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Material ────────────────────────────────────────────────────────────────
class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.lixeira});

  final LixeiraModel lixeira;

  @override
  Widget build(BuildContext context) {
    final l = lixeira;
    final predominante = l.materialPredominante;
    final ordenados = TipoResiduo.values.toList()
      ..sort((a, b) => (l.composicao[b] ?? 0).compareTo(l.composicao[a] ?? 0));

    return WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Titulo(
              icone: Icons.pie_chart_rounded, texto: 'Material mais concentrado'),
          const SizedBox(height: 14),
          if (predominante == null)
            const Text(
              'Os sensores ainda não identificaram materiais nesta lixeira.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            )
          else ...[
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: predominante.cor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(predominante.icone,
                      color: predominante.cor, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      predominante.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: AppColors.dark,
                      ),
                    ),
                    Text(
                      '${l.percentualPredominante}% do conteúdo',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final t in ordenados)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 62,
                      child: Text(t.label,
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.dark)),
                    ),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                            begin: 0, end: (l.composicao[t] ?? 0) / 100),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: 8,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ColoredBox(
                                      color: AppColors.dark
                                          .withValues(alpha: 0.08)),
                                ),
                                Positioned.fill(
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: v.clamp(0.0, 1.0),
                                    child: ColoredBox(color: t.cor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 42,
                      child: Text(
                        '${l.composicao[t] ?? 0}%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Localização ─────────────────────────────────────────────────────────────
class _LocalizacaoCard extends StatelessWidget {
  const _LocalizacaoCard({required this.lixeira});

  final LixeiraModel lixeira;

  @override
  Widget build(BuildContext context) {
    final l = lixeira;
    return WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Titulo(icone: Icons.place_rounded, texto: 'Localização'),
          const SizedBox(height: 12),
          Text(l.endereco,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark)),
          const SizedBox(height: 3),
          Text('Coordenadas: ${l.coordenadaTexto}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
          if (l.observacoes != null) ...[
            const SizedBox(height: 3),
            Text(l.observacoes!,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted)),
          ],
          const SizedBox(height: 14),
          GruButton(
            label: 'Abrir no mapa',
            icon: Icons.directions_rounded,
            color: AppColors.dark,
            width: double.infinity,
            onPressed: () => abrirNoMapa(context, l),
          ),
        ],
      ),
    );
  }
}
