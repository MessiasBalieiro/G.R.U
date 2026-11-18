import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/repositories/lixeira_repository.dart';
import '../../../data/repositories/usuario_repository.dart';
import '../../../data/services/social_auth_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/lixeira_provider.dart';
import '../../../routes/app_routes.dart';

/// Fluxo compartilhado pelas telas de Login e Cadastro:
///  - [iniciar]: login social (cria o cadastro na primeira vez);
///  - [concluirLogin]: carrega os dados da conta e abre a Área de Trabalho.
class SocialLoginFlow {
  SocialLoginFlow._();

  static Future<void> iniciar(
      BuildContext context, ProvedorSocial provedor) async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = UsuarioRepository();

    void aviso(String texto) {
      messenger.showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade600,
        content: Text(texto),
      ));
    }

    try {
      final perfil = await SocialAuthService().entrar(provedor);
      dynamic usuario = await repo.loginSocial(idToken: perfil.idToken);

      if (usuario == null) {
        // Primeira vez: completa o cadastro (CPF, telefone, instituição).
        if (!context.mounted) return;
        final dados = await showDialog<_DadosComplementares>(
          context: context,
          barrierDismissible: false,
          builder: (_) => _CompletarCadastroDialog(perfil: perfil),
        );
        if (dados == null) return;
        usuario = await repo.cadastrar(
          nome: perfil.nome,
          email: perfil.email,
          telefone: dados.telefone,
          cpf: dados.cpf,
          senha: _senhaAleatoria(),
          instituicao: dados.instituicao,
        );
        if (usuario == null) {
          aviso('Não foi possível criar sua conta. Confira o CPF e o telefone.');
          return;
        }
      }

      if (!context.mounted) return;
      await concluirLogin(context, usuario);
    } on SocialAuthException catch (e) {
      if (!e.cancelado) aviso(e.mensagem);
    } catch (_) {
      aviso('Não foi possível entrar agora. Tente novamente.');
    }
  }

  /// Guarda o usuário, carrega organização/coletores/lixeiras e abre a
  /// Área de Trabalho. [usuario] é o JSON devolvido pelo backend.
  static Future<void> concluirLogin(BuildContext context, dynamic usuario) async {
    final auth = context.read<AuthProvider>();
    final lixeiras = context.read<LixeiraProvider>();
    final navigator = Navigator.of(context);
    final repo = UsuarioRepository();
    final repoLixeira = LixeiraRepository();

    auth.definirUsuario(UsuarioModel(
      id: usuario['_id'],
      nomeUsuario: usuario['nome_usuario'],
      emailUsuario: usuario['email_usuario'],
      telefoneUsuario: usuario['telefone_usuario'],
      cpfUsuario: usuario['cpf_usuario'],
      cargoUsuario: usuario['cargo_usuario'],
      instituicao: usuario['instituicao_usuario'],
      coletasRealizadas: usuario['coletas_realizadas'],
    ));
    auth.definirOrganizacao(
        await repo.buscarOrganizacao(idContratante: usuario['_id']));

    final org = auth.organizacao;
    if (org != null) {
      final coletores = org['colectors'] as List?;
      if (coletores != null && coletores.isNotEmpty) {
        auth.definirColetores(await repo.buscarColetores(ids: coletores));
      }
      final trashes = org['trashes'] as List?;
      if (trashes != null && trashes.isNotEmpty) {
        lixeiras.definirLixeiras(
            await repoLixeira.listar(codigoDonoLixeira: usuario['_id']));
      }
    }

    navigator.pushNamedAndRemoveUntil(AppRoutes.areaTrabalho, (_) => false);
  }

  /// Contas sociais não usam senha, mas o cadastro exige uma.
  static String _senhaAleatoria() {
    final r = Random.secure();
    return base64UrlEncode(List<int>.generate(24, (_) => r.nextInt(256)));
  }
}

class _DadosComplementares {
  const _DadosComplementares(this.cpf, this.telefone, this.instituicao);
  final String cpf;
  final String telefone;
  final String instituicao;
}

class _CompletarCadastroDialog extends StatefulWidget {
  const _CompletarCadastroDialog({required this.perfil});
  final SocialPerfil perfil;

  @override
  State<_CompletarCadastroDialog> createState() =>
      _CompletarCadastroDialogState();
}

class _CompletarCadastroDialogState extends State<_CompletarCadastroDialog> {
  final _form = GlobalKey<FormState>();
  final _cpf = TextEditingController();
  final _tel = TextEditingController();
  final _inst = TextEditingController();

  @override
  void dispose() {
    _cpf.dispose();
    _tel.dispose();
    _inst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete seu cadastro'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${widget.perfil.nome}! Falta pouco para criar sua '
                  'conta com ${widget.perfil.email}.',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cpf,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_MascaraFormatter(_formatarCpf, 11)],
                  decoration: const InputDecoration(hintText: 'CPF'),
                  validator: (v) =>
                      RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$').hasMatch(v ?? '')
                          ? null
                          : 'Informe um CPF válido',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tel,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_MascaraFormatter(_formatarTelefone, 11)],
                  decoration: const InputDecoration(hintText: 'Telefone'),
                  validator: (v) => RegExp(r'^\(\d{2}\) \d{4,5}-\d{4}$')
                          .hasMatch(v ?? '')
                      ? null
                      : 'Informe um telefone válido',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _inst,
                  decoration: const InputDecoration(hintText: 'Instituição'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe sua instituição'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.of(context).pop(_DadosComplementares(
                _cpf.text, _tel.text, _inst.text.trim()));
          },
          child: const Text('Criar conta'),
        ),
      ],
    );
  }
}

String _formatarCpf(String d) {
  final b = StringBuffer();
  for (var i = 0; i < d.length; i++) {
    if (i == 3 || i == 6) b.write('.');
    if (i == 9) b.write('-');
    b.write(d[i]);
  }
  return b.toString();
}

String _formatarTelefone(String d) {
  final b = StringBuffer();
  for (var i = 0; i < d.length; i++) {
    if (i == 0) b.write('(');
    if (i == 2) b.write(') ');
    if (d.length == 11 ? i == 7 : i == 6) b.write('-');
    b.write(d[i]);
  }
  return b.toString();
}

/// Digita só números e aplica a máscara enquanto a pessoa escreve.
class _MascaraFormatter extends TextInputFormatter {
  _MascaraFormatter(this.formatar, this.maxDigitos);
  final String Function(String digitos) formatar;
  final int maxDigitos;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue antigo, TextEditingValue novo) {
    var d = novo.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > maxDigitos) d = d.substring(0, maxDigitos);
    final t = formatar(d);
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}
