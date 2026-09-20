import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/domain_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/lixeira_model.dart';
import '../../../data/models/residuo_model.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/session_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gru_scaffold.dart';
import '../../widgets/white_card.dart';

/// "Tela Dashboard - Admin": mesmos indicadores do dashboard web, em
/// cartões brancos empilhados para caber no celular.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = SessionService.instance.usuario!;
    final db = MockDataService.instance;

    return ListenableBuilder(
      listenable: db,
      builder: (context, _) {
        final lixeiras = db.lixeirasDasInstituicoes(usuario.instituicaoIds);
        final instId = usuario.instituicaoPrincipalId;
        final ranking = instId == null
            ? <({UsuarioModel coletor, int coletas})>[]
            : db.ranking(instId);
        final visitas = db.visitasDasInstituicoes(usuario.instituicaoIds);

        if (lixeiras.isEmpty) {
          return const GruScaffold(
            title: 'Dashboard',
            background: kFundoAdmin,
            child: EmptyState(
              icon: Icons.bar_chart_rounded,
              titulo: 'Sem dados ainda',
              mensagem: 'Cadastre lixeiras para ver os indicadores aqui.',
            ),
          );
        }

        final ocupacaoMedia =
            (lixeiras.map((l) => l.ocupacao).reduce((a, b) => a + b) /
                    lixeiras.length)
                .round();
        final limite = DateTime.now().subtract(const Duration(days: 30));
        final coletas30 = visitas.where((v) => v.dataHora.isAfter(limite)).length;

        return GruScaffold(
          title: 'Dashboard',
          background: kFundoAdmin,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 150),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.delete_rounded,
                      cor: AppColors.green,
                      label: 'Lixeiras',
                      valor: '${lixeiras.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.speed_rounded,
                      cor: ocupacaoMedia >= 70
                          ? AppColors.orange
                          : AppColors.green,
                      label: 'Ocupação média',
                      valor: '$ocupacaoMedia%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.warning_amber_rounded,
                      cor: AppColors.danger,
                      label: 'Para coletar',
                      valor: '${lixeiras.where((l) => l.status.codigo >= 3).length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.local_shipping_rounded,
                      cor: AppColors.dark,
                      label: 'Coletas (30 dias)',
                      valor: '$coletas30',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _OcupacaoCard(lixeiras: lixeiras),
              const SizedBox(height: 16),
              _TiposResiduoCard(lixeiras: lixeiras),
              const SizedBox(height: 16),
              _RankingCard(ranking: [
                for (final r in ranking)
                  (nome: r.coletor.nome, coletas: r.coletas),
              ]),
              const SizedBox(height: 16),
              _AtividadesCard(
                itens: [
                  for (final v in visitas.take(5))
                    (
                      texto:
                          '${v.coletorNome.split(' ').first} coletou ${v.lixeiraNomeCurto}',
                      tempo: Fmt.relativo(v.dataHora),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// KPI
// ═══════════════════════════════════════════════════════════════════════════
class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.cor,
    required this.label,
    required this.valor,
  });

  final IconData icon;
  final Color cor;
  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTitulo extends StatelessWidget {
  const _CardTitulo(this.titulo, this.subtitulo);
  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.dark)),
        const SizedBox(height: 2),
        Text(subtitulo,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// OCUPAÇÃO POR LIXEIRA (barras)
// ═══════════════════════════════════════════════════════════════════════════
class _OcupacaoCard extends StatelessWidget {
  const _OcupacaoCard({required this.lixeiras});

  final List<LixeiraModel> lixeiras;

  @override
  Widget build(BuildContext context) {
    final ordenadas = [...lixeiras]
      ..sort((a, b) => b.ocupacao.compareTo(a.ocupacao));
    const alturaMax = 120.0;

    return WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitulo('Ocupação por lixeira', 'Nível atual de cada uma'),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, box) {
            final largura = max(56.0, box.maxWidth / ordenadas.length);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final l in ordenadas)
                    SizedBox(
                      width: largura,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${l.ocupacao}%',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.dark)),
                          const SizedBox(height: 4),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                                begin: 0, end: l.ocupacao / 100),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, __) => Container(
                              width: 26,
                              height: max(4.0, alturaMax * v),
                              decoration: BoxDecoration(
                                color: corDoStatus(l.status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Text(
                              l.nomeCurto,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TIPOS DE RESÍDUO (rosca)
// ═══════════════════════════════════════════════════════════════════════════
class _TiposResiduoCard extends StatelessWidget {
  const _TiposResiduoCard({required this.lixeiras});

  final List<LixeiraModel> lixeiras;

  @override
  Widget build(BuildContext context) {
    final soma = <TipoResiduo, double>{
      for (final t in TipoResiduo.values) t: 0.0,
    };
    for (final l in lixeiras) {
      l.composicao.forEach((tipo, pct) {
        soma[tipo] = soma[tipo]! + l.ocupacao * pct / 100;
      });
    }
    final total = soma.values.fold<double>(0, (a, b) => a + b);
    final dados = [
      for (final t in TipoResiduo.values) (tipo: t, valor: soma[t]!),
    ];

    return WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitulo(
              'Tipos de resíduo', 'Composição do que está nas lixeiras'),
          const SizedBox(height: 16),
          if (total == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Sem dados de material ainda.',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => SizedBox(
                    width: 130,
                    height: 130,
                    child: CustomPaint(
                      painter: _DonutPainter(dados: dados, progress: v),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      for (final d in dados)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: d.tipo.cor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(d.tipo.label,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.dark)),
                              ),
                              Text(
                                '${(d.valor / total * 100).round()}%',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.dark),
                              ),
                            ],
                          ),
                        ),
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

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.dados, required this.progress});

  final List<({TipoResiduo tipo, double valor})> dados;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final total = dados.fold<double>(0, (s, d) => s + d.valor);
    if (total == 0) return;

    const stroke = 24.0;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - stroke / 2,
    );

    var inicio = -pi / 2;
    for (final d in dados) {
      final sweep = d.valor / total * 2 * pi * progress;
      if (sweep <= 0) continue;
      canvas.drawArc(
        rect,
        inicio,
        max(0.0, sweep - 0.03),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = d.tipo.cor,
      );
      inicio += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress || old.dados != dados;
}

// ═══════════════════════════════════════════════════════════════════════════
// RANKING DE COLETORES
// ═══════════════════════════════════════════════════════════════════════════
class _RankingCard extends StatelessWidget {
  const _RankingCard({required this.ranking});

  final List<({String nome, int coletas})> ranking;

  @override
  Widget build(BuildContext context) {
    final maxColetas =
        ranking.isEmpty ? 1 : max(1, ranking.first.coletas);
    final medalhas = [AppColors.orange, AppColors.textMuted, AppColors.dark];

    return WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitulo('Ranking de coletores', 'Coletas realizadas'),
          const SizedBox(height: 14),
          if (ranking.isEmpty)
            const Text('Nenhum coletor vinculado ainda.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          for (int i = 0; i < ranking.length; i++) ...[
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: (i < 3 ? medalhas[i] : AppColors.textMuted)
                        .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${i + 1}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color:
                                i < 3 ? medalhas[i] : AppColors.textMuted)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ranking[i].nome,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 5,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ColoredBox(
                                    color: AppColors.dark
                                        .withValues(alpha: 0.07)),
                              ),
                              Positioned.fill(
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor:
                                      ranking[i].coletas / maxColetas,
                                  child: const ColoredBox(
                                      color: AppColors.green),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text('${ranking[i].coletas}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.dark)),
              ],
            ),
            if (i < ranking.length - 1)
              const Divider(height: 18, color: Color(0xFFEEEEEE)),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ATIVIDADES RECENTES
// ═══════════════════════════════════════════════════════════════════════════
class _AtividadesCard extends StatelessWidget {
  const _AtividadesCard({required this.itens});

  final List<({String texto, String tempo})> itens;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitulo('Atividades recentes', 'Últimas coletas'),
          const SizedBox(height: 12),
          if (itens.isEmpty)
            const Text('Nenhuma coleta registrada ainda.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          for (final a in itens)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.green, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(a.texto,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.dark)),
                  ),
                  Text(a.tempo,
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.textMuted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
