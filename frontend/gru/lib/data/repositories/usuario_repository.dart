import '../models/usuario_model.dart';

/// Repositório de autenticação/cadastro de usuário.
///
/// O backend ainda não tem rotas de login (`POST /users/login`) nem de
/// criação (`POST /users`) - só `GET /users/all-users`. Por isso o login e
/// o cadastro aqui são simulados (qualquer preenchimento válido "funciona").
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
