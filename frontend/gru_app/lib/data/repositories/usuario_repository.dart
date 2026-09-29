import '../models/usuario_model.dart';
import '../services/mock_data_service.dart';

class AuthException implements Exception {
  AuthException(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Login e cadastro. Hoje usa o [MockDataService]; quando o backend tiver
/// `POST /users/login` e `POST /users`, troque só o corpo dos métodos.
class UsuarioRepository {
  final _db = MockDataService.instance;

  Future<UsuarioModel> login({
    required String email,
    required String senha,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final u = _db.autenticar(email, senha);
    if (u == null) throw AuthException('E-mail ou senha incorretos.');
    return u;
  }

  Future<UsuarioModel> cadastrarAdministrador({
    required String email,
    required String nome,
    required String senha,
    required String instituicao,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_db.usuarioPorEmail(email) != null) {
      throw AuthException('Este e-mail já está cadastrado.');
    }
    final inst = _db.criarInstituicao(instituicao);
    return _db.registrarUsuario(
      nome: nome,
      email: email,
      senha: senha,
      tipo: TipoUsuario.administrador,
      instituicaoId: inst.id,
    );
  }

  Future<UsuarioModel> cadastrarColetor({
    required String email,
    required String nome,
    required String senha,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_db.usuarioPorEmail(email) != null) {
      throw AuthException('Este e-mail já está cadastrado.');
    }
    return _db.registrarUsuario(
      nome: nome,
      email: email,
      senha: senha,
      tipo: TipoUsuario.coletor,
    );
  }
}
