
import 'package:flutter/material.dart';
import 'package:gru/data/models/usuario_model.dart';
import 'package:gru/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/repositories/usuario_repository.dart';
import '../../widgets/workspace_header.dart';

class CadastroColetorScreen extends StatefulWidget  {
  const CadastroColetorScreen({super.key});

  @override
  State<CadastroColetorScreen> createState() =>
      _CadastroColetorScreenState();
}

class _CadastroColetorScreenState extends State<CadastroColetorScreen> with TickerProviderStateMixin {
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _buscaController = TextEditingController();
  final _usuarioRepository = UsuarioRepository();

  // List<_Coletor> get _coletoresFiltrados {
  //   final termo = _buscaController.text.trim().toLowerCase();

  //   if (termo.isEmpty) return _coletores;

  //   return _coletores.where((coletor) {
  //     return coletor.nome.toLowerCase().contains(termo);
  //   }).toList();
  // }

  List<UsuarioModel> _coletoresReal = [];
  bool _formAberto = false;
  bool _salvando = false;
  String _idcoletor = '';

  late final AnimationController _btnCtrl;
  late final Animation<double> _btnRotation;

  late final AnimationController _cardCtrl;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;

  late final AnimationController _listaCtrl;

  @override
  void initState() {
    super.initState();

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _btnRotation = Tween<double>(
      begin: 0,
      end: 0.125,
    ).animate(
      CurvedAnimation(
        parent: _btnCtrl,
        curve: Curves.easeOut,
      ),
    );

    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _cardSlide = Tween<Offset>(
      begin: const Offset(-0.06, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cardCtrl,
        curve: Curves.easeOut,
      ),
    );

    _cardFade = CurvedAnimation(
      parent: _cardCtrl,
      curve: Curves.easeOut,
    );

    _listaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _cardCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregar(provider: context.read<AuthProvider>());
    });
  }

  @override
  void dispose() {
    _btnCtrl.dispose();
    _cardCtrl.dispose();
    _listaCtrl.dispose();

    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _buscaController.dispose();

    super.dispose();
  }

  void _toggleForm() {
    setState(() => _formAberto = !_formAberto);

    if (_formAberto) {
      _btnCtrl.forward();
    } else {
      _btnCtrl.reverse();
    }
  }

  
  Future<void> _carregar({String? termo, AuthProvider? provider}) async {
    _listaCtrl.reset();
    final lista = await provider!.buscarColetores(termoBusca: termo);
    if (!mounted) return;
    setState(() {
      _coletoresReal = lista;
    });
    _listaCtrl.forward();
  }

  Future<void> _adicionarColetor(AuthProvider providerWatchUsuario, AuthProvider providerReadUsuario) async {
    if (_cpfController.text.trim().isEmpty || _nomeController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _telefoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesquise um coletor antes de adicioná-lo.'),
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final resposta = await _usuarioRepository.adicionarColetorParaOrganizacao(cpf: _cpfController.text.trim(), idOrg: providerWatchUsuario.organizacao['_id']);

      providerReadUsuario.adicionarColetor(UsuarioModel(id: _idcoletor, nomeUsuario: _nomeController.text.trim(), emailUsuario: _emailController.text.trim(), telefoneUsuario: _telefoneController.text.trim(), cpfUsuario: _cpfController.text.trim(), cargoUsuario: "COLETOR", instituicao: "", coletasRealizadas: 0));

      if (resposta.toString().isNotEmpty) {

        _nomeController.clear();
        _emailController.clear();
        _telefoneController.clear();
        _cpfController.clear();

        setState(() => _idcoletor = '');

        if (!mounted) return;
        _btnCtrl.reverse();
        if (!mounted) return;
      }

      _listaCtrl.forward(from: 0);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coletor adicionado com sucesso!'),
          backgroundColor: AppColors.green,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  Future<void> _pesquisarColetor() async {
    if (_cpfController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o CPF do coletor para pesquisar.'),
        ),
      );
      return;
    }

    try {
      final resposta = await _usuarioRepository.buscarUsuario(cpf: _cpfController.text.trim(), cargo: 'COLETOR');

      _nomeController.text = resposta['nome_usuario'] ?? '';
      _telefoneController.text = resposta['telefone_usuario'] ?? '';
      _emailController.text = resposta['email_usuario'] ?? '';

      setState(() => _idcoletor = resposta['_id'] ?? '');
    }
    finally {

    }
  }

  Future<void> _excluirColetor(UsuarioModel coletor, AuthProvider providerWatchUsuario, AuthProvider providerReadUsuario) async {
    try {
      final resposta = await _usuarioRepository.removerColetorDaOrganizacao(
        cltCpf: coletor.cpfUsuario,
        idOrg: providerWatchUsuario.organizacao['_id'],
      );

      if (resposta.statusCode == 200) {
        providerReadUsuario.removerColetor(coletor);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coletor excluído.'),
          ),
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível remover o coletor.'),
          ),
        );
      }
    } 
    on StateError {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coletor não encontrado na lista.'),
        ),
      );
    } 
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao remover coletor.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerWatchUsuario = context.watch<AuthProvider>();
    final providerReadUsuario = context.read<AuthProvider>();
    _coletoresReal = providerWatchUsuario.coletores;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: _DotGridBackground(),
            ),

            const Positioned(
              bottom: 0,
              right: 0,
              child: _CornerArc(
                color: AppColors.orange,
                radius: 120,
                corner: _Corner.bottomRight,
              ),
            ),

            const Positioned(
              top: 0,
              left: 0,
              child: _CornerArc(
                color: AppColors.green,
                radius: 70,
                corner: _Corner.topLeft,
              ),
            ),

            PageContainer(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WorkspaceHeader(
                      title: 'Cadastro de Coletores',
                      accentColor: AppColors.orange,
                    ),

                    const SizedBox(height: 18),

                    _MiniStatsRow(
                      total: providerWatchUsuario.coletores.length,
                    ),

                    const SizedBox(height: 18),

                    FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: _cardSlide,
                        child: _CadastroColetorCard(
                          nomeController: _nomeController,
                          cpfController: _cpfController,
                          telefoneController: _telefoneController,
                          emailController: _emailController,
                          aberto: _formAberto,
                          salvando: _salvando,
                          btnRotation: _btnRotation,
                          onToggle: _toggleForm,
                          onAdicionar: () => _adicionarColetor(providerWatchUsuario, providerReadUsuario),
                          onPesquisar: _pesquisarColetor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    _PesquisarColetorCard(
                      buscaController: _buscaController,
                      coletores: _coletoresReal,
                      listaCtrl: _listaCtrl,
                      onExcluir: (coletor) => _excluirColetor(
                        coletor,
                        providerWatchUsuario,
                        providerReadUsuario,
                      ),
                      onBuscar: (t) => _carregar(termo: t, provider: providerWatchUsuario)
                    ),

                    const SizedBox(height: 120),
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

// MINI STATS

class _MiniStatsRow extends StatelessWidget {
  const _MiniStatsRow({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            valor: '$total',
            label: 'Total de Coletores',
            cor: AppColors.dark,
            icon: Icons.groups_rounded,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.valor,
    required this.label,
    required this.cor,
    required this.icon,
  });

  final String valor;
  final String label;
  final Color cor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: cor, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// CARD DE CADASTRO

class _CadastroColetorCard extends StatelessWidget {
  const _CadastroColetorCard({
    required this.nomeController,
    required this.cpfController,
    required this.telefoneController,
    required this.emailController,
    required this.aberto,
    required this.salvando,
    required this.btnRotation,
    required this.onToggle,
    required this.onAdicionar,
    required this.onPesquisar,
  });

  final TextEditingController nomeController;
  final TextEditingController cpfController;
  final TextEditingController telefoneController;
  final TextEditingController emailController;

  final bool aberto;
  final bool salvando;
  final Animation<double> btnRotation;

  final VoidCallback onToggle;
  final VoidCallback onAdicionar;
  final VoidCallback onPesquisar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(18),
            ),
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              decoration: const BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Cadastrar novo Coletor',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  RotationTransition(
                    turns: btnRotation,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: aberto
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ColetorField(
                          label: 'CPF',
                          controller: cpfController,
                          hint: 'Ex: 123.456.789-00',
                          icon: Icons.badge_outlined,
                          editable: true,
                        ),

                        const SizedBox(height: 20),

                        _ColetorField(
                          label: 'Nome completo',
                          controller: nomeController,
                          hint: '',
                          icon: Icons.person_outline,
                          editable: false,
                        ),

                        const SizedBox(height: 20),

                        _ColetorField(
                          label: 'Telefone',
                          controller: telefoneController,
                          hint: '',
                          icon: Icons.phone_outlined,
                          editable: false,
                        ),
                        const SizedBox(height: 20),

                        _ColetorField(
                          label: 'E-mail',
                          controller: emailController,
                          hint: '',
                          icon: Icons.email_outlined,
                          editable: false,
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Botão Pesquisar
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange, // Altere para a cor desejada
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              onPressed: onPesquisar,
                              icon: const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Pesquisar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Botão Adicionar
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: salvando ? 0 : 4,
                              ),
                              onPressed: salvando ? null : onAdicionar,
                              icon: salvando
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                salvando ? 'Adicionando...' : 'Adicionar',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// CAMPO ANIMADO

class _ColetorField extends StatefulWidget {
  const _ColetorField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.editable,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool editable;

  @override
  State<_ColetorField> createState() => _ColetorFieldState();
}

class _ColetorFieldState extends State<_ColetorField> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  bool _focado = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.icon,
                  size: 14,
                  color: _focado
                      ? AppColors.orange
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _focado
                        ? AppColors.orange
                        : AppColors.dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Focus(
              onFocusChange: (f) => setState(() => _focado = f),
              child: TextField(
                controller: widget.controller,
                enabled: widget.editable,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: _focado
                      ? AppColors.orange.withValues(alpha: 0.04)
                      : const Color(0xFFF7F9FC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.dark.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.dark.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.orange,
                      width: 1.8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CARD DE PESQUISA E LISTA

class _PesquisarColetorCard extends StatelessWidget {
  const _PesquisarColetorCard({
    required this.buscaController,
    required this.coletores,
    required this.listaCtrl,
    required this.onExcluir,
    required this.onBuscar,
  });

  final TextEditingController buscaController;
  final List<UsuarioModel> coletores;
  final AnimationController listaCtrl;
  final ValueChanged<String> onBuscar;
  final Function(UsuarioModel) onExcluir;

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            decoration: const BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Coletores',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                // const Spacer(),
                // SizedBox(
                //   width: 160,
                //   height: 34,
                //   child: TextField(
                //     controller: buscaController,
                //     onChanged: onBuscar,
                //     style: const TextStyle(
                //       color: Colors.white,
                //       fontSize: 13,
                //     ),
                //     decoration: InputDecoration(
                //       hintText: 'Buscar...',
                //       hintStyle: const TextStyle(
                //         color: Colors.white54,
                //       ),
                //       prefixIcon: const Icon(
                //         Icons.search_rounded,
                //         color: Colors.white54,
                //         size: 16,
                //       ),
                //       isDense: true,
                //       filled: true,
                //       fillColor: Colors.white.withValues(alpha: 0.12),
                //       contentPadding: const EdgeInsets.symmetric(
                //         vertical: 6,
                //       ),
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(20),
                //         borderSide: BorderSide.none,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          if (coletores.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 40,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nenhum coletor encontrado.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: coletores.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
                color: Color.fromARGB(255, 235, 235, 235),
              ),
              itemBuilder: (context, index) {
                final itemAnim = CurvedAnimation(
                  parent: listaCtrl,
                  curve: Interval(
                    (index * 0.15).clamp(0.0, 0.7),
                    ((index * 0.15) + 0.4).clamp(0.0, 1.0),
                    curve: Curves.easeOut,
                  ),
                );

                return FadeTransition(
                  opacity: itemAnim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(itemAnim),
                    child: _ColetorItem(
                      coletor: coletores[index],
                      onExcluir: () => onExcluir(coletores[index]),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ITEM DA LISTA

class _ColetorItem extends StatefulWidget {
  const _ColetorItem({
    required this.coletor,
    required this.onExcluir,
  });

  final UsuarioModel coletor;
  final VoidCallback onExcluir;

  @override
  State<_ColetorItem> createState() => _ColetorItemState();
}

class _ColetorItemState extends State<_ColetorItem> {
  bool _hovered = false;

  String _formatarData(DateTime? data) {
    if (data == null) return 'Nenhuma coleta realizada';

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year;

    return 'Última coleta: $dia/$mes/$ano';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        color: _hovered
            ? AppColors.orange.withValues(alpha: 0.04)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(
                  alpha: _hovered ? 0.2 : 0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.coletor.nomeUsuario,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _hovered
                          ? AppColors.orange
                          : AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatarData(null),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            TextButton.icon(
              onPressed: widget.onExcluir,
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 16,
              ),
              label: const Text(
                'Excluir',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FUNDO PONTILHADO

class _DotGridBackground extends StatelessWidget {
  const _DotGridBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotPainter(),
      size: Size.infinite,
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.dark.withValues(alpha: 0.04);

    const step = 28.0;

    for (double x = step; x < size.width; x += step) {
      for (double y = step; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.4, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ARCOS DECORATIVOS

enum _Corner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class _CornerArc extends StatelessWidget {
  const _CornerArc({
    required this.color,
    required this.radius,
    required this.corner,
  });

  final Color color;
  final double radius;
  final _Corner corner;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius,
      height: radius,
      child: CustomPaint(
        painter: _CornerArcPainter(color, corner),
      ),
    );
  }
}

class _CornerArcPainter extends CustomPainter {
  const _CornerArcPainter(this.color, this.corner);

  final Color color;
  final _Corner corner;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final w = size.width;
    final h = size.height;
    final path = Path();

    switch (corner) {
      case _Corner.topLeft:
        path
          ..moveTo(0, 0)
          ..arcToPoint(
            Offset(w, h),
            radius: Radius.circular(w),
            clockwise: true,
          )
          ..lineTo(0, h)
          ..close();
        break;

      case _Corner.topRight:
        path
          ..moveTo(w, 0)
          ..arcToPoint(
            Offset(0, h),
            radius: Radius.circular(w),
            clockwise: false,
          )
          ..lineTo(w, h)
          ..close();
        break;

      case _Corner.bottomLeft:
        path
          ..moveTo(0, h)
          ..arcToPoint(
            Offset(w, 0),
            radius: Radius.circular(w),
            clockwise: false,
          )
          ..lineTo(0, 0)
          ..close();
        break;

      case _Corner.bottomRight:
        path
          ..moveTo(w, h)
          ..arcToPoint(
            Offset(0, 0),
            radius: Radius.circular(w),
            clockwise: true,
          )
          ..lineTo(w, 0)
          ..close();
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerArcPainter oldDelegate) => false;
}