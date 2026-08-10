import 'package:flutter/material.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/repositories/usuario_repository.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/social_login_row.dart';
import '../../widgets/wave_shapes.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  final _instituicaoController = TextEditingController();
  final _repository = UsuarioRepository();
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nomeController.dispose();
    _senhaController.dispose();
    _instituicaoController.dispose();
    super.dispose();
  }

  String? _obrigatorio(String? v, String campo) =>
      (v == null || v.trim().isEmpty) ? 'Informe $campo' : null;

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    final ok = await _repository.cadastrar(UsuarioModel(
      nomeUsuario: _nomeController.text.trim(),
      emailUsuario: _emailController.text.trim(),
      telefoneUsuario: '',
      cpfUsuario: '',
      senhaUsuario: _senhaController.text,
      instituicao: _instituicaoController.text.trim(),
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
    return Scaffold(
      body: Stack(
        children: [
          const SplitWaveBackground(
            leftColor: AppColors.dark,
            rightColor: AppColors.green,
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
                      opacity: 0.85,
                      child: Image.asset(AppImages.fern, width: 90 * escala),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 8),
                        child: IconButton(
                          onPressed: () => Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.login),
                          iconSize: 22 * escala,
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white),
                          tooltip: 'Voltar para o Login',
                        ),
                      ),
                      Expanded(
                        child: Builder(builder: (context) {
                          final formulario = _CadastroForm(
                            formKey: _formKey,
                            emailController: _emailController,
                            nomeController: _nomeController,
                            senhaController: _senhaController,
                            instituicaoController: _instituicaoController,
                            carregando: _carregando,
                            obrigatorio: _obrigatorio,
                            onSubmit: _cadastrar,
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

class _CadastroForm extends StatelessWidget {
  const _CadastroForm({
    required this.formKey,
    required this.emailController,
    required this.nomeController,
    required this.senhaController,
    required this.instituicaoController,
    required this.carregando,
    required this.obrigatorio,
    required this.onSubmit,
    required this.escala,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController nomeController;
  final TextEditingController senhaController;
  final TextEditingController instituicaoController;
  final bool carregando;
  final String? Function(String?, String) obrigatorio;
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
            'Cadastro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30 * escala,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 28 * escala),
          LabeledTextField(
            label: 'Email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => obrigatorio(v, 'seu email'),
          ),
          SizedBox(height: 18 * escala),
          LabeledTextField(
            label: 'Nome',
            controller: nomeController,
            validator: (v) => obrigatorio(v, 'seu nome'),
          ),
          SizedBox(height: 18 * escala),
          LabeledTextField(
            label: 'Senha',
            controller: senhaController,
            obscureText: true,
            validator: (v) => obrigatorio(v, 'uma senha'),
          ),
          SizedBox(height: 18 * escala),
          LabeledTextField(
            label: 'Instituição',
            controller: instituicaoController,
            validator: (v) => obrigatorio(v, 'sua instituição'),
          ),
          SizedBox(height: 26 * escala),
          SocialLoginRow(iconSize: 26 * escala),
          SizedBox(height: 26 * escala),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
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
                  : const Text('Cadastrar'),
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
            'Já tem uma conta?',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20 * escala,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10 * escala),
          Text(
            'Faça login para acessar o G.R.U',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(color: Colors.white70, fontSize: 14 * escala),
          ),
          SizedBox(height: 22 * escala),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.6),
              padding: EdgeInsets.symmetric(
                  horizontal: 28 * escala, vertical: 14 * escala),
              textStyle: TextStyle(fontSize: 15 * escala),
            ),
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.login),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
