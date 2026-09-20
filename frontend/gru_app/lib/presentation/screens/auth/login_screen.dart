import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/usuario_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/gru_button.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/gru_scaffold.dart';
import '../../widgets/gru_text_field.dart';
import '../../widgets/social_login_row.dart';

/// "Tela Login": fundo verde, Email, Senha, login social e botão Login.
/// O tipo de usuário (Administrador/Coletor) vem da conta e define a Home.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _repo = UsuarioRepository();
  bool _carregando = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      final u = await _repo.login(email: _email.text, senha: _senha.text);
      if (!mounted) return;
      SessionService.instance.entrar(u);
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.homePara(u.tipo), (_) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.mensagem)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GruSystemUi(
      navColor: AppColors.green,
      child: Scaffold(
        backgroundColor: AppColors.green,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 8, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: Colors.white),
                      ),
                      const GruMascot(size: 48),
                    ],
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.09),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GruTextField(
                          label: 'Email',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 18),
                        GruTextField(
                          label: 'Senha',
                          controller: _senha,
                          obscure: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _entrar(),
                          validator: (v) => Validators.obrigatorio(v, 'Senha'),
                        ),
                        const SizedBox(height: 28),
                        const Center(child: SocialLoginRow()),
                        const SizedBox(height: 28),
                        Center(
                          child: GruButton(
                            label: 'Login',
                            loading: _carregando,
                            onPressed: _entrar,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.cadastro),
                            child: const Text(
                              'Não tem conta? Cadastre-se',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
