import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/coletor_model.dart';
import '../../../data/models/lixeira_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../widgets/workspace_header.dart';

enum _DashboardSecao { lixeiras, coletores, outras }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _DashboardSecao _secao = _DashboardSecao.lixeiras;

  @override
  Widget build(BuildContext context) {
    final lixeiras = MockDataService.instance.lixeiras;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Stack(
          children: [
            // ── FUNDO: grade de pontos sutil ────────────────────────
            Positioned.fill(child: const _DotGridBackground()),

            // ── DECORAÇÃO: arco circular verde (canto sup. direito) ──
            const Positioned(
              top: 0,
              right: 0,
              child: _CornerArc(
                color: AppColors.green,
                radius: 130,
                corner: _Corner.topRight,
              ),
            ),

            // ── DECORAÇÃO: arco circular laranja (canto inf. direito) ─
            const Positioned(
              bottom: 0,
              right: 0,
              child: _CornerArc(
                color: AppColors.orange,
                radius: 100,
                corner: _Corner.bottomRight,
              ),
            ),

            // ── DECORAÇÃO: arco menor verde (canto inf. esquerdo) ────
            const Positioned(
              bottom: 0,
              left: 0,
              child: _CornerArc(
                color: AppColors.green,
                radius: 60,
                corner: _Corner.bottomLeft,
              ),
            ),

            // ── CONTEÚDO ─────────────────────────────────────────────
            PageContainer(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: LayoutBuilder(builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;

                final sidebar = _DashboardSidebar(
                  isMobile: isMobile,
                  secaoAtual: _secao,
                  onSelecionar: (s) => setState(() => _secao = s),
                );

                if (isMobile) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const WorkspaceHeader(
                          title: 'Dashboard',
                          accentColor: AppColors.green,
                        ),
                        const SizedBox(height: 16),
                        _StatsRow(lixeiras: lixeiras),
                        const SizedBox(height: 16),
                        sidebar,
                        const SizedBox(height: 16),
                        _DashboardConteudo(secao: _secao, lixeiras: lixeiras),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WorkspaceHeader(
                      title: 'Dashboard',
                      accentColor: AppColors.green,
                    ),
                    const SizedBox(height: 16),
                    // Faixa de KPIs sempre visível
                    _StatsRow(lixeiras: lixeiras),
                    const SizedBox(height: 16),
                    // Corpo principal
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 200, child: sidebar),
                          const SizedBox(width: 20),
                          Expanded(
                            child: SingleChildScrollView(
                              child: _DashboardConteudo(
                                secao: _secao,
                                lixeiras: lixeiras,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DECORAÇÕES DE FUNDO
// ═══════════════════════════════════════════════════════════════════════════

/// Grade de pontos sutil no fundo da tela.
class _DotGridBackground extends StatelessWidget {
  const _DotGridBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotGridPainter());
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.dark.withValues(alpha: 0.045)
      ..strokeWidth = 1;
    const step = 28.0;
    const dotR = 1.4;
    for (double x = step; x < size.width; x += step) {
      for (double y = step; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), dotR, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Arco de círculo decorativo fixo em um canto da tela.
enum _Corner { topRight, bottomRight, bottomLeft }

class _CornerArc extends StatelessWidget {
  const _CornerArc({required this.color, required this.radius, required this.corner});

  final Color color;
  final double radius;
  final _Corner corner;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius,
      height: radius,
      child: CustomPaint(painter: _CornerArcPainter(color, radius, corner)),
    );
  }
}

class _CornerArcPainter extends CustomPainter {
  const _CornerArcPainter(this.color, this.radius, this.corner);

  final Color color;
  final double radius;
  final _Corner corner;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    switch (corner) {
      case _Corner.topRight:
        path.moveTo(size.width, 0);
        path.arcToPoint(
          Offset(0, size.height),
          radius: Radius.circular(size.width),
          clockwise: false,
        );
        path.lineTo(size.width, size.height);
        path.close();
        break;
      case _Corner.bottomRight:
        path.moveTo(size.width, size.height);
        path.arcToPoint(
          Offset(0, 0),
          radius: Radius.circular(size.width),
          clockwise: true,
        );
        path.lineTo(size.width, 0);
        path.close();
        break;
      case _Corner.bottomLeft:
        path.moveTo(0, size.height);
        path.arcToPoint(
          Offset(size.width, 0),
          radius: Radius.circular(size.width),
          clockwise: false,
        );
        path.lineTo(0, 0);
        path.close();
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerArcPainter old) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// FAIXA DE KPIs
// ═══════════════════════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.lixeiras});

  final List<LixeiraModel> lixeiras;

  @override
  Widget build(BuildContext context) {
    final ocupacaoMedia = lixeiras.isEmpty
        ? 0
        : (lixeiras.map((l) => l.statusLixeira.codigo + 1).reduce((a, b) => a + b) /
                lixeiras.length /
                5 *
                100)
            .round();

    final totalColetas = MockDataService.coletores
        .fold<int>(0, (t, c) => t + c.coletasRealizadas);

    final stats = [
      (icon: Icons.delete_rounded, cor: AppColors.green, label: 'Lixeiras', valor: '${lixeiras.length}'),
      (icon: Icons.speed_rounded, cor: AppColors.orange, label: 'Ocupação média', valor: '$ocupacaoMedia%'),
      (icon: Icons.groups_rounded, cor: AppColors.dark, label: 'Coletores', valor: '${MockDataService.coletores.length}'),
      (icon: Icons.local_shipping_rounded, cor: AppColors.green, label: 'Coletas / semana', valor: '$totalColetas'),
    ];

    return Row(
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          Expanded(
            child: _KpiCard(
              icon: stats[i].icon,
              cor: stats[i].cor,
              label: stats[i].label,
              valor: stats[i].valor,
            ),
          ),
          if (i < stats.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SIDEBAR
// ═══════════════════════════════════════════════════════════════════════════
class _DashboardSidebar extends StatelessWidget {
  const _DashboardSidebar({
    required this.isMobile,
    required this.secaoAtual,
    required this.onSelecionar,
  });

  final bool isMobile;
  final _DashboardSecao secaoAtual;
  final ValueChanged<_DashboardSecao> onSelecionar;

  static const _itens = [
    (
      secao: _DashboardSecao.lixeiras,
      icon: Icons.delete_outline_rounded,
      titulo: 'Gráficos das lixeiras',
      subtitulo: 'Ocupação e uso por lixeira',
    ),
    (
      secao: _DashboardSecao.coletores,
      icon: Icons.groups_outlined,
      titulo: 'Gráficos dos coletores',
      subtitulo: 'Desempenho da equipe de coleta',
    ),
    (
      secao: _DashboardSecao.outras,
      icon: Icons.dashboard_customize_outlined,
      titulo: 'Outras métricas',
      subtitulo: 'Indicadores gerais',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Seções',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 6),
          for (final i in _itens) ...[
            _SidebarItem(
              icon: i.icon,
              titulo: i.titulo,
              subtitulo: i.subtitulo,
              selecionado: secaoAtual == i.secao,
              onTap: () => onSelecionar(i.secao),
            ),
            if (i != _itens.last) const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.selecionado,
    required this.onTap,
  });

  final IconData icon;
  final String titulo;
  final String subtitulo;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selecionado
            ? AppColors.green.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: selecionado
                        ? AppColors.green
                        : AppColors.dark.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: selecionado ? Colors.white : AppColors.textMuted,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          color: selecionado ? AppColors.greenDark : AppColors.dark,
                          fontWeight: selecionado ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (selecionado)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CONTEÚDO PRINCIPAL
// ═══════════════════════════════════════════════════════════════════════════
class _DashboardConteudo extends StatelessWidget {
  const _DashboardConteudo({required this.secao, required this.lixeiras});

  final _DashboardSecao secao;
  final List<LixeiraModel> lixeiras;

  @override
  Widget build(BuildContext context) {
    switch (secao) {
      case _DashboardSecao.lixeiras:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GraficoBarrasCard(
              titulo: 'Ocupação por lixeira',
              subtitulo: 'Nível de preenchimento atual',
              barras: [
                for (final l in lixeiras)
                  _BarraDado(
                    valor: (l.statusLixeira.codigo + 1) / 5,
                    rotulo: l.nome.split(' ').last,
                    label: l.statusLixeira.label,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _GraficoRosquinhaCard(
              titulo: 'Status das lixeiras',
              lixeiras: lixeiras,
            ),
            const SizedBox(height: 14),
            _IndicadorCard(
              icon: Icons.delete_outline_rounded,
              titulo: 'Lixeiras cadastradas',
              valor: '${lixeiras.length}',
              detalhe: 'unidades monitoradas',
              cor: AppColors.green,
            ),
          ],
        );

      case _DashboardSecao.coletores:
        final coletores = MockDataService.coletores;
        final maxColetas = coletores
            .map((c) => c.coletasRealizadas)
            .reduce((a, b) => a > b ? a : b);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GraficoBarrasCard(
              titulo: 'Coletas por coletor',
              subtitulo: 'Desempenho na semana atual',
              barras: [
                for (final c in coletores)
                  _BarraDado(
                    valor: c.coletasRealizadas / maxColetas,
                    rotulo: c.nome.split(' ').first,
                    label: '${c.coletasRealizadas} coletas',
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _RankingColetoresCard(coletores: coletores),
            const SizedBox(height: 14),
            _IndicadorCard(
              icon: Icons.local_shipping_rounded,
              titulo: 'Total de coletas na semana',
              valor: '${coletores.fold<int>(0, (t, c) => t + c.coletasRealizadas)}',
              detalhe: 'coletas realizadas',
              cor: AppColors.orange,
            ),
          ],
        );

      case _DashboardSecao.outras:
        final ocupacaoMedia = lixeiras.isEmpty
            ? 0
            : (lixeiras.map((l) => l.statusLixeira.codigo + 1).reduce((a, b) => a + b) /
                    lixeiras.length /
                    5 *
                    100)
                .round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _IndicadorCard(
                    icon: Icons.speed_rounded,
                    titulo: 'Ocupação média',
                    valor: '$ocupacaoMedia%',
                    detalhe: 'das lixeiras ativas',
                    cor: ocupacaoMedia > 70 ? AppColors.orange : AppColors.green,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _IndicadorCard(
                    icon: Icons.groups_rounded,
                    titulo: 'Coletores ativos',
                    valor: '${MockDataService.coletores.length}',
                    detalhe: 'na equipe atual',
                    cor: AppColors.dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _IndicadorCard(
                    icon: Icons.location_city_rounded,
                    titulo: 'Instituições',
                    valor: '${lixeiras.map((l) => l.codigoDonoLixeira).toSet().length}',
                    detalhe: 'atendidas atualmente',
                    cor: AppColors.green,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _IndicadorCard(
                    icon: Icons.recycling_rounded,
                    titulo: 'Reciclagem estimada',
                    valor: '${(lixeiras.length * 48)}kg',
                    detalhe: 'esta semana',
                    cor: AppColors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _AtividadesCard(),
          ],
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GRÁFICO DE BARRAS — corrigido com LayoutBuilder
// ═══════════════════════════════════════════════════════════════════════════
class _BarraDado {
  const _BarraDado({required this.valor, required this.rotulo, required this.label});
  final double valor; // 0.0 a 1.0
  final String rotulo; // rótulo curto (eixo X)
  final String label;  // tooltip / linha de detalhe
}

class _GraficoBarrasCard extends StatelessWidget {
  const _GraficoBarrasCard({
    required this.titulo,
    required this.subtitulo,
    required this.barras,
  });

  final String titulo;
  final String subtitulo;
  final List<_BarraDado> barras;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Atual',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (barras.isEmpty)
            const SizedBox(
              height: 160,
              child: Center(child: Text('Sem dados ainda.')),
            )
          else
            // BARRAS: LayoutBuilder dá a altura exata disponível
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Eixo Y com linhas de grade
                  SizedBox(
                    width: 36,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final pct in ['100%', '75%', '50%', '25%', ''])
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              pct,
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Área de barras
                  Expanded(
                    child: Stack(
                      children: [
                        // Linhas de grade horizontais
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (int i = 0; i < 5; i++)
                                Divider(
                                  height: 1,
                                  color: AppColors.dark.withValues(alpha: 0.07),
                                ),
                            ],
                          ),
                        ),
                        // Barras
                        Positioned.fill(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (int i = 0; i < barras.length; i++) ...[
                                Expanded(
                                  child: _BarraAnimada(dado: barras[i]),
                                ),
                                if (i < barras.length - 1)
                                  const SizedBox(width: 12),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Barra individual com animação de entrada (sobe do zero)
class _BarraAnimada extends StatefulWidget {
  const _BarraAnimada({required this.dado});

  final _BarraDado dado;

  @override
  State<_BarraAnimada> createState() => _BarraAnimadaState();
}

class _BarraAnimadaState extends State<_BarraAnimada>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant _BarraAnimada old) {
    super.didUpdateWidget(old);
    if (old.dado.valor != widget.dado.valor) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // maxHeight é a altura disponível para a barra + rótulo
      const textH = 42.0; // altura reservada para rótulo + gap
      final maxBarH = constraints.maxHeight - textH;

      return AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final barH = (maxBarH * widget.dado.valor * _anim.value).clamp(2.0, maxBarH);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Tooltip com percentual
              Text(
                '${(widget.dado.valor * 100).round()}%',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              // A barra propriamente dita
              Container(
                height: barH,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.green,
                      AppColors.green.withValues(alpha: 0.65),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.dado.rotulo,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GRÁFICO DE ROSQUINHA — distribuição de status das lixeiras
// ═══════════════════════════════════════════════════════════════════════════
class _GraficoRosquinhaCard extends StatelessWidget {
  const _GraficoRosquinhaCard({required this.titulo, required this.lixeiras});

  final String titulo;
  final List<LixeiraModel> lixeiras;

  @override
  Widget build(BuildContext context) {
    final contagens = <StatusLixeira, int>{};
    for (final l in lixeiras) {
      contagens[l.statusLixeira] = (contagens[l.statusLixeira] ?? 0) + 1;
    }

    final dados = [
      (status: StatusLixeira.vazia,   cor: AppColors.green.withValues(alpha: 0.3)),
      (status: StatusLixeira.baixa,   cor: AppColors.green.withValues(alpha: 0.55)),
      (status: StatusLixeira.media,   cor: AppColors.green),
      (status: StatusLixeira.alta,    cor: AppColors.orange),
      (status: StatusLixeira.cheia,   cor: Colors.redAccent),
    ].where((d) => (contagens[d.status] ?? 0) > 0).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Legenda
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Status das lixeiras',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 12),
                for (final d in dados) ...[
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: d.cor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          d.status.label,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.dark),
                        ),
                      ),
                      Text(
                        '${contagens[d.status] ?? 0}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Rosquinha
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _RosquinhaPainter(
                dados: [
                  for (final d in dados)
                    (
                      valor: (contagens[d.status] ?? 0).toDouble(),
                      cor: d.cor
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  '${lixeiras.length}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RosquinhaPainter extends CustomPainter {
  const _RosquinhaPainter({required this.dados});

  final List<({double valor, Color cor})> dados;

  @override
  void paint(Canvas canvas, Size size) {
    final total = dados.fold<double>(0, (s, d) => s + d.valor);
    if (total == 0) return;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2 - 6;
    final innerR = outerR * 0.6;

    double startAngle = -pi / 2;
    for (final d in dados) {
      final sweep = (d.valor / total) * 2 * pi;
      final paint = Paint()
        ..color = d.cor
        ..style = PaintingStyle.fill;

      final path = Path()
        ..arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: outerR),
          startAngle,
          sweep,
          true,
        )
        ..arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: innerR),
          startAngle + sweep,
          -sweep,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RosquinhaPainter old) => old.dados != dados;
}

// ═══════════════════════════════════════════════════════════════════════════
// RANKING DE COLETORES
// ═══════════════════════════════════════════════════════════════════════════
class _RankingColetoresCard extends StatelessWidget {
  const _RankingColetoresCard({required this.coletores});

  final List<ColetorModel> coletores;

  @override
  Widget build(BuildContext context) {
    final sorted = [...coletores]
      ..sort((a, b) => b.coletasRealizadas.compareTo(a.coletasRealizadas));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ranking da semana',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          for (int i = 0; i < sorted.length; i++) ...[
            _RankingItem(
              posicao: i + 1,
              nome: sorted[i].nome,
              coletas: sorted[i].coletasRealizadas,
              maxColetas: sorted.first.coletasRealizadas,
            ),
            if (i < sorted.length - 1)
              const Divider(height: 16, color: Color(0xFFEEEEEE)),
          ],
        ],
      ),
    );
  }
}

class _RankingItem extends StatelessWidget {
  const _RankingItem({
    required this.posicao,
    required this.nome,
    required this.coletas,
    required this.maxColetas,
  });

  final int posicao;
  final String nome;
  final int coletas;
  final int maxColetas;

  @override
  Widget build(BuildContext context) {
    final medalColors = [AppColors.orange, AppColors.textMuted, AppColors.dark];
    final medalColor = posicao <= 3 ? medalColors[posicao - 1] : AppColors.textMuted;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: medalColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$posicao',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: medalColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nome,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: coletas / maxColetas,
                backgroundColor: AppColors.dark.withValues(alpha: 0.07),
                color: AppColors.green,
                borderRadius: BorderRadius.circular(10),
                minHeight: 5,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$coletas',
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.dark),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CARD DE ATIVIDADES RECENTES (seção "Outras métricas")
// ═══════════════════════════════════════════════════════════════════════════
class _AtividadesCard extends StatelessWidget {
  const _AtividadesCard();

  static const _atividades = [
    (icon: Icons.check_circle_rounded, cor: AppColors.green, texto: 'Lixeira Central coletada', tempo: 'Há 2h'),
    (icon: Icons.warning_rounded, cor: AppColors.orange, texto: 'Lixeira Campus Norte: nível alto', tempo: 'Há 4h'),
    (icon: Icons.add_circle_rounded, cor: AppColors.dark, texto: 'Nova lixeira cadastrada', tempo: 'Há 1d'),
    (icon: Icons.recycling_rounded, cor: AppColors.green, texto: 'Coleta do Terminal concluída', tempo: 'Há 1d'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Atividades recentes',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          for (int i = 0; i < _atividades.length; i++) ...[
            Row(
              children: [
                Icon(_atividades[i].icon,
                    color: _atividades[i].cor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_atividades[i].texto,
                      style: const TextStyle(fontSize: 12.5)),
                ),
                Text(_atividades[i].tempo,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
            if (i < _atividades.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Container(
                    width: 1, height: 16,
                    color: const Color(0xFFEEEEEE)),
              ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INDICADOR GENÉRICO
// ═══════════════════════════════════════════════════════════════════════════
class _IndicadorCard extends StatelessWidget {
  const _IndicadorCard({
    required this.icon,
    required this.titulo,
    required this.valor,
    required this.detalhe,
    required this.cor,
  });

  final IconData icon;
  final String titulo;
  final String valor;
  final String detalhe;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(valor,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: AppColors.dark)),
                Text(detalhe,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            width: 6,
            height: 40,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
