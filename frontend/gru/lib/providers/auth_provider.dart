import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gru/providers/lixeira_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/usuario_model.dart';
import '../data/repositories/lixeira_repository.dart';
import '../data/repositories/usuario_repository.dart';
import '../data/services/demo_data.dart';

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
  bool _dadosExemplo = false;
  String? _erroCarga;

  /// `true` enquanto o site confere se havia um login salvo (ao abrir/recarregar).
  bool get restaurando => _restaurando;
  bool get carregandoConta => _carregandoConta;

  /// `true` quando o servidor falhou e a tela mostra dados de exemplo.
  bool get usandoDadosExemplo => _dadosExemplo;

  /// Mensagem de erro de carga (hoje o servidor com falha usa dados de exemplo).
  String? get erroCarga => _erroCarga;

  void _carregarExemplo() {
    _dadosExemplo = true;
    _coletores.clear();
    _adicionarColetores(DemoData.coletores());
    _lixeiraProvider?.definirLixeiras(DemoData.lixeiras());
    _organizacao = DemoData.organizacao();
  }

  void definirUsuario(UsuarioModel usuario) {
    _dadosExemplo = false;
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
  ///
  /// Com [silencioso] (atualização automática) não mostra carregamento e, se
  /// falhar, mantém os dados que já estavam na tela.
  Future<void> carregarConta({bool silencioso = false}) async {
    final usuario = _usuario;
    if (usuario == null) return;

    if (!silencioso) {
      _carregandoConta = true;
      _erroCarga = null;
      notifyListeners();
    }

    final repo = UsuarioRepository();
    final repoLixeira = LixeiraRepository();
    Map<String, dynamic> org = {};
    var falhou = false;
    List<dynamic>? coletoresNovos;
    dynamic lixeirasNovas;

    try {
      final resposta = await repo.buscarOrganizacao(idContratante: usuario.id);
      if (resposta is Map) org = Map<String, dynamic>.from(resposta);

      final coletores = org['colectors'];
      if (coletores is List && coletores.isNotEmpty) {
        coletoresNovos = await repo.buscarColetores(ids: coletores);
      }

      final trashes = org['trashes'];
      if (trashes is List && trashes.isNotEmpty) {
        lixeirasNovas =
            await repoLixeira.listar(codigoDonoLixeira: usuario.id);
      } else {
        lixeirasNovas = [];
      }
    } catch (_) {
      falhou = true;
    }

    // Se o usuário saiu da conta (ou entrou na demo) durante a espera, descarta.
    if (_usuario?.id != usuario.id) {
      _carregandoConta = false;
      return;
    }

    if (falhou) {
      // Servidor com problema: mostra dados de exemplo (com aviso na tela).
      if (!silencioso) _carregarExemplo();
    } else {
      _erroCarga = null;
      _dadosExemplo = false;
      _coletores.clear();
      if (coletoresNovos != null) _adicionarColetores(coletoresNovos);
      if (lixeirasNovas != null) _lixeiraProvider?.definirLixeiras(lixeirasNovas);
      org.putIfAbsent('colectors', () => []);
      org.putIfAbsent('trashes', () => []);
      org.putIfAbsent('history', () => []);
      _organizacao = org;
    }
    _carregandoConta = false;
    notifyListeners();
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
    _dadosExemplo = false;
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