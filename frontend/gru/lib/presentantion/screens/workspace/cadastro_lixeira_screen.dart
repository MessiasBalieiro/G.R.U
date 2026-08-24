import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/lixeira_model.dart';
import '../../../data/repositories/lixeira_repository.dart';
import '../../widgets/workspace_header.dart';

class CadastroLixeiraScreen extends StatefulWidget {
  const CadastroLixeiraScreen({super.key});

  @override
  State<CadastroLixeiraScreen> createState() => _CadastroLixeiraScreenState();
}

class _CadastroLixeiraScreenState extends State<CadastroLixeiraScreen>
    with TickerProviderStateMixin {
  final _repository = LixeiraRepository();
  final _idController = TextEditingController();
  final _nomeController = TextEditingController();
  final _infoController = TextEditingController();
  final _buscaController = TextEditingController();

  List<LixeiraModel> _lixeiras = [];
  bool _carregando = true;
  bool _salvando = false;

  // Controla se o formulário está expandido
  bool _formAberto = true;

  // Animação de rotação do botão +
  late final AnimationController _btnCtrl;
  late final Animation<double> _btnRotation;

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

    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _cardSlide = Tween<Offset>(begin: const Offset(-0.06, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardCtrl.forward();

    _listaCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _carregar();
  }

  @override
  void dispose() {
    _btnCtrl.dispose();
    _cardCtrl.dispose();
    _listaCtrl.dispose();
    _idController.dispose();
    _nomeController.dispose();
    _infoController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar({String? termo}) async {
    setState(() => _carregando = true);
    _listaCtrl.reset();
    final lista = await _repository.listar(termoBusca: termo);
    if (!mounted) return;
    setState(() {
      _lixeiras = lista;
      _carregando = false;
    });
    _listaCtrl.forward();
  }

  Future<void> _cadastrarLixeira() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe ao menos o nome da lixeira.')),
      );
      return;
    }
    setState(() => _salvando = true);
    _btnCtrl.forward();

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
    _btnCtrl.reverse();
    await _carregar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Lixeira cadastrada com sucesso!'),
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
      _btnCtrl.reverse();
    } else {
      _btnCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
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

                    // Card de cadastro com animação de entrada
                    FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: _cardSlide,
                        child: _CadastroCard(
                          idController: _idController,
                          nomeController: _nomeController,
                          infoController: _infoController,
                          salvando: _salvando,
                          aberto: _formAberto,
                          btnRotation: _btnRotation,
                          onToggle: _toggleForm,
                          onAdicionar: _cadastrarLixeira,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Card de pesquisa + lista animada
                    _PesquisarCard(
                      buscaController: _buscaController,
                      onBuscar: (t) => _carregar(termo: t),
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
      for (double y = step; y < size.height; y += step)
        canvas.drawCircle(Offset(x, y), 1.4, p);
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
    final cheias = lixeiras
        .where((l) => l.statusLixeira == StatusLixeira.cheia)
        .length;
    final livres = lixeiras
        .where((l) => l.statusLixeira == StatusLixeira.vazia ||
            l.statusLixeira == StatusLixeira.baixa)
        .length;

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

// ═══════════════════════════════════════════════════════════════════════════
// CARD DE CADASTRO (expand/collapse animado + botão rotativo)
// ═══════════════════════════════════════════════════════════════════════════
class _CadastroCard extends StatelessWidget {
  const _CadastroCard({
    required this.idController,
    required this.nomeController,
    required this.infoController,
    required this.salvando,
    required this.aberto,
    required this.btnRotation,
    required this.onToggle,
    required this.onAdicionar,
  });

  final TextEditingController idController;
  final TextEditingController nomeController;
  final TextEditingController infoController;
  final bool salvando;
  final bool aberto;
  final Animation<double> btnRotation;
  final VoidCallback onToggle;
  final VoidCallback onAdicionar;

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
                    'Cadastrar nova Lixeira',
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
                          label: 'ID Lixeira',
                          controller: idController,
                          icon: Icons.tag_rounded,
                          hint: 'Opcional — gerado automaticamente',
                          delay: const Duration(milliseconds: 0),
                        ),
                        const SizedBox(height: 14),
                        _AnimatedField(
                          label: 'Nome da Lixeira',
                          controller: nomeController,
                          icon: Icons.edit_rounded,
                          hint: 'Ex: Lixeira Praça Central',
                          delay: const Duration(milliseconds: 80),
                        ),
                        const SizedBox(height: 14),
                        _AnimatedField(
                          label: 'Outras informações',
                          controller: infoController,
                          icon: Icons.info_outline_rounded,
                          hint: 'Tipo de coleta, localização...',
                          delay: const Duration(milliseconds: 160),
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
  });
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final Duration delay;

  @override
  State<_AnimatedField> createState() => _AnimatedFieldState();
}

class _AnimatedFieldState extends State<_AnimatedField>
    with SingleTickerProviderStateMixin {
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
    required this.onBuscar,
    required this.lixeiras,
    required this.carregando,
    required this.listaCtrl,
  });

  final TextEditingController buscaController;
  final ValueChanged<String> onBuscar;
  final List<LixeiraModel> lixeiras;
  final bool carregando;
  final AnimationController listaCtrl;

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
                const Spacer(),
                SizedBox(
                  width: 160,
                  height: 34,
                  child: TextField(
                    controller: buscaController,
                    onSubmitted: onBuscar,
                    onChanged: (v) {
                      if (v.isEmpty) onBuscar('');
                    },
                    style:
                        const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Colors.white54, size: 16),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.12),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
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
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lixeiras.length,
              separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: Color(0xFFF0F0F0)),
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
                            begin: const Offset(0.08, 0), end: Offset.zero)
                        .animate(itemAnim),
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
                    widget.lixeira.nome,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _hovered ? AppColors.orange : AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.lixeira.outrasInformacoes?.isNotEmpty == true
                        ? widget.lixeira.outrasInformacoes!
                        : 'ID: ${widget.lixeira.id}',
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
