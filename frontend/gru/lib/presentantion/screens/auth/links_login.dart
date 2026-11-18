import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/mascaras.dart';
import '../../../data/services/contato_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';

/// Links abaixo do botão Entrar: "Esqueci minha senha" e "Modo demonstração".
class LinksLogin extends StatelessWidget {
  const LinksLogin({super.key, this.alinhamento = WrapAlignment.end});

  final WrapAlignment alinhamento;

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(
        color: Colors.white,
        fontSize: 13,
        decoration: TextDecoration.underline,
        decorationColor: Colors.white);
    return Wrap(
      alignment: alinhamento,
      spacing: 4,
      children: [
        TextButton(
          onPressed: () => showDialog(
              context: context, builder: (_) => const _EsqueciSenhaDialog()),
          child: const Text('Esqueci minha senha', style: estilo),
        ),
        TextButton(
          onPressed: () {
            context.read<AuthProvider>().entrarModoDemo();
            Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.areaTrabalho, (_) => false);
          },
          child: const Text('Modo demonstração', style: estilo),
        ),
      ],
    );
  }
}

class _EsqueciSenhaDialog extends StatefulWidget {
  const _EsqueciSenhaDialog();

  @override
  State<_EsqueciSenhaDialog> createState() => _EsqueciSenhaDialogState();
}

class _EsqueciSenhaDialogState extends State<_EsqueciSenhaDialog> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _enviando = false;
  bool _enviado = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final email = _email.text.trim();
    final ok = await const ContatoService().enviar(
      assunto: 'Redefinição de senha - G.R.U',
      emailRetorno: email,
      mensagem: 'Pedido de redefinição de senha pelo site.\n'
          'E-mail da conta: $email',
    );
    if (!mounted) return;
    setState(() {
      _enviando = false;
      _enviado = ok;
      if (!ok) {
        _erro = 'Não foi possível enviar agora. Tente de novo em instantes.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Esqueci minha senha'),
      content: _enviado
          ? const Text(
              'Pedido enviado! A equipe do G.R.U vai entrar em contato pelo '
              'e-mail informado para ajudar a redefinir sua senha.')
          : Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'Informe o e-mail da sua conta. A equipe entrará em '
                      'contato por e-mail para redefinir a senha.'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: Validadores.email,
                  ),
                  if (_erro != null) ...[
                    const SizedBox(height: 8),
                    Text(_erro!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
          child: Text(_enviado ? 'Fechar' : 'Cancelar'),
        ),
        if (!_enviado)
          FilledButton(
            onPressed: _enviando ? null : _enviar,
            child: _enviando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Enviar'),
          ),
      ],
    );
  }
}
