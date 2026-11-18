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
  bool _modoDemo = false;
  String? _erroCarga;

  /// `true` enquanto o site confere se havia um login salvo (ao abrir/recarregar).
  bool get restaurando => _restaurando;
  bool get carregandoConta => _carregandoConta;

  /// `true` no modo demonstração (dados de exemplo, sem servidor).
  bool get modoDemo => _modoDemo;

  /// Entra com dados de exemplo, sem precisar de conta nem do servidor.
  void entrarModoDemo() {
    _modoDemo = true;
    _erroCarga = null;
    _usuario = UsuarioModel.fromJson(DemoData.usuario());
    _coletores.clear();
    _adicionarColetores(DemoData.coletores());
    _lixeiraProvider?.definirLixeiras(DemoData.lixeiras());
    _organizacao = DemoData.organizacao();
    _restaurando = false;
    notifyListeners();
  }

  /// Mensagem quando os dados da conta não puderam ser carregados do servidor.
  String? get erroCarga => _erroCarga;

  void definirUsuario(UsuarioModel usuario) {
    _modoDemo = false;
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
    if (usuario == null || _modoDemo) return;

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
    if (_usuario?.id != usuario.id || _modoDemo) {
      _carregandoConta = false;
      return;
    }

    if (falhou) {
      if (!silencioso) {
        _erroCarga = 'Não foi possível carregar os dados do servidor.';
        _organizacao ??= {'colectors': [], 'trashes': [], 'history': []};
      }
    } else {
      _erroCarga = null;
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
    _modoDemo = false;
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