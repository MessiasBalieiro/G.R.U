import 'package:flutter/material.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/animated_svg_wave.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/quem_somos_card.dart';
import '../../widgets/depth_card.dart';
import '../../widgets/app_footer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeroSection(),
            const SizedBox(height: 44),
            const PageContainer(child: _QuemSomosSection()),
            const SizedBox(height: 44),
            const _LixeiraInteligenteSection(),
            const SizedBox(height: 44),
            const _ComecarSection(),
            const SizedBox(height: 44),
            const PageContainer(child: _FaqSection()),
            const SizedBox(height: 32),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO — ocupa 100% da altura da janela no primeiro carregamento
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;

    return Container(
      height: screenH,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.heroBg),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
              ),
            ),
          ),

          // ── ONDA SVG NA BASE DO HERO ──────────────────────────────────
          // COMO MODIFICAR AS ONDAS SVG:
          //
          // TAMANHO  → altere width / height abaixo (em pixels)
          // POSIÇÃO  → altere top / bottom / left / right no Positioned
          // VELOCIDADE → period: Duration(seconds: X)
          //              menor X = onda mais rápida, maior X = mais lenta
          // INTENSIDADE → amplitude: X
          //              maior X = balança mais pixels, menor X = mais sutil
          // DIREÇÃO  → horizontal: false  = anima eixo Y (cima/baixo) ← use para ondas no topo/base
          //            horizontal: true   = anima eixo X (esq/dir)   ← use para divisores laterais
          // ARQUIVO SVG → assetPath: AppWaves.nomeDoArquivo
          //   AppWaves.cornerGreenBottom → assets/waves/wave_corner_green_bottom.svg
          //   AppWaves.cornerGreenTop    → assets/waves/wave_corner_green_top.svg
          //   AppWaves.cornerDark        → assets/waves/wave_corner_dark.svg
          //   AppWaves.cornerOrange      → assets/waves/wave_corner_orange.svg
          //   AppWaves.dividerGreen      → assets/waves/wave_divider_green.svg
          //   AppWaves.dividerDark       → assets/waves/wave_divider_dark.svg
          //   AppWaves.bottomDark        → assets/waves/wave_bottom_dark.svg
          //   AppWaves.bottomOrange      → assets/waves/wave_bottom_orange.svg
          //   AppWaves.topGreen          → assets/waves/wave_top_green.svg
          Positioned(
            bottom: -2,
            left: 0,
            right: 0,
            child: AnimatedSvgWave(
              assetPath: AppWaves.cornerGreenBottom,
              height: 90,          // ← altura da onda em pixels
              fit: BoxFit.cover,
              horizontal: false,   // ← move no eixo Y (cima/baixo)
              amplitude: 6,        // ← intensidade: 6px pra cima e pra baixo
              period: const Duration(seconds: 6), // ← 1 ciclo a cada 6s
            ),
          ),

          Positioned(
            top: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
              child: const Text('Login'),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GruLogoLockup(iconSize: 44),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.appFullName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 48),
                const _ScrollHint(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Setinha animada indicando "role para baixo".
class _ScrollHint extends StatefulWidget {
  const _ScrollHint();
  @override
  State<_ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<_ScrollHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: 12)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _anim.value), child: child),
      child: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Colors.white70, size: 32),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUEM SOMOS — 3 cards com efeito DepthCard e hover
// ─────────────────────────────────────────────────────────────────────────────
class _QuemSomosSection extends StatelessWidget {
  const _QuemSomosSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quem Somos?',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 640;

          final cardDefs = [
            (
              titulo: AppStrings.problemaTitulo,
              texto: AppStrings.problemaTexto,
              img: AppImages.problema,
              shadow: AppColors.orange,
            ),
            (
              titulo: AppStrings.solucaoTitulo,
              texto: AppStrings.solucaoTexto,
              img: AppImages.solucao,
              shadow: AppColors.green,
            ),
            (
              titulo: AppStrings.gruTitulo,
              texto: AppStrings.gruTexto,
              img: null as String?,
              shadow: AppColors.orange,
            ),
          ];

          if (isMobile) {
            return Column(
              children: [
                for (final d in cardDefs) ...[
                  SizedBox(
                    height: 260,
                    child: DepthCard(
                      depthColor: d.shadow,
                      child: QuemSomosCard(
                          titulo: d.titulo,
                          texto: d.texto,
                          imagemAsset: d.img),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
              ],
            );
          }

          return SizedBox(
            height: 290,
            child: Row(
              children: [
                for (int i = 0; i < cardDefs.length; i++) ...[
                  Expanded(
                    child: DepthCard(
                      depthColor: cardDefs[i].shadow,
                      child: QuemSomosCard(
                        titulo: cardDefs[i].titulo,
                        texto: cardDefs[i].texto,
                        imagemAsset: cardDefs[i].img,
                      ),
                    ),
                  ),
                  if (i < cardDefs.length - 1) const SizedBox(width: 24),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIXEIRA INTELIGENTE
// ─────────────────────────────────────────────────────────────────────────────
class _LixeiraInteligenteSection extends StatelessWidget {
  const _LixeiraInteligenteSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.green,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: PageContainer(
        child: LayoutBuilder(builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 640;

          final texto = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.lixeiraInteligenteTitulo,
                style: TextStyle(
                    color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              Text(
                AppStrings.lixeiraInteligenteTexto,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 15,
                    height: 1.55),
              ),
            ],
          );

          final foto = Container(
            height: 220,
            width: isMobile ? double.infinity : 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(28),
            child: Image.asset(AppImages.binGreen, fit: BoxFit.contain),
          );

          if (isMobile) {
            return Column(
                children: [texto, const SizedBox(height: 26), foto]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: texto),
              const SizedBox(width: 36),
              foto,
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA
// ─────────────────────────────────────────────────────────────────────────────
class _ComecarSection extends StatelessWidget {
  const _ComecarSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Começar a reciclar com o G.R.U',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.dark),
          ),
          const SizedBox(width: 10),
          const GruMascot(size: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAQ
// ─────────────────────────────────────────────────────────────────────────────
class _FaqSection extends StatefulWidget {
  const _FaqSection();
  @override
  State<_FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<_FaqSection> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _focado = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _focado = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 640;

      final pergunta = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(AppStrings.faqTitulo,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          const Text(AppStrings.faqSubtitulo,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _focado ? AppColors.orange : AppColors.placeholder,
                      width: _focado ? 1.6 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Escreva sua pergunta...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green),
                onPressed: () {
                  final texto = _controller.text.trim();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(texto.isEmpty
                          ? 'Escreva uma pergunta antes de enviar.'
                          : 'Pergunta enviada! Em breve retornamos.'),
                    ),
                  );
                  if (texto.isNotEmpty) _controller.clear();
                },
                child: const Text('Enviar'),
              ),
            ],
          ),
        ],
      );

      final respondidas = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(AppStrings.faqRespondidasTitulo,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          for (final p in AppStrings.faqPerguntas)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Expanded(
                        child: Text(p,
                            style: const TextStyle(
                                fontSize: 13.5, color: AppColors.dark))),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 16, color: AppColors.orange),
                  ],
                ),
              ),
            ),
        ],
      );

      if (isMobile) {
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          pergunta,
          const SizedBox(height: 24),
          respondidas,
        ]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: pergunta),
          const SizedBox(width: 32),
          Expanded(flex: 2, child: respondidas),
        ],
      );
    });
  }
}
