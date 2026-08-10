import '../models/usuario_model.dart';

/// Repositório de autenticação/cadastro de usuário.
///
/// Quando o backend tiver os endpoints reais, troque o corpo dos métodos
/// por chamadas HTTP mantendo a mesma assinatura.
class UsuarioRepository {
  Future<bool> login({required String email, required String senha}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return email.trim().isNotEmpty && senha.trim().isNotEmpty;
  }

  Future<bool> cadastrar(UsuarioModel usuario) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }
}
