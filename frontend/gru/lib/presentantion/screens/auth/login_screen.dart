import 'package:flutter/material.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/usuario_repository.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/social_login_row.dart';
import '../../widgets/wave_shapes.dart';

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

  /// Volta para a Home. Usa `pop` se possível (mantém o histórico natural),
  /// senão navega direto para não deixar o usuário preso na tela.
  void _voltarParaHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SplitWaveBackground(
            leftColor: AppColors.green,
            rightColor: AppColors.dark,
            splitFraction: 0.53,
          ),
          SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              final double escala = isMobile
                  ? 1.0
                  : (constraints.maxWidth / 1100).clamp(1.0, 1.7).toDouble();

              return Stack(
                children: [
                  Positioned(
                    right: 24 * escala,
                    bottom: 24 * escala,
                    child: Opacity(
                      opacity: 0.7,
                      child: Image.asset(AppImages.fern, width: 90 * escala),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 8),
                        child: IconButton(
                          onPressed: _voltarParaHome,
                          iconSize: 22 * escala,
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white),
                          tooltip: 'Voltar para a Home',
                        ),
                      ),
                      Expanded(
                        child: Builder(builder: (context) {
                          final formulario = _LoginForm(
                            formKey: _formKey,
                            emailController: _emailController,
                            senhaController: _senhaController,
                            carregando: _carregando,
                            onSubmit: _entrar,
                            escala: escala,
                          );
                          final ladoDireito = _RightPanel(
                            isMobile: isMobile,
                            escala: escala,
                          );

                          if (isMobile) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  formulario,
                                  const SizedBox(height: 48),
                                  ladoDireito,
                                ],
                              ),
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxWidth: 480 * escala),
                                    child: formulario,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Center(child: ladoDireito),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.senhaController,
    required this.carregando,
    required this.onSubmit,
    required this.escala,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final bool carregando;
  final VoidCallback onSubmit;
  final double escala;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GruMascot(size: 44 * escala),
          SizedBox(height: 22 * escala),
          Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30 * escala,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30 * escala),
          LabeledTextField(
            label: 'Email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe seu email' : null,
          ),
          SizedBox(height: 22 * escala),
          LabeledTextField(
            label: 'Senha',
            controller: senhaController,
            obscureText: true,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe sua senha' : null,
          ),
          SizedBox(height: 30 * escala),
          SocialLoginRow(iconSize: 26 * escala),
          SizedBox(height: 26 * escala),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.dark,
                padding: EdgeInsets.symmetric(
                    horizontal: 30 * escala, vertical: 16 * escala),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: TextStyle(fontSize: 15 * escala),
              ),
              onPressed: carregando ? null : onSubmit,
              child: carregando
                  ? SizedBox(
                      width: 18 * escala,
                      height: 18 * escala,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Entrar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({required this.isMobile, required this.escala});

  final bool isMobile;
  final double escala;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Image.asset(AppImages.recyclingSymbolWhite, width: 110 * escala),
          SizedBox(height: 30 * escala),
          Text(
            'Não possui conta?',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20 * escala,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10 * escala),
          Text(
            'Se cadastre agora para poder acessar o G.R.U',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(color: Colors.white70, fontSize: 14 * escala),
          ),
          SizedBox(height: 22 * escala),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  horizontal: 28 * escala, vertical: 14 * escala),
              textStyle: TextStyle(fontSize: 15 * escala),
            ),
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.cadastro),
            child: const Text('Cadastre-se'),
          ),
        ],
      ),
    );
  }
}
