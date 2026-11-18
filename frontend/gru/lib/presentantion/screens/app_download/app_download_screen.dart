import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/api_config.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/decor_background.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/phone_mockup.dart';

class AppDownloadScreen extends StatelessWidget {
  const AppDownloadScreen({super.key});

  Future<void> _baixar(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Iniciando o download do G.R.U...')),
    );
    var ok = false;
    try {
      ok = await launchUrl(
        Uri.parse(ApiConfig.apkUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade600,
          content: const Text('Não foi possível iniciar o download agora.'),
        ),
      );
    }
  }

  void _voltar(BuildContext context) {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          const DotGridBackground(),
          const CornerArc(
              color: AppColors.green, radius: 150, corner: ArcCorner.topLeft),
          const CornerArc(
              color: AppColors.dark,
              radius: 170,
              corner: ArcCorner.bottomRight),
          const CornerArc(
              color: AppColors.orange,
              radius: 70,
              corner: ArcCorner.bottomLeft),
          SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 800;
              final informacoes = _Informacoes(
                centralizado: isMobile,
                onBaixar: () => _baixar(context),
              );
              final visual = const _Visual();

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24, vertical: isMobile ? 64 : 40),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: isMobile
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  informacoes,
                                  const SizedBox(height: 36),
                                  visual,
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(flex: 5, child: informacoes),
                                  const SizedBox(width: 40),
                                  Expanded(flex: 4, child: visual),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                tooltip: 'Voltar',
                onPressed: () => _voltar(context),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Informacoes extends StatelessWidget {
  const _Informacoes({required this.centralizado, required this.onBaixar});

  final bool centralizado;
  final VoidCallback onBaixar;

  @override
  Widget build(BuildContext context) {
    final alinhamento =
        centralizado ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final texto = centralizado ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: alinhamento,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.orange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'APP PARA ANDROID',
            style: TextStyle(
              color: AppColors.orange,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Leve o G.R.U\nno seu bolso',
          textAlign: texto,
          style: const TextStyle(
            fontSize: 40,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Acompanhe suas lixeiras e a coleta de resíduos de onde estiver.',
          textAlign: texto,
          style: const TextStyle(
              fontSize: 16, height: 1.4, color: AppColors.textMuted),
        ),
        const SizedBox(height: 22),
        const _Beneficio(Icons.speed_rounded,
            'Nível das lixeiras em tempo real'),
        const _Beneficio(Icons.add_location_alt_rounded,
            'Cadastre lixeiras e coletores pelo celular'),
        const _Beneficio(Icons.chat_bubble_rounded,
            'Tire dúvidas com o Ciclo, nosso assistente'),
        const SizedBox(height: 26),
        _BotaoDownload(onTap: onBaixar),
        const SizedBox(height: 10),
        const Text(
          'Arquivo APK • instalação direta',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        const _ComoInstalar(),
      ],
    );
  }
}

class _Beneficio extends StatelessWidget {
  const _Beneficio(this.icone, this.texto);
  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 16, color: AppColors.greenDark),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(texto,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.dark)),
          ),
        ],
      ),
    );
  }
}

class _BotaoDownload extends StatefulWidget {
  const _BotaoDownload({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_BotaoDownload> createState() => _BotaoDownloadState();
}

class _BotaoDownloadState extends State<_BotaoDownload> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          decoration: BoxDecoration(
            color: _hover ? AppColors.orangeDark : AppColors.orange,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withOpacity(_hover ? 0.5 : 0.3),
                blurRadius: _hover ? 24 : 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Baixar APK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComoInstalar extends StatelessWidget {
  const _ComoInstalar();

  @override
  Widget build(BuildContext context) {
    const passos = [
      'Baixe o arquivo APK no seu celular Android.',
      'Abra o arquivo e permita a instalação de apps desconhecidos, se pedir.',
      'Toque em Instalar e pronto!',
    ];
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Como instalar',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.dark)),
          const SizedBox(height: 8),
          for (var i = 0; i < passos.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: AppColors.dark, shape: BoxShape.circle),
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(passos[i],
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.textMuted)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Visual extends StatelessWidget {
  const _Visual();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 340,
        height: 600,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const _Flutuando(
              amplitude: 8,
              duracao: Duration(seconds: 3),
              child: PhoneMockup(imageAsset: AppImages.appPreview, width: 260),
            ),
            Positioned(
              right: 0,
              bottom: 60,
              child: _Flutuando(
                amplitude: 12,
                duracao: const Duration(milliseconds: 2400),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dark.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const GruMascot(size: 64),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Faz o filho flutuar suavemente para cima e para baixo.
class _Flutuando extends StatefulWidget {
  const _Flutuando({
    required this.child,
    required this.amplitude,
    required this.duracao,
  });

  final Widget child;
  final double amplitude;
  final Duration duracao;

  @override
  State<_Flutuando> createState() => _FlutuandoState();
}

class _FlutuandoState extends State<_Flutuando>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duracao,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      child: widget.child,
      builder: (_, child) {
        final t = Curves.easeInOut.transform(_c.value);
        return Transform.translate(
          offset: Offset(0, (t - 0.5) * 2 * widget.amplitude),
          child: child,
        );
      },
    );
  }
}
