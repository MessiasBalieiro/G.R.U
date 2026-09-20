/// Tipos de usuário do app.
enum TipoUsuario {
  administrador('Administrador'),
  coletor('Coletor');

  const TipoUsuario(this.label);
  final String label;
}

/// Usuário do app (Administrador ou Coletor).
///
/// Espelha `user.model.js` (nome/e-mail/senha) e acrescenta [tipo] e
/// [vinculos] (instituição → data em que o vínculo começou). O administrador
/// tem um vínculo (a instituição que ele gerencia); o coletor pode ter vários.
class UsuarioModel {
  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.tipo,
    Map<String, DateTime>? vinculos,
  }) : vinculos = vinculos ?? <String, DateTime>{};

  final String id;
  final String nome;
  final String email;
  final String senha;
  final TipoUsuario tipo;

  /// instituicaoId → data do vínculo.
  final Map<String, DateTime> vinculos;

  bool get ehAdmin => tipo == TipoUsuario.administrador;
  bool get ehColetor => tipo == TipoUsuario.coletor;

  List<String> get instituicaoIds => vinculos.keys.toList();

  String? get instituicaoPrincipalId =>
      vinculos.isEmpty ? null : vinculos.keys.first;

  String get primeiroNome {
    final partes = nome.trim().split(RegExp(r'\s+'));
    return partes.isEmpty ? nome : partes.first;
  }

  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'nome_usuario': nome,
        'email_usuario': email,
        'senha_usuario': senha,
        'tipo_usuario': tipo.label,
        'instituicoes': vinculos.keys.toList(),
      };
}
