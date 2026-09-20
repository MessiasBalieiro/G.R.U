import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../../../data/repositories/usuario_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/gru_button.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/gru_text_field.dart';
import '../../widgets/social_login_row.dart';
import 'auth_background.dart';

/// "Tela Cadastro" (Administrador): Email, Nome, Senha e Instituição.
/// O botão laranja "Coletores" leva ao cadastro de coletores.
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _nome = TextEditingController();
  final _senha = TextEditingController();
  final _instituicao = TextEditingController();
  final _repo = UsuarioRepository();
  bool _carregando = false;

  @override
  void dispose() {
    _email.dispose();
    _nome.dispose();
    _senha.dispose();
    _instituicao.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      final u = await _repo.cadastrarAdministrador(
        email: _email.text,
        nome: _nome.text,
        senha: _senha.text,
        instituicao: _instituicao.text,
      );
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
    return AuthBlobBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 8, 24, 32),
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
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRoutes.cadastroColetor),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    child: const Text('Coletores'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Criar conta de Administrador',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GruTextField(
                      label: 'Email',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),
                    GruTextField(
                      label: 'Nome',
                      controller: _nome,
                      validator: (v) => Validators.obrigatorio(v, 'Nome'),
                    ),
                    const SizedBox(height: 14),
                    GruTextField(
                      label: 'Senha',
                      controller: _senha,
                      obscure: true,
                      validator: Validators.senha,
                    ),
                    const SizedBox(height: 14),
                    GruTextField(
                      label: 'Instituição',
                      controller: _instituicao,
                      textInputAction: TextInputAction.done,
                      validator: (v) =>
                          Validators.obrigatorio(v, 'Instituição'),
                    ),
                    const SizedBox(height: 26),
                    const Center(child: SocialLoginRow()),
                    const SizedBox(height: 22),
                    Center(
                      child: GruButton(
                        label: 'Cadastre-se',
                        loading: _carregando,
                        onPressed: _cadastrar,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.login),
                        child: const Text(
                          'Já tem conta? Entrar',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
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
    );
  }
}
