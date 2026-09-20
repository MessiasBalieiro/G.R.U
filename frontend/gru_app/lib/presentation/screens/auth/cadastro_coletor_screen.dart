import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../../../data/repositories/usuario_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/gru_button.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/gru_text_field.dart';
import 'auth_background.dart';

/// "Tela Cadastro-Coletor": "Bem-vindo, Coletores!" + Email, Nome e Senha.
/// A instituição não é digitada aqui: o Administrador vincula o coletor.
class CadastroColetorScreen extends StatefulWidget {
  const CadastroColetorScreen({super.key});

  @override
  State<CadastroColetorScreen> createState() => _CadastroColetorScreenState();
}

class _CadastroColetorScreenState extends State<CadastroColetorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _nome = TextEditingController();
  final _senha = TextEditingController();
  final _repo = UsuarioRepository();
  bool _carregando = false;

  @override
  void dispose() {
    _email.dispose();
    _nome.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      final u = await _repo.cadastrarColetor(
        email: _email.text,
        nome: _nome.text,
        senha: _senha.text,
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
                  const Text(
                    'Bem-vindo,\nColetores!',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
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
                    const SizedBox(height: 16),
                    GruTextField(
                      label: 'Nome',
                      controller: _nome,
                      validator: (v) => Validators.obrigatorio(v, 'Nome'),
                    ),
                    const SizedBox(height: 16),
                    GruTextField(
                      label: 'Senha',
                      controller: _senha,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _cadastrar(),
                      validator: Validators.senha,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Depois do cadastro, o administrador da sua instituição '
                      'vai vincular você às lixeiras que você atende.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
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
