import '../models/usuario_model.dart';

/// Guarda o usuário logado (em memória).
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  UsuarioModel? usuario;

  bool get logado => usuario != null;

  void entrar(UsuarioModel u) => usuario = u;

  void sair() => usuario = null;
}
