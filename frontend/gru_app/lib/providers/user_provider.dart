import 'package:flutter/material.dart';
import 'package:gru_app/providers/lixeira_provider.dart';
import '../data/models/usuario_model.dart';

class AuthProvider extends ChangeNotifier {
  UsuarioModel? _usuario;
  UsuarioModel? _contratante;
  LixeiraProvider? _lixeiraProvider;
  dynamic _organizacao;
  
  final List<dynamic> _organizacoes = [];
  final List<UsuarioModel> _coletores = [];

  AuthProvider(LixeiraProvider lixeiraProvider) {
    _lixeiraProvider = lixeiraProvider;
  }

  void definirUsuario(UsuarioModel usuario) {
    _usuario = usuario;
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

  void definirOrganizacoes(dynamic organizacao) {
    _organizacoes.add(organizacao);
    notifyListeners();
  }

  void definirColetores(dynamic coletores) {
    coletores.forEach((coletor) {
      _coletores.add(UsuarioModel(id: coletor['_id'], nomeUsuario: coletor['nome_usuario'], emailUsuario: coletor['email_usuario'], telefoneUsuario: coletor['telefone_usuario'], cpfUsuario: coletor['cpf_usuario'], cargoUsuario: coletor['cargo_usuario'], instituicao: coletor['instituicao_usuario'], coletasRealizadas: coletor['coletas_realizadas'], history: coletor['history'], instituicoes: coletor['instituicoes']));
    });
    notifyListeners();
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

  void adicionarHistorico(String action, String timeAction, String trashId, String trashName) {
    _usuario?.history.add({
      "action": action,
      "time_action": timeAction,
      "trash_id": trashId,
      "trash_name": trashName
    });

    notifyListeners();
  }

  void logout() {
    _usuario = null;
    _contratante = null;
    _organizacao = null;
    _organizacoes.clear();
    _lixeiraProvider?.limparLixeiras();
    _coletores.clear();
    notifyListeners();
  }

  UsuarioModel? get usuario => _usuario;
  UsuarioModel? get contratante => _contratante;
  dynamic get organizacao => _organizacao;
  List<dynamic> get organizacoes => _organizacoes;
  List<UsuarioModel> get coletores => _coletores;
}