/// Espelha o schema `user.model.js` do backend (coleção `Usuarios`).
class UsuarioModel {
  const UsuarioModel({
    this.id,
    required this.nomeUsuario,
    required this.emailUsuario,
    required this.telefoneUsuario,
    required this.cpfUsuario,
    required this.senhaUsuario,
    this.instituicao,
  });

  final String? id;
  final String nomeUsuario;
  final String emailUsuario;
  final String telefoneUsuario;
  final String cpfUsuario;
  final String senhaUsuario;

  /// Campo extra usado na tela de Cadastro do app (não existe ainda no
  /// schema do backend - foi incluído aqui para bater com o design;
  /// adicione `instituicao_usuario` no `user.model.js` para persistir).
  final String? instituicao;

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['_id'] as String?,
      nomeUsuario: json['nome_usuario'] as String? ?? '',
      emailUsuario: json['email_usuario'] as String? ?? '',
      telefoneUsuario: json['telefone_usuario'] as String? ?? '',
      cpfUsuario: json['cpf_usuario'] as String? ?? '',
      senhaUsuario: json['senha_usuario'] as String? ?? '',
      instituicao: json['instituicao_usuario'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'nome_usuario': nomeUsuario,
      'email_usuario': emailUsuario,
      'telefone_usuario': telefoneUsuario,
      'cpf_usuario': cpfUsuario,
      'senha_usuario': senhaUsuario,
      if (instituicao != null) 'instituicao_usuario': instituicao,
    };
  }
}
