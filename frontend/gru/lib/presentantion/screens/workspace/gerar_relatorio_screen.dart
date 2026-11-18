import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/relatorio_model.dart';
import '../../../data/services/demo_data.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/relatorio_pdf.dart';
import '../../../data/services/relatorio_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/lixeira_provider.dart';
import '../../widgets/animated_svg_wave.dart';
import '../../widgets/workspace_header.dart';

/// Tela "Gerar Relatório" - reúne as duas telas do design (lista de
/// relatórios e preview) em um único widget com estado, trocando entre
/// os dois momentos conforme o usuário escolhe um relatório.
class GerarRelatorioScreen extends StatefulWidget {
  const GerarRelatorioScreen({super.key});

  @override
  State<GerarRelatorioScreen> createState() => _GerarRelatorioScreenState();
}

class _GerarRelatorioScreenState extends State<GerarRelatorioScreen> {
  RelatorioOpcao? _selecionado;
  RelatorioDados? _dados;
  bool _carregando = false;
  bool _gerando = false;
  String? _erro;

  List<dynamic> _history(dynamic org) {
    if (org is Map && org['history'] is List) {
      return List<dynamic>.from(org['history'] as List);
    }
    return const [];
  }

  Future<void> _abrir(RelatorioOpcao opcao) async {
    setState(() {
      _selecionado = opcao;
      _dados = null;
      _erro = null;
      _carregando = true;
    });

    final auth = context.read<AuthProvider>();
    final lixeiras = context.read<LixeiraProvider>().lixeiras;
    final instituicao = (auth.usuario?.instituicao?.trim().isNotEmpty ?? false)
        ? auth.usuario!.instituicao!.trim()
        : 'Minha instituição';
    final history = _history(auth.organizacao);

    try {
      final RelatorioDados dados;
      switch (opcao.id) {
        case 'tipos_residuo':
          final residuos = auth.modoDemo
              ? DemoData.residuos()
              : await RelatorioService.buscarResiduos();
          dados = RelatorioService.tiposResiduo(
              instituicao: instituicao, lixeiras: lixeiras, residuos: residuos);
        case 'ocupacao':
          dados = RelatorioService.ocupacao(
              instituicao: instituicao, lixeiras: lixeiras, history: history);
        default:
          dados = RelatorioService.utilizacao(
              instituicao: instituicao, lixeiras: lixeiras, history: history);
      }
      if (!mounted || _selecionado?.id != opcao.id) return;
      setState(() {
        _dados = dados;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted || _selecionado?.id != opcao.id) return;
      setState(() {
        _erro = 'Não foi possível carregar os dados agora.';
        _carregando = false;
      });
    }
  }

  void _voltarParaLista() => setState(() {
        _selecionado = null;
        _dados = null;
        _erro = null;
      });

  Future<void> _gerarRelatorio() async {
    final dados = _dados;
    if (dados == null) return;
    setState(() => _gerando = true);
    try {
      await RelatorioPdf.baixar(dados);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.green,
          content: Text('Relatório "${dados.titulo}" gerado! O PDF foi baixado.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade600,
          content: const Text('Não foi possível gerar o PDF.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _gerando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: -10,
              right: 0,
              child: AnimatedSvgWave(
                assetPath: AppWaves.cornerOrange,
                width: 240,
                height: 90,
                fit: BoxFit.fill,
                amplitude: 7,
                period: const Duration(seconds: 5),
              ),
            ),
            PageContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WorkspaceHeader(
                    title: 'Gerar Relatórios',
                    accentColor: AppColors.orange,
                    onBack: _selecionado == null ? null : _voltarParaLista,
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: _selecionado == null
                        ? _ListaRelatorios(
                            onSelecionar: _abrir,
                          )
                        : _PreviewRelatorio(
                            opcao: _selecionado!,
                            dados: _dados,
                            carregando: _carregando,
                            erro: _erro,
                            gerando: _gerando,
                            onGerar: _gerarRelatorio,
                            onTentarDeNovo: () => _abrir(_selecionado!),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaRelatorios extends StatelessWidget {
  const _ListaRelatorios({required this.onSelecionar});

  final ValueChanged<RelatorioOpcao> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange, width: 1.4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            color: AppColors.orange,
            child: const Text(
              'Escolher relatório',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: MockDataService.relatorios.length - 1,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.placeholder),
              itemBuilder: (context, index) {
                final opcao = MockDataService.relatorios[index];

                return ListTile(
                  leading: Icon(opcao.icone, color: AppColors.orange),
                  title: Text(
                    opcao.titulo,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    opcao.descricao,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.orange,
                  ),
                  onTap: () => onSelecionar(opcao),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewRelatorio extends StatelessWidget {
  const _PreviewRelatorio({
    required this.opcao,
    required this.dados,
    required this.carregando,
    required this.erro,
    required this.gerando,
    required this.onGerar,
    required this.onTentarDeNovo,
  });

  final RelatorioOpcao opcao;
  final RelatorioDados? dados;
  final bool carregando;
  final String? erro;
  final bool gerando;
  final VoidCallback onGerar;
  final VoidCallback onTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final pronto = dados != null && !carregando;

    Widget corpo;
    if (carregando) {
      corpo = const Center(child: CircularProgressIndicator());
    } else if (erro != null) {
      corpo = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.orange),
            const SizedBox(height: 10),
            Text(erro!, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.orange,
                  side: const BorderSide(color: AppColors.orange)),
              onPressed: onTentarDeNovo,
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      );
    } else {
      corpo = _ConteudoRelatorio(dados: dados!);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange, width: 1.4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            color: AppColors.orange,
            child: Row(
              children: [
                Icon(opcao.icone, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  opcao.titulo,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.orange),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: corpo,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: (!pronto || gerando) ? null : onGerar,
                      icon: gerando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.picture_as_pdf_rounded, size: 20),
                      label: const Text('Gerar Relatório'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Conteúdo do relatório na tela: resumo, barras, tabela e eventos.
class _ConteudoRelatorio extends StatelessWidget {
  const _ConteudoRelatorio({required this.dados});

  final RelatorioDados dados;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${dados.instituicao}  •  gerado em ${RelatorioPdf.formatarData(dados.geradoEm)}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            if (dados.resumo.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final r in dados.resumo) _ResumoChip(item: r),
                ],
              ),
            if (dados.aviso != null) ...[
              const SizedBox(height: 22),
              Center(
                child: Text(dados.aviso!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted)),
              ),
            ],
            if (dados.barras.isNotEmpty && !dados.vazio) ...[
              const SizedBox(height: 22),
              Text(dados.tituloBarras,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 10),
              for (final b in dados.barras) _LinhaBarra(barra: b),
            ],
            if (!dados.vazio) ...[
              const SizedBox(height: 22),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(
                      AppColors.orange.withValues(alpha: 0.12)),
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.dark),
                  columns: [
                    for (final c in dados.colunas) DataColumn(label: Text(c)),
                  ],
                  rows: [
                    for (final linha in dados.linhas)
                      DataRow(cells: [
                        for (final c in linha) DataCell(Text(c)),
                      ]),
                  ],
                ),
              ),
            ],
            if (dados.eventos.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(dados.tituloEventos,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 8),
              for (final e in dados.eventos)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.change_circle_outlined,
                          size: 16, color: AppColors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(e.texto,
                              style: const TextStyle(fontSize: 13))),
                      const SizedBox(width: 8),
                      Text(e.quando,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResumoChip extends StatelessWidget {
  const _ResumoChip({required this.item});

  final RelatorioResumoItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item.rotulo,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(item.valor,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark)),
        ],
      ),
    );
  }
}

class _LinhaBarra extends StatelessWidget {
  const _LinhaBarra({required this.barra});

  final RelatorioBarra barra;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(barra.rotulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5)),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, box) {
              return Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.placeholder.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: barra.fracao.clamp(0.0, 1.0).toDouble()),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Container(
                      height: 10,
                      width: box.maxWidth * v,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 44,
            child: Text(barra.valor,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
