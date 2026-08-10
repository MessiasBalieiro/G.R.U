import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/coletor_model.dart';
import '../../../data/models/lixeira_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../widgets/wave_shapes.dart';
import '../../widgets/workspace_header.dart';

/// As três seções navegáveis do Dashboard, escolhidas na barra lateral.
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: CornerBlob(
                color: AppColors.green,
                size: const Size(220, 100),
                corner: WaveCorner.topRight,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CornerBlob(
                color: AppColors.orange,
                size: const Size(220, 100),
                corner: WaveCorner.bottomRight,
              ),
            ),
            PageContainer(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                final sidebar = _DashboardSidebar(
                  isMobile: isMobile,
                  secaoAtual: _secao,
                  onSelecionar: (s) => setState(() => _secao = s),
                );
                final conteudo = SingleChildScrollView(
                  child: _DashboardConteudo(
                    secao: _secao,
                    lixeiras: lixeiras,
                  ),
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
                        const SizedBox(height: 24),
                        sidebar,
                        const SizedBox(height: 24),
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
                    const SizedBox(height: 24),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 210, child: sidebar),
                          const SizedBox(width: 24),
                          Expanded(child: conteudo),
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
      subtitulo: 'Indicadores gerais do sistema',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final itens = [
      for (final i in _itens)
        _SidebarItem(
          icon: i.icon,
          titulo: i.titulo,
          subtitulo: i.subtitulo,
          selecionado: secaoAtual == i.secao,
          onTap: () => onSelecionar(i.secao),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: isMobile
          ? Row(
              children: [
                for (final item in itens) ...[
                  Expanded(child: item),
                ],
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in itens) ...[
                  item,
                  if (item != itens.last) const SizedBox(height: 10),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selecionado ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selecionado
                ? Border.all(color: AppColors.green, width: 1.4)
                : null,
            boxShadow: selecionado
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: selecionado
                      ? AppColors.greenDark
                      : AppColors.dark.withValues(alpha: 0.6),
                  size: 22),
              const SizedBox(height: 6),
              Text(
                titulo,
                style: TextStyle(
                  color: AppColors.dark,
                  fontWeight: selecionado ? FontWeight.w800 : FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


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
              barras: [
                for (final l in lixeiras)
                  _BarraDado(
                    valor: (l.statusLixeira.codigo + 1) / 5,
                    rotulo: l.nome.split(' ').last,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _IndicadorCard(
              icon: Icons.delete_outline_rounded,
              titulo: 'Lixeiras cadastradas',
              valor: '${lixeiras.length} lixeiras',
            ),
          ],
        );

      case _DashboardSecao.coletores:
        final coletores = MockDataService.coletores;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GraficoBarrasCard(
              titulo: 'Coletas por coletor (semana)',
              barras: [
                for (final c in coletores)
                  _BarraDado(
                    valor: c.coletasRealizadas /
                        (coletores.map((e) => e.coletasRealizadas).reduce(
                                (a, b) => a > b ? a : b) *
                            1.0),
                    rotulo: c.nome.split(' ').first,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _IndicadorCard(
              icon: Icons.local_shipping_outlined,
              titulo: 'Coletas realizadas na semana',
              valor:
                  '${coletores.fold<int>(0, (t, c) => t + c.coletasRealizadas)} coletas',
            ),
          ],
        );

      case _DashboardSecao.outras:
        final ocupacaoMedia = lixeiras.isEmpty
            ? 0
            : (lixeiras
                        .map((l) => l.statusLixeira.codigo + 1)
                        .reduce((a, b) => a + b) /
                    lixeiras.length /
                    5 *
                    100)
                .round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _IndicadorCard(
              icon: Icons.percent_rounded,
              titulo: 'Ocupação média das lixeiras',
              valor: '$ocupacaoMedia%',
            ),
            const SizedBox(height: 16),
            _IndicadorCard(
              icon: Icons.groups_outlined,
              titulo: 'Coletores ativos',
              valor: '${MockDataService.coletores.length} pessoas',
            ),
            const SizedBox(height: 16),
            _IndicadorCard(
              icon: Icons.location_city_outlined,
              titulo: 'Instituições atendidas',
              valor:
                  '${lixeiras.map((l) => l.codigoDonoLixeira).toSet().length} instituições',
            ),
          ],
        );
    }
  }
}

class _BarraDado {
  const _BarraDado({required this.valor, required this.rotulo});
  final double valor;
  final String rotulo;
}

class _GraficoBarrasCard extends StatelessWidget {
  const _GraficoBarrasCard({required this.titulo, required this.barras});

  final String titulo;
  final List<_BarraDado> barras;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.dark, width: 1.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          if (barras.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Sem dados ainda.')),
            )
          else
            SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final b in barras) ...[
                    Expanded(child: _BarraOcupacao(dado: b)),
                    if (b != barras.last) const SizedBox(width: 14),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BarraOcupacao extends StatelessWidget {
  const _BarraOcupacao({required this.dado});

  final _BarraDado dado;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxH = constraints.maxHeight - 22;
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: (maxH * dado.valor).clamp(6, maxH).toDouble(),
            decoration: const BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ),
          const SizedBox(height: 8),
          Text(dado.rotulo,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      );
    });
  }
}

class _IndicadorCard extends StatelessWidget {
  const _IndicadorCard({
    required this.icon,
    required this.titulo,
    required this.valor,
  });

  final IconData icon;
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 96,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.dark, width: 1.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.orange, size: 26),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.5)),
                const SizedBox(height: 6),
                Text(valor,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
