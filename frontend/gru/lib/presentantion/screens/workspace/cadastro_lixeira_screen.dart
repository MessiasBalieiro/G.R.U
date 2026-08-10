import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/lixeira_model.dart';
import '../../../data/repositories/lixeira_repository.dart';
import '../../widgets/wave_shapes.dart';
import '../../widgets/workspace_header.dart';

class CadastroLixeiraScreen extends StatefulWidget {
  const CadastroLixeiraScreen({super.key});

  @override
  State<CadastroLixeiraScreen> createState() => _CadastroLixeiraScreenState();
}

class _CadastroLixeiraScreenState extends State<CadastroLixeiraScreen> {
  final _repository = LixeiraRepository();
  final _idController = TextEditingController();
  final _nomeController = TextEditingController();
  final _infoController = TextEditingController();
  final _buscaController = TextEditingController();

  List<LixeiraModel> _lixeiras = [];
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _idController.dispose();
    _nomeController.dispose();
    _infoController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar({String? termo}) async {
    setState(() => _carregando = true);
    final lista = await _repository.listar(termoBusca: termo);
    if (!mounted) return;
    setState(() {
      _lixeiras = lista;
      _carregando = false;
    });
  }

  Future<void> _cadastrarLixeira() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe ao menos o nome da lixeira.')),
      );
      return;
    }

    setState(() => _salvando = true);
    await _repository.cadastrar(LixeiraModel(
      id: _idController.text.trim().isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : _idController.text.trim(),
      nome: _nomeController.text.trim(),
      codigoDonoLixeira: 'INST-000',
      enderecoLixeira: '-',
      coordenada: '-',
      statusLixeira: StatusLixeira.vazia,
      outrasInformacoes: _infoController.text.trim(),
    ));

    _idController.clear();
    _nomeController.clear();
    _infoController.clear();
    if (!mounted) return;
    setState(() => _salvando = false);
    await _carregar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lixeira cadastrada com sucesso!')),
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
                color: AppColors.dark,
                height: 80,
                corner: WaveCorner.bottomRight,
              ),
            ),
            PageContainer(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WorkspaceHeader(
                      title: 'Cadastro de Lixeiras Inteligentes',
                    ),
                    const SizedBox(height: 22),
                    _CadastrarNovaLixeiraCard(
                      idController: _idController,
                      nomeController: _nomeController,
                      infoController: _infoController,
                      salvando: _salvando,
                      onAdicionar: _cadastrarLixeira,
                    ),
                    const SizedBox(height: 20),
                    _PesquisarLixeiraCard(
                      buscaController: _buscaController,
                      onBuscar: (termo) => _carregar(termo: termo),
                      lixeiras: _lixeiras,
                      carregando: _carregando,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CadastrarNovaLixeiraCard extends StatelessWidget {
  const _CadastrarNovaLixeiraCard({
    required this.idController,
    required this.nomeController,
    required this.infoController,
    required this.salvando,
    required this.onAdicionar,
  });

  final TextEditingController idController;
  final TextEditingController nomeController;
  final TextEditingController infoController;
  final bool salvando;
  final VoidCallback onAdicionar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.placeholder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Text(
              'Cadastrar nova Lixeira',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FieldRow(label: 'ID Lixeira:', controller: idController),
                const SizedBox(height: 12),
                _FieldRow(label: 'Nome Lixeira:', controller: nomeController),
                const SizedBox(height: 12),
                _FieldRow(
                    label: 'Outras informações', controller: infoController),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FloatingActionButton.small(
                    heroTag: 'add_lixeira',
                    backgroundColor: AppColors.orange,
                    onPressed: salvando ? null : onAdicionar,
                    child: salvando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.add, color: Colors.white),
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

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.dark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5)),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.dark, width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.dark, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.orange, width: 1.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PesquisarLixeiraCard extends StatelessWidget {
  const _PesquisarLixeiraCard({
    required this.buscaController,
    required this.onBuscar,
    required this.lixeiras,
    required this.carregando,
  });

  final TextEditingController buscaController;
  final ValueChanged<String> onBuscar;
  final List<LixeiraModel> lixeiras;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.placeholder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text(
                  'Pesquisar Lixeira',
                  style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.search, color: Colors.white70, size: 18),
                const Spacer(),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: SizedBox(
                      height: 34,
                      child: TextField(
                        controller: buscaController,
                        onSubmitted: onBuscar,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white24,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (carregando)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (lixeiras.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Nenhuma lixeira encontrada.')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lixeiras.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.placeholder),
              itemBuilder: (context, index) {
                final l = lixeiras[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.orange),
                  ),
                  title: Text(l.nome,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    l.outrasInformacoes?.isNotEmpty == true
                        ? l.outrasInformacoes!
                        : 'ID: ${l.id}',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  trailing: _StatusBadge(status: l.statusLixeira),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final StatusLixeira status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
            color: AppColors.greenDark,
            fontSize: 11,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
