import 'package:flutter/material.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/usuario_repository.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/animated_svg_wave.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/social_login_row.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GUIA RÁPIDO: COMO MODIFICAR AS ONDAS SVG
//
// TAMANHO     → width / height no AnimatedSvgWave (em pixels)
// POSIÇÃO     → mova o Positioned (top / bottom / left / right)
// VELOCIDADE  → period: Duration(seconds: X)  — menor = mais rápido
// INTENSIDADE → amplitude: X                  — maior = balança mais (px)
// DIREÇÃO     → horizontal: false → eixo Y (cima/baixo) ← ondas no topo/base
//               horizontal: true  → eixo X (esq/dir)   ← divisores laterais
// ARQUIVO SVG → assetPath: AppWaves.nomeDaOnda
//   AppWaves.dividerGreen      → assets/waves/wave_divider_green.svg
//   AppWaves.dividerDark       → assets/waves/wave_divider_dark.svg
//   AppWaves.cornerGreenTop    → assets/waves/wave_corner_green_top.svg
//   AppWaves.cornerGreenBottom → assets/waves/wave_corner_green_bottom.svg
//   AppWaves.cornerDark        → assets/waves/wave_corner_dark.svg
//   AppWaves.cornerOrange      → assets/waves/wave_corner_orange.svg
//   AppWaves.topGreen          → assets/waves/wave_top_green.svg
//   AppWaves.bottomDark        → assets/waves/wave_bottom_dark.svg
//   AppWaves.bottomOrange      → assets/waves/wave_bottom_orange.svg
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _repository = UsuarioRepository();
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    final ok = await _repository.login(
      email: _emailController.text,
      senha: _senhaController.text,
    );
    if (!mounted) return;
    setState(() => _carregando = false);
    if (ok) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.areaTrabalho, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha email e senha.')),
      );
    }
  }

  void _voltarParaHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return Scaffold(
      // Impede que o teclado mobile empurre o layout e quebre o design
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── FUNDO: verde esq | escuro dir ──────────────────────────
          Positioned.fill(
            child: Row(
              children: [
                Expanded(flex: 53, child: Container(color: AppColors.green)),
                Expanded(flex: 47, child: Container(color: AppColors.dark)),
              ],
            ),
          ),

          // ── ONDA SVG VERDE (divisor S-curve, vai-e-vem lateral) ────
          // Para ajustar: veja o guia no topo deste arquivo
          Positioned.fill(
            child: LayoutBuilder(builder: (ctx, box) {
              final splitX = box.maxWidth * 0.53;
              const waveW = 160.0; // ← LARGURA da onda (px)
              return Stack(
                children: [
                  
                  Positioned(
                    left: splitX - waveW * 0.2,
                    top: 0,
                    bottom: 0,
                    width: waveW,
                    child: AnimatedSvgWave(
                      assetPath: AppWaves.dividerDark,
                      fit: BoxFit.fill,
                      horizontal: true,
                      amplitude: 14,
                      period: const Duration(seconds: 7), // fase ligeiramente diferente
                      allowDrawingOutsideViewBox: true,
                    ),
                  ),
                ],
              );
            }),
          ),

          // ── SAMAMBAIA decorativa ──────────────────────────────────
          // Posição → altere right / bottom
          // Tamanho → altere width
          Positioned(
            right: 20,  // ← distância da borda direita
            bottom: 20, // ← distância da borda inferior
            child: Opacity(
              opacity: 0.65,
              child: Image.asset(AppImages.fern, width: 80), // ← tamanho
            ),
          ),

          // ── CONTEÚDO ──────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: _voltarParaHome,
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                Expanded(
                  child: isMobile
                      ? _MobileLayout(
                          formKey: _formKey,
                          emailController: _emailController,
                          senhaController: _senhaController,
                          carregando: _carregando,
                          onSubmit: _entrar,
                        )
                      : _DesktopLayout(
                          formKey: _formKey,
                          emailController: _emailController,
                          senhaController: _senhaController,
                          carregando: _carregando,
                          onSubmit: _entrar,
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

// ══════════════════════════════════════════════════════════════════════════════
// DESKTOP — dois painéis, SEM scroll (cabe na tela inteira)
// ══════════════════════════════════════════════════════════════════════════════
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.formKey,
    required this.emailController,
    required this.senhaController,
    required this.carregando,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final bool carregando;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Painel esquerdo (verde): formulário ─────────────────────
        Expanded(
          flex: 53,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 48, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GruMascot(size: 36),
                const SizedBox(height: 14),
                const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),

                // Container com borda branca — igual ao design
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.7), width: 1.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LabeledTextField(
                          label: 'Email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Informe seu email'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        LabeledTextField(
                          label: 'Senha',
                          controller: senhaController,
                          obscureText: true,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Informe sua senha'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        const SocialLoginRow(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.dark,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: carregando ? null : onSubmit,
                    child: carregando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Entrar'),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Painel direito (escuro): info ───────────────────────────
        Expanded(
          flex: 47,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(AppImages.recyclingSymbolWhite, width: 100),
                  const SizedBox(height: 28),
                  const Text(
                    'Não possui conta?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Se cadastre agora para poder acessar o G.R.U',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.cadastro),
                    child: const Text('Cadastre-se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MOBILE — coluna scrollável (telas pequenas)
// ══════════════════════════════════════════════════════════════════════════════
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.formKey,
    required this.emailController,
    required this.senhaController,
    required this.carregando,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final bool carregando;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GruMascot(size: 32),
            const SizedBox(height: 12),
            const Text('Login',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.7)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LabeledTextField(
                    label: 'Email',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe seu email'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  LabeledTextField(
                    label: 'Senha',
                    controller: senhaController,
                    obscureText: true,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe sua senha'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const SocialLoginRow(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.dark),
                onPressed: carregando ? null : onSubmit,
                child: const Text('Entrar'),
              ),
            ),
            const SizedBox(height: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(AppImages.recyclingSymbolWhite, width: 80),
                const SizedBox(height: 16),
                const Text('Não possui conta?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Se cadastre agora para poder acessar o G.R.U',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.cadastro),
                  child: const Text('Cadastre-se'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
