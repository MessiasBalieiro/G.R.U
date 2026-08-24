import 'package:flutter/material.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/repositories/usuario_repository.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/animated_svg_wave.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/social_login_row.dart';

// Guia de modificação das ondas → veja login_screen.dart (mesmo guia)

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _instCtrl = TextEditingController();
  final _repository = UsuarioRepository();
  bool _carregando = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nomeCtrl.dispose();
    _senhaCtrl.dispose();
    _instCtrl.dispose();
    super.dispose();
  }

  String? _req(String? v, String campo) =>
      (v == null || v.trim().isEmpty) ? 'Informe $campo' : null;

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    final ok = await _repository.cadastrar(UsuarioModel(
      nomeUsuario: _nomeCtrl.text.trim(),
      emailUsuario: _emailCtrl.text.trim(),
      telefoneUsuario: '',
      cpfUsuario: '',
      senhaUsuario: _senhaCtrl.text,
      instituicao: _instCtrl.text.trim(),
    ));
    if (!mounted) return;
    setState(() => _carregando = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado! Faça login.')),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Fundo: escuro esq | verde dir (inverso do Login) ───────
          Positioned.fill(
            child: Row(
              children: [
                Expanded(flex: 53, child: Container(color: AppColors.dark)),
                Expanded(flex: 47, child: Container(color: AppColors.green)),
              ],
            ),
          ),

          // ── Ondas SVG — mesma lógica do Login, cores invertidas ────
          Positioned.fill(
            child: LayoutBuilder(builder: (ctx, box) {
              final splitX = box.maxWidth * 0.53;
              const waveW = 160.0;
              return Stack(
                children: [
                  Positioned(
                    left: splitX - waveW * 0.2,
                    top: 0,
                    bottom: 0,
                    width: waveW,
                    child: AnimatedSvgWave(
                      assetPath: AppWaves.dividerGreen,
                      fit: BoxFit.fill,
                      horizontal: true,
                      amplitude: 14,
                      period: const Duration(seconds: 7),
                      allowDrawingOutsideViewBox: true,
                    ),
                  ),
                ],
              );
            }),
          ),

          // ── Samambaia ───────────────────────────────────────────────
          Positioned(
            right: 20,
            bottom: 20,
            child: Opacity(
              opacity: 0.65,
              child: Image.asset(AppImages.fern, width: 80),
            ),
          ),

          // ── Conteúdo ────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.login),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                ),
                Expanded(
                  child: isMobile
                      ? _MobileCadastro(
                          formKey: _formKey,
                          emailCtrl: _emailCtrl,
                          nomeCtrl: _nomeCtrl,
                          senhaCtrl: _senhaCtrl,
                          instCtrl: _instCtrl,
                          carregando: _carregando,
                          req: _req,
                          onSubmit: _cadastrar,
                        )
                      : _DesktopCadastro(
                          formKey: _formKey,
                          emailCtrl: _emailCtrl,
                          nomeCtrl: _nomeCtrl,
                          senhaCtrl: _senhaCtrl,
                          instCtrl: _instCtrl,
                          carregando: _carregando,
                          req: _req,
                          onSubmit: _cadastrar,
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
// DESKTOP — sem scroll
// ══════════════════════════════════════════════════════════════════════════════
class _DesktopCadastro extends StatelessWidget {
  const _DesktopCadastro({
    required this.formKey,
    required this.emailCtrl,
    required this.nomeCtrl,
    required this.senhaCtrl,
    required this.instCtrl,
    required this.carregando,
    required this.req,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl, nomeCtrl, senhaCtrl, instCtrl;
  final bool carregando;
  final String? Function(String?, String) req;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Painel esquerdo (escuro): formulário ─────────────────────
        Expanded(
          flex: 53,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 48, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GruMascot(size: 36),
                const SizedBox(height: 12),
                const Text(
                  'Cadastro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
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
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => req(v, 'seu email')),
                        const SizedBox(height: 10),
                        LabeledTextField(
                            label: 'Nome',
                            controller: nomeCtrl,
                            validator: (v) => req(v, 'seu nome')),
                        const SizedBox(height: 10),
                        LabeledTextField(
                            label: 'Senha',
                            controller: senhaCtrl,
                            obscureText: true,
                            validator: (v) => req(v, 'uma senha')),
                        const SizedBox(height: 10),
                        LabeledTextField(
                            label: 'Instituição',
                            controller: instCtrl,
                            validator: (v) => req(v, 'sua instituição')),
                        const SizedBox(height: 16),
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
                      backgroundColor: AppColors.green,
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
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Painel direito (verde): info ─────────────────────────────
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
                    'Já tem uma conta?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Faça login para acessar o G.R.U',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.login),
                    child: const Text('Login'),
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
// MOBILE — coluna scrollável
// ══════════════════════════════════════════════════════════════════════════════
class _MobileCadastro extends StatelessWidget {
  const _MobileCadastro({
    required this.formKey,
    required this.emailCtrl,
    required this.nomeCtrl,
    required this.senhaCtrl,
    required this.instCtrl,
    required this.carregando,
    required this.req,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl, nomeCtrl, senhaCtrl, instCtrl;
  final bool carregando;
  final String? Function(String?, String) req;
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
            const Text('Cadastro',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
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
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => req(v, 'seu email')),
                  const SizedBox(height: 10),
                  LabeledTextField(
                      label: 'Nome',
                      controller: nomeCtrl,
                      validator: (v) => req(v, 'seu nome')),
                  const SizedBox(height: 10),
                  LabeledTextField(
                      label: 'Senha',
                      controller: senhaCtrl,
                      obscureText: true,
                      validator: (v) => req(v, 'uma senha')),
                  const SizedBox(height: 10),
                  LabeledTextField(
                      label: 'Instituição',
                      controller: instCtrl,
                      validator: (v) => req(v, 'sua instituição')),
                  const SizedBox(height: 14),
                  const SocialLoginRow(),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green),
                onPressed: carregando ? null : onSubmit,
                child: const Text('Cadastrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
