import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/relatorio_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../widgets/wave_shapes.dart';
import '../../widgets/workspace_header.dart';

class GerarRelatorioScreen extends StatefulWidget {
  const GerarRelatorioScreen({super.key});

  @override
  State<GerarRelatorioScreen> createState() => _GerarRelatorioScreenState();
}

class _GerarRelatorioScreenState extends State<GerarRelatorioScreen> {
  RelatorioOpcao? _selecionado;
  bool _gerando = false;

  Future<void> _gerarRelatorio() async {
    setState(() => _gerando = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _gerando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Relatório "${_selecionado!.titulo}" gerado!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CornerWave(
                color: AppColors.orange,
                height: 80,
                corner: WaveCorner.bottomRight,
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
                    onBack:
                        _selecionado == null ? null : () => setState(() => _selecionado = null),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: _selecionado == null
                        ? _ListaRelatorios(
                            onSelecionar: (opcao) =>
                                setState(() => _selecionado = opcao),
                          )
                        : _PreviewRelatorio(
                            opcao: _selecionado!,
                            gerando: _gerando,
                            onGerar: _gerarRelatorio,
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
              itemCount: MockDataService.relatorios.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.placeholder),
              itemBuilder: (context, index) {
                final opcao = MockDataService.relatorios[index];
                return ListTile(
                  leading: Icon(opcao.icone, color: AppColors.orange),
                  title: Text(opcao.titulo,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(opcao.descricao,
                      style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.orange),
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
    required this.gerando,
    required this.onGerar,
  });

  final RelatorioOpcao opcao;
  final bool gerando;
  final VoidCallback onGerar;

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
            child: Text(
              opcao.titulo,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(opcao.icone, size: 40, color: AppColors.orange),
                          const SizedBox(height: 10),
                          const Text(
                            'Preview do relatório',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: gerando ? null : onGerar,
                      child: gerando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Gerar Relatório'),
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
