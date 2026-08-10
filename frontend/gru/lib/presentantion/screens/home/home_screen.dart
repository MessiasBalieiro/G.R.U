import 'package:flutter/material.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/quem_somos_card.dart';
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

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
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
          Positioned(
            top: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.login),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 640;
          final cards = const [
            QuemSomosCard(
              titulo: AppStrings.problemaTitulo,
              texto: AppStrings.problemaTexto,
              imagemAsset: AppImages.problema,
            ),
            QuemSomosCard(
              titulo: AppStrings.solucaoTitulo,
              texto: AppStrings.solucaoTexto,
              imagemAsset: AppImages.solucao,
            ),
            QuemSomosCard(
              titulo: AppStrings.gruTitulo,
              texto: AppStrings.gruTexto,
            ),
          ];

          if (isMobile) {
            return Column(
              children: [
                for (final c in cards) ...[
                  SizedBox(height: 260, child: c),
                  const SizedBox(height: 18),
                ],
              ],
            );
          }

          return SizedBox(
            height: 280,
            child: Row(
              children: [
                for (final c in cards) ...[
                  Expanded(child: c),
                  if (c != cards.last) const SizedBox(width: 20),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}


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
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                AppStrings.lixeiraInteligenteTexto,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 15,
                  height: 1.55,
                ),
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
              children: [texto, const SizedBox(height: 26), foto],
            );
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
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(width: 10),
          const GruMascot(size: 32),
        ],
      ),
    );
  }
}

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
    _focusNode.addListener(() {
      setState(() => _focado = _focusNode.hasFocus);
    });
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
          const Text(
            AppStrings.faqTitulo,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            AppStrings.faqSubtitulo,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
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
                  backgroundColor: AppColors.green,
                ),
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
          const Text(
            AppStrings.faqRespondidasTitulo,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
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
                              fontSize: 13.5, color: AppColors.dark)),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 16, color: AppColors.orange),
                  ],
                ),
              ),
            ),
        ],
      );

      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            pergunta,
            const SizedBox(height: 24),
            respondidas,
          ],
        );
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
