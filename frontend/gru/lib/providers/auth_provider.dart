import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gru/providers/lixeira_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/usuario_model.dart';
import '../data/repositories/lixeira_repository.dart';
import '../data/repositories/usuario_repository.dart';

class AuthProvider extends ChangeNotifier {
  UsuarioModel? _usuario;
  UsuarioModel? _contratante;
  LixeiraProvider? _lixeiraProvider;
  dynamic _organizacao;
  final List<UsuarioModel> _coletores = [];

  AuthProvider(LixeiraProvider lixeiraProvider) {
    _lixeiraProvider = lixeiraProvider;
  }

  static const _chaveSessao = 'gru_sessao_usuario';

  bool _restaurando = true;
  bool _carregandoConta = false;
  String? _erroCarga;

  /// `true` enquanto o site confere se havia um login salvo (ao abrir/recarregar).
  bool get restaurando => _restaurando;
  bool get carregandoConta => _carregandoConta;

  /// Mensagem quando os dados da conta não puderam ser carregados do servidor.
  String? get erroCarga => _erroCarga;

  void definirUsuario(UsuarioModel usuario) {
    _usuario = usuario;
    _salvarSessao(usuario);
    notifyListeners();
  }

  // ── Sessão salva no navegador (sobrevive ao F5) ───────────────────────
  Future<void> _salvarSessao(UsuarioModel usuario) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chaveSessao, jsonEncode(usuario.toJson()));
    } catch (_) {}
  }

  Future<void> _limparSessao() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chaveSessao);
    } catch (_) {}
  }

  /// Chamado ao abrir o site: se houver login salvo, recarrega a conta.
  Future<void> restaurarSessao() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salvo = prefs.getString(_chaveSessao);
      if (salvo != null) {
        _usuario =
            UsuarioModel.fromJson(jsonDecode(salvo) as Map<String, dynamic>);
        await carregarConta();
      }
    } catch (_) {
      _usuario = null;
      await _limparSessao();
    } finally {
      _restaurando = false;
      notifyListeners();
    }
  }

  /// Busca no servidor a organização, os coletores e as lixeiras do usuário.
  /// Se o servidor falhar, deixa dados vazios e preenche [erroCarga].
  Future<void> carregarConta() async {
    final usuario = _usuario;
    if (usuario == null) return;

    _carregandoConta = true;
    _erroCarga = null;
    notifyListeners();

    final repo = UsuarioRepository();
    final repoLixeira = LixeiraRepository();
    Map<String, dynamic> org = {};

    try {
      final resposta = await repo.buscarOrganizacao(idContratante: usuario.id);
      if (resposta is Map) org = Map<String, dynamic>.from(resposta);

      _coletores.clear();
      final coletores = org['colectors'];
      if (coletores is List && coletores.isNotEmpty) {
        _adicionarColetores(await repo.buscarColetores(ids: coletores));
      }

      final trashes = org['trashes'];
      if (trashes is List && trashes.isNotEmpty) {
        _lixeiraProvider?.definirLixeiras(
            await repoLixeira.listar(codigoDonoLixeira: usuario.id));
      }
    } catch (_) {
      _erroCarga = 'Não foi possível carregar os dados do servidor.';
    } finally {
      org.putIfAbsent('colectors', () => []);
      org.putIfAbsent('trashes', () => []);
      org.putIfAbsent('history', () => []);
      _organizacao = org;
      _carregandoConta = false;
      notifyListeners();
    }
  }

  void definirContratante(UsuarioModel contratante) {
    _contratante = contratante;
    notifyListeners();
  }

  void definirOrganizacao(dynamic organizacao) {
    _organizacao = organizacao;
    notifyListeners();
  }

  void definirColetores(dynamic coletores) {
    _coletores.clear();
    _adicionarColetores(coletores);
    notifyListeners();
  }

  void _adicionarColetores(dynamic coletores) {
    coletores.forEach((coletor) {
      _coletores.add(UsuarioModel(id: coletor['_id'], nomeUsuario: coletor['nome_usuario'], emailUsuario: coletor['email_usuario'], telefoneUsuario: coletor['telefone_usuario'], cpfUsuario: coletor['cpf_usuario'], cargoUsuario: coletor['cargo_usuario'], instituicao: coletor['instituicao_usuario'], coletasRealizadas: coletor['coletas_realizadas']));
    });
  }

  void adicionarColetor(UsuarioModel coletor) {
    _coletores.add(coletor);
    notifyListeners();
  }

  void removerColetor(UsuarioModel coletor) {
    _coletores.remove(coletor);
    notifyListeners();
  }

  Future<List<UsuarioModel>> buscarColetores({String? termoBusca}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final todas = _coletores;
    if (termoBusca == null || termoBusca.trim().isEmpty) return todas;

    final termo = termoBusca.toLowerCase();
    return todas.where((l) => l.nomeUsuario.toLowerCase().contains(termo) || (l.id).toLowerCase().contains(termo)).toList();
  }

  void logout() {
    _limparSessao();
    _erroCarga = null;
    _usuario = null;
    _contratante = null;
    _organizacao = null;
    _lixeiraProvider?.limparLixeiras();
    _coletores.clear();
    notifyListeners();
  }

  UsuarioModel? get usuario => _usuario;
  UsuarioModel? get contratante => _contratante;
  dynamic get organizacao => _organizacao;
  List<UsuarioModel> get coletores => _coletores;
}