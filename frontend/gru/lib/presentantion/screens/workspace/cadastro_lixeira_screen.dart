import 'package:flutter/material.dart';
import 'package:gru/providers/auth_provider.dart';
import 'package:gru/providers/lixeira_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/lixeira_model.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/repositories/lixeira_repository.dart';
import '../../../data/repositories/usuario_repository.dart';
import '../../widgets/aviso_modo_demo.dart';
import '../../widgets/workspace_header.dart';

class CadastroLixeiraScreen extends StatefulWidget {
  const CadastroLixeiraScreen({super.key});

  @override
  State<CadastroLixeiraScreen> createState() => _CadastroLixeiraScreenState();
}

class _CadastroLixeiraScreenState extends State<CadastroLixeiraScreen> with TickerProviderStateMixin {
  final _repository = LixeiraRepository();
  final _usuarioRepository = UsuarioRepository();
  final _cpfController = TextEditingController();
  final _cpfContratanteController = TextEditingController();
  final _nomeContratanteController = TextEditingController();
  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _coordenadaController = TextEditingController();
  final _buscaController = TextEditingController();

  List<LixeiraModel> _lixeiras = [];
  bool _carregando = false;
  bool _salvando = false;
  bool _pesquisando = false;

  // Controla se o formulário está expandido
  bool _formAberto = false;
  bool _formContratanteAberto = false;

  // Animação de rotação do botão +
  late final AnimationController _btnCtrl;
  late final Animation<double> _btnRotation;
  late final AnimationController _btnCtrlContratante;
  late final Animation<double> _btnRotationContratante;

  // Animação de entrada do card do formulário
  late final AnimationController _cardCtrl;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;

  // Animação de entrada escalonada da lista
  late final AnimationController _listaCtrl;

