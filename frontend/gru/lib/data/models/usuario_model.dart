/// Espelha o schema `user.model.js` do backend (coleção `Usuarios`).
class UsuarioModel {
  const UsuarioModel({
    required this.id,
    required this.nomeUsuario,
    required this.emailUsuario,
    required this.telefoneUsuario,
    required this.cpfUsuario,
    required this.cargoUsuario,
    required this.instituicao,
    required this.coletasRealizadas,
  });

  final String id;
  final String nomeUsuario;
  final String emailUsuario;
  final String telefoneUsuario;
  final String cpfUsuario;
  final String cargoUsuario;
  final String? instituicao;
  final int coletasRealizadas;

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['_id'] as String,
      nomeUsuario: json['nome_usuario'] as String? ?? '',
      emailUsuario: json['email_usuario'] as String? ?? '',
      telefoneUsuario: json['telefone_usuario'] as String? ?? '',
      cpfUsuario: json['cpf_usuario'] as String? ?? '',
      instituicao: json['instituicao_usuario'] as String? ?? '',
      cargoUsuario: json['cargo_usuario'] as String? ?? '',
      coletasRealizadas: json['coletas_realizadas'] as int? ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nome_usuario': nomeUsuario,
      'email_usuario': emailUsuario,
      'telefone_usuario': telefoneUsuario,
      'cpf_usuario': cpfUsuario,
      'cargo_usuario': cargoUsuario,
      'instituicao_usuario': instituicao,
      'coletas_realizadas': coletasRealizadas
    };
  }
}