  @override
  void initState() {
    super.initState();

    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _btnRotation = Tween<double>(begin: 0, end: 0.125) // 45°
        .animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut));

    _btnCtrlContratante = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _btnRotationContratante = Tween<double>(begin: 0, end: 0.125) // 45°
        .animate(CurvedAnimation(parent: _btnCtrlContratante, curve: Curves.easeOut));

    _btnCtrl.reverse();
    _btnCtrlContratante.reverse();

    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _cardSlide = Tween<Offset>(begin: const Offset(-0.06, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardCtrl.forward();

    _listaCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregar(provider: context.read<LixeiraProvider>());
    });

  }

  @override
  void dispose() {
    _btnCtrl.dispose();
    _btnCtrlContratante.dispose();
    _cardCtrl.dispose();
    _listaCtrl.dispose();
    _cpfController.dispose();
    _cpfContratanteController.dispose();
    _nomeContratanteController.dispose();
    _nomeController.dispose();
    _enderecoController.dispose();
    _coordenadaController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar({String? termo, LixeiraProvider? provider}) async {
    setState(() => _carregando = true);
    _listaCtrl.reset();
    final lista = await provider!.buscarLixeiras(termoBusca: termo);
    if (!mounted) return;
    setState(() {
      _lixeiras = lista;
      _carregando = false;
    });
    _listaCtrl.forward();
  }

  Future<void> _cadastrarLixeira(LixeiraProvider providerRead, AuthProvider providerReadUsuario) async {
    if (bloquearNaDemo(context)) return;
    if (_nomeController.text.trim().isEmpty || _enderecoController.text.trim().isEmpty || _coordenadaController.text.trim().isEmpty || _cpfController.text.trim().isEmpty || _nomeContratanteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe todos os campos.')),
      );
      return;
    }

    setState(() => _salvando = true);
    _btnCtrl.forward();

    final resposta = await _repository.cadastrar(_cpfController.text.trim(), _nomeContratanteController.text.trim(), _nomeController.text.trim(), _enderecoController.text.trim(), _coordenadaController.text.trim(), providerReadUsuario.organizacao['_id']);

    if (resposta['_id'] != null && resposta['_id'].toString().isNotEmpty) {
      providerRead.adicionarLixeira(LixeiraModel(
        id: resposta['_id'],
        nomeLixeira: resposta['nome_lixeira'],
        codigoDonoLixeira: resposta['codigo_dono_lixeira'],
        enderecoLixeira: resposta['endereco_lixeira'],
        coordenada: resposta['coordenada'],
        quantidadeResiduo: resposta['quantidade_residuo'] ?? 0,
        statusLixeira: StatusLixeira.fromCodigo(resposta['status_lixeira']),
      ));

      _cpfController.clear();
      _nomeContratanteController.clear();
      _nomeController.clear();
      _enderecoController.clear();
      _coordenadaController.clear();

      if (!mounted) return;
      setState(() => _salvando = false);
      _btnCtrl.reverse();
      if (!mounted) return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: resposta['_id'] != null && resposta['_id'].toString().isNotEmpty ? [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Lixeira cadastrada com sucesso!'),
          ] : [
            Icon(Icons.error, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text(resposta['message']),
          ],
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _buscarContratante(LixeiraProvider providerRead, AuthProvider providerReadUsuario) async {
    if (bloquearNaDemo(context)) return;
    if (_cpfContratanteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o CPF do contratante.')),
      );
      return;
    }

    setState(() => _pesquisando = true);
    _btnCtrl.forward();

    final resposta = await _usuarioRepository.buscarUsuario(cpf: _cpfContratanteController.text.trim(), cargo: 'CONTRATANTE');

    if (resposta['_id'] != null && resposta['_id'].toString().isNotEmpty) {
      providerReadUsuario.definirContratante(UsuarioModel(
        id: resposta['_id'],
        nomeUsuario: resposta['nome_usuario'],
        emailUsuario: resposta['email_usuario'],
        telefoneUsuario: resposta['telefone_usuario'],
        cpfUsuario: resposta['cpf_usuario'],
        cargoUsuario: resposta['cargo_usuario'],
        instituicao: resposta['instituicao_usuario'],
        coletasRealizadas: resposta['coletas_realizadas'],
      ));

      if (!mounted) return;
      setState(() => _pesquisando = false);
      _btnCtrl.reverse();
      if (!mounted) return;

      providerRead.limparLixeiras();
      providerRead.definirLixeiras(await _repository.listar(codigoDonoLixeira: resposta['_id']));

      final respostaOrg = await _usuarioRepository.buscarOrganizacao(idContratante: resposta['_id']);

      if (respostaOrg != null) {
        providerReadUsuario.definirOrganizacao(respostaOrg);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: resposta['_id'] != null && resposta['_id'].toString().isNotEmpty ? [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Usuário encontrado: ${resposta['nome_usuario']}'),
          ] : [
            Icon(Icons.error, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Usuário não encontrado ou não é um contratante'),
          ],
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleForm() {
    setState(() => _formAberto = !_formAberto);
    if (_formAberto) {
      _btnCtrl.forward();
    } else {
      _btnCtrl.reverse();
    }
  }

  void _toggleFormContratante() {
    setState(() => _formContratanteAberto = !_formContratanteAberto);
    if (_formContratanteAberto) {
      _btnCtrlContratante.forward();
    } else {
      _btnCtrlContratante.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
  final providerWatch = context.watch<LixeiraProvider>();
  final providerRead = context.read<LixeiraProvider>();
  final providerReadUsuario = context.read<AuthProvider>();
  final providerWatchUsuario = context.watch<AuthProvider>();
  _lixeiras = providerWatch.lixeiras;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Fundo pontilhado ──────────────────────────────────────
            const Positioned.fill(child: _DotGridBackground()),

            // ── Arco laranja — canto inferior direito (CORRIGIDO) ────
            const Positioned(
              bottom: 0,
              right: 0,
              child: _CornerArc(
                color: AppColors.orange,
                radius: 120,
                corner: _Corner.bottomRight,
              ),
            ),

            // ── Arco verde — canto superior esquerdo (pequeno) ───────
            const Positioned(
              top: 0,
              left: 0,
              child: _CornerArc(
                color: AppColors.green,
                radius: 70,
                corner: _Corner.topLeft,
              ),
            ),

            // ── Conteúdo ──────────────────────────────────────────────
            PageContainer(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WorkspaceHeader(
                      title: 'Cadastro de Lixeiras',
                      accentColor: AppColors.orange,
                    ),
                    const SizedBox(height: 18),

                    // Mini KPIs
                    _MiniStatsRow(lixeiras: _lixeiras),
                    const SizedBox(height: 18),

                    FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: _cardSlide,
                        child: _BuscarContratanteCard(
                          cpfContratanteController: _cpfContratanteController,
                          pesquisando: _pesquisando,
                          abertoFormsContratante: _formContratanteAberto,
                          btnRotation: _btnRotationContratante,
                          onToggle: _toggleFormContratante,
                          onBuscarContratante: () => _buscarContratante(providerRead, providerReadUsuario),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: _cardSlide,
                        child: _CadastroCard(
                          cpfController: _cpfController,
                          nomeContratanteController: _nomeContratanteController,
                          nomeController: _nomeController,
                          enderecoController: _enderecoController,
                          coordenadaController: _coordenadaController,
                          salvando: _salvando,
                          aberto: _formAberto,
                          btnRotation: _btnRotation,
                          onToggle: _toggleForm,
                          onAdicionar: () => _cadastrarLixeira(providerRead, providerReadUsuario),
                          providerReadUsuario: providerReadUsuario,
                          providerWatchUsuario: providerWatchUsuario,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Card de pesquisa + lista animada
                    _PesquisarCard(
                      buscaController: _buscaController,
                      onBuscar: (t) => _carregar(termo: t, provider: providerWatch),
                      lixeiras: _lixeiras,
                      carregando: _carregando,
                      listaCtrl: _listaCtrl,
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

// ═══════════════════════════════════════════════════════════════════════════
// FUNDO PONTILHADO (reutilizado do Dashboard)
// ═══════════════════════════════════════════════════════════════════════════
class _DotGridBackground extends StatelessWidget {
  const _DotGridBackground();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _DotPainter(), size: Size.infinite);
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppColors.dark.withValues(alpha: 0.04);
    const step = 28.0;
    for (double x = step; x < size.width; x += step)
      for (double y = step; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.4, p);
      }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// ARCOS DE CANTO (substitui SVG quebrado)
// ═══════════════════════════════════════════════════════════════════════════
enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

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
  Widget build(BuildContext context) => SizedBox(
        width: radius,
        height: radius,
        child: CustomPaint(
            painter: _CornerArcPainter(color, radius, corner)),
      );
}

class _CornerArcPainter extends CustomPainter {
  const _CornerArcPainter(this.color, this.radius, this.corner);
  final Color color;
  final double radius;
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
          ..arcToPoint(Offset(w, h),
              radius: Radius.circular(w), clockwise: true)
          ..lineTo(0, h)
          ..close();
        break;
      case _Corner.topRight:
        path
          ..moveTo(w, 0)
          ..arcToPoint(Offset(0, h),
              radius: Radius.circular(w), clockwise: false)
          ..lineTo(w, h)
          ..close();
        break;
      case _Corner.bottomLeft:
        path
          ..moveTo(0, h)
          ..arcToPoint(Offset(w, 0),
              radius: Radius.circular(w), clockwise: false)
          ..lineTo(0, 0)
          ..close();
        break;
      case _Corner.bottomRight:
        path
          ..moveTo(w, h)
          ..arcToPoint(Offset(0, 0),
              radius: Radius.circular(w), clockwise: true)
          ..lineTo(w, 0)
          ..close();
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerArcPainter old) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// MINI STATS
// ═══════════════════════════════════════════════════════════════════════════
class _MiniStatsRow extends StatelessWidget {
  const _MiniStatsRow({required this.lixeiras});
  final List<LixeiraModel> lixeiras;


  @override
  Widget build(BuildContext context) {
    final total = lixeiras.length;
    final cheias = lixeiras.where((l) => l.statusLixeira == StatusLixeira.cheia).length;
    final livres = lixeiras.where((l) => l.statusLixeira == StatusLixeira.vazia || l.statusLixeira == StatusLixeira.baixa).length;

    return Row(
      children: [
        _MiniStat(
            valor: '$total',
            label: 'Total',
            cor: AppColors.dark,
            icon: Icons.delete_rounded),
        const SizedBox(width: 10),
        _MiniStat(
            valor: '$livres',
            label: 'Disponíveis',
            cor: AppColors.green,
            icon: Icons.check_circle_rounded),
        const SizedBox(width: 10),
        _MiniStat(
            valor: '$cheias',
            label: 'Cheias',
            cor: AppColors.orange,
            icon: Icons.warning_rounded),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
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
              child: Icon(icon, color: cor, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(valor,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                        height: 1)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _BuscarContratanteCard extends StatelessWidget {
  const _BuscarContratanteCard({
    required this.cpfContratanteController,
    required this.pesquisando,
    required this.abertoFormsContratante,
    required this.btnRotation,
    required this.onToggle,
    required this.onBuscarContratante,
  });

  final bool pesquisando;
  final bool abertoFormsContratante;
  final Animation<double> btnRotation;
  final VoidCallback onToggle;
  final VoidCallback onBuscarContratante;
  final TextEditingController cpfContratanteController;

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
              offset: const Offset(0, 6)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header clicável para expandir/colapsar
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            onTap: onToggle,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.dark,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Buscar por CPF do Contratante',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                  const Spacer(),
                  // Botão + que vira × ao expandir
                  RotationTransition(
                    turns: btnRotation,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Campos — AnimatedSize faz o collapse suave
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: abertoFormsContratante
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AnimatedField(
                          label: 'CPF do Contratante',
                          controller: cpfContratanteController,
                          icon: Icons.edit_rounded,
                          hint: 'Ex: 123.456.789-00',
                          activated: true,
                          delay: const Duration(milliseconds: 80),
                        ),

                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.centerRight,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pesquisando
                                    ? AppColors.orange.withValues(alpha: 0.6)
                                    : AppColors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: pesquisando ? 0 : 4,
                                shadowColor:
                                    AppColors.orange.withValues(alpha: 0.4),
                              ),
                              onPressed: pesquisando ? null : onBuscarContratante,
                              icon: pesquisando
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Icon(Icons.search,
                                      color: Colors.white, size: 18),
                              label: Text(
                                pesquisando ? 'Pesquisando...' : 'Buscar',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
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

// ═══════════════════════════════════════════════════════════════════════════
// CARD DE CADASTRO (expand/collapse animado + botão rotativo)
// ═══════════════════════════════════════════════════════════════════════════
class _CadastroCard extends StatelessWidget {
  const _CadastroCard({
    required this.cpfController,
    required this.nomeContratanteController,
    required this.nomeController,
    required this.enderecoController,
    required this.coordenadaController,
    required this.salvando,
    required this.aberto,
    required this.btnRotation,
    required this.onToggle,
    required this.onAdicionar,
    required this.providerReadUsuario,
    required this.providerWatchUsuario,
  });

  final TextEditingController cpfController;
  final TextEditingController nomeContratanteController;
  final TextEditingController nomeController;
  final TextEditingController enderecoController;
  final TextEditingController coordenadaController;
  final bool salvando;
  final bool aberto;
  final Animation<double> btnRotation;
  final VoidCallback onToggle;
  final VoidCallback onAdicionar;
  final AuthProvider providerReadUsuario;
  final AuthProvider providerWatchUsuario;

  @override
  Widget build(BuildContext context) {
    cpfController.text = providerReadUsuario.contratante?.cpfUsuario ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: AppColors.orange.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header clicável para expandir/colapsar
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            onTap: onToggle,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.dark,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    providerWatchUsuario.contratante != null ? 'Cadastrar nova Lixeira para ${providerWatchUsuario.contratante!.instituicao}' : 'Cadastrar nova Lixeira',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                  const Spacer(),
                  // Botão + que vira × ao expandir
                  RotationTransition(
                    turns: btnRotation,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Campos — AnimatedSize faz o collapse suave
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: aberto
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AnimatedField(
                          label: 'CPF do Contratante',
                          controller: cpfController,
                          icon: Icons.edit_rounded,
                          hint: 'Ex: 123.456.789-00',
                          activated: false, // Desativado, pois o CPF já foi buscado
                          delay: const Duration(milliseconds: 80),
                        ),
                        const SizedBox(height: 20),
                        _AnimatedField(
                          label: 'Nome da Instituição',
                          controller: nomeContratanteController,
                          icon: Icons.edit_rounded,
                          hint: 'Ex: EcoVida',
                          activated: true,
                          delay: const Duration(milliseconds: 80),
                        ),
                        const SizedBox(height: 20),
                        _AnimatedField(
                          label: 'Nome da Lixeira',
                          controller: nomeController,
                          icon: Icons.edit_rounded,
                          hint: 'Ex: Lixeira Praça Central',
                          activated: true,
                          delay: const Duration(milliseconds: 80),
                        ),
                        const SizedBox(height: 20),
                        _AnimatedField(
                          label: 'Endereço da Lixeira',
                          controller: enderecoController,
                          icon: Icons.edit_rounded,
                          hint: 'Ex: Av. Francisco Pignatari, 650 - Vila Gustavo Correia, Carapicuíba - SP, 06310-390',
                          activated: true,
                          delay: const Duration(milliseconds: 80),
                        ),
                        const SizedBox(height: 20),
                        _AnimatedField(
                          label: 'Coordenadas da Lixeira',
                          controller: coordenadaController,
                          icon: Icons.edit_rounded,
                          hint: 'Ex: 23.5489, -46.6388',
                          activated: true,
                          delay: const Duration(milliseconds: 80),
                        ),
                        const SizedBox(height: 20),
                        // Botão de envio
                        Align(
                          alignment: Alignment.centerRight,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: salvando
                                    ? AppColors.orange.withValues(alpha: 0.6)
                                    : AppColors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: salvando ? 0 : 4,
                                shadowColor:
                                    AppColors.orange.withValues(alpha: 0.4),
                              ),
                              onPressed: salvando ? null : onAdicionar,
                              icon: salvando
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Icon(Icons.add_rounded,
                                      color: Colors.white, size: 18),
                              label: Text(
                                salvando ? 'Cadastrando...' : 'Adicionar',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
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

// Campo de texto com animação de entrada
class _AnimatedField extends StatefulWidget {
  const _AnimatedField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    required this.delay,
    required this.activated,
  });
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final Duration delay;
  final bool activated;

  @override
  State<_AnimatedField> createState() => _AnimatedFieldState();
}

class _AnimatedFieldState extends State<_AnimatedField> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  bool _focado = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
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
                Icon(widget.icon,
                    size: 14,
                    color: _focado ? AppColors.orange : AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _focado ? AppColors.orange : AppColors.dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Focus(
              onFocusChange: (f) => setState(() => _focado = f),
              child: TextField(
                enabled: widget.activated,
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                  isDense: true,
                  filled: true,
                  fillColor: _focado
                      ? AppColors.orange.withValues(alpha: 0.04)
                      : const Color(0xFFF7F9FC),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: AppColors.dark.withValues(alpha: 0.2),
                        width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: AppColors.dark.withValues(alpha: 0.2),
                        width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.orange, width: 1.8),
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

// ═══════════════════════════════════════════════════════════════════════════
// CARD DE PESQUISA + LISTA ANIMADA
// ═══════════════════════════════════════════════════════════════════════════
class _PesquisarCard extends StatelessWidget {
  const _PesquisarCard({
    required this.buscaController,
    required this.lixeiras,
    required this.carregando,
    required this.listaCtrl,
    required this.onBuscar,
  });

  final TextEditingController buscaController;
  final List<LixeiraModel> lixeiras;
  final bool carregando;
  final AnimationController listaCtrl;
  final ValueChanged<String> onBuscar;

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
              offset: const Offset(0, 6)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header da pesquisa
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.dark,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.search_rounded,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Pesquisar Lixeira',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15),
                ),
                // const Spacer(),
                // SizedBox(
                //   width: 160,
                //   height: 34,
                //   child: TextField(
                //     controller: buscaController,
                //     onSubmitted: onBuscar,
                //     onChanged: (v) {
                //       if (v.isEmpty) onBuscar('');
                //     },
                //     style:
                //         const TextStyle(color: Colors.white, fontSize: 13),
                //     decoration: InputDecoration(
                //       hintText: 'Buscar...',
                //       hintStyle: const TextStyle(color: Colors.white54),
                //       prefixIcon: const Icon(Icons.search_rounded,
                //           color: Colors.white54, size: 16),
                //       isDense: true,
                //       filled: true,
                //       fillColor: Colors.white.withValues(alpha: 0.12),
                //       contentPadding:
                //           const EdgeInsets.symmetric(vertical: 6),
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

          // Lista
          if (carregando)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.orange),
              ),
            )
          else if (lixeiras.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 40,
                      color: AppColors.dark.withValues(alpha: 0.2)),
                  const SizedBox(height: 10),
                  const Text('Nenhuma lixeira encontrada.',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: lixeiras.length,
              separatorBuilder: (_, _) => Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: Color.fromARGB(255, 235, 235, 235)),
              itemBuilder: (context, index) {
                // Cada item entra com um delay escalonado
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
                      begin: Offset(0.08, 0), end: Offset.zero
                    ).animate(itemAnim),
                    child: _LixeiraItem(lixeira: lixeiras[index]),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Item individual da lista
class _LixeiraItem extends StatefulWidget {
  const _LixeiraItem({required this.lixeira});
  final LixeiraModel lixeira;

  @override
  State<_LixeiraItem> createState() => _LixeiraItemState();
}

class _LixeiraItemState extends State<_LixeiraItem> {
  bool _hovered = false;

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
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Ícone com cor conforme o status
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _statusColor(widget.lixeira.statusLixeira)
                    .withValues(alpha: _hovered ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_rounded,
                color: _statusColor(widget.lixeira.statusLixeira),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lixeira.nomeLixeira,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _hovered ? AppColors.orange : AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.lixeira.enderecoLixeira.isNotEmpty == true
                        ? widget.lixeira.enderecoLixeira
                        : 'Sem endereço cadastrado',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _StatusBadge(status: widget.lixeira.statusLixeira),
          ],
        ),
      ),
    );
  }

  Color _statusColor(StatusLixeira s) {
    switch (s) {
      case StatusLixeira.vazia:
        return AppColors.textMuted;
      case StatusLixeira.baixa:
        return AppColors.green;
      case StatusLixeira.media:
        return const Color(0xFF27AE60);
      case StatusLixeira.alta:
        return AppColors.orange;
      case StatusLixeira.cheia:
        return Colors.redAccent;
    }
  }
}

// Badge de status com cor semântica
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final StatusLixeira status;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      StatusLixeira.vazia  => (AppColors.textMuted, AppColors.textMuted.withValues(alpha: 0.1)),
      StatusLixeira.baixa  => (const Color(0xFF27AE60), AppColors.green.withValues(alpha: 0.1)),
      StatusLixeira.media  => (AppColors.greenDark, AppColors.green.withValues(alpha: 0.15)),
      StatusLixeira.alta   => (AppColors.orange, AppColors.orange.withValues(alpha: 0.12)),
      StatusLixeira.cheia  => (Colors.redAccent, Colors.red.withValues(alpha: 0.1)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
