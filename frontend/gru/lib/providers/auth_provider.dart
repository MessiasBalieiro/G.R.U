import 'package:flutter/material.dart';
import 'package:gru/providers/lixeira_provider.dart';
import '../data/models/usuario_model.dart';

class AuthProvider extends ChangeNotifier {
  UsuarioModel? _usuario;
  UsuarioModel? _contratante;
  LixeiraProvider? _lixeiraProvider;
  dynamic _organizacao;
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

  void definirColetores(dynamic coletores) {
    coletores.forEach((coletor) {
      _coletores.add(UsuarioModel(id: coletor['_id'], nomeUsuario: coletor['nome_usuario'], emailUsuario: coletor['email_usuario'], telefoneUsuario: coletor['telefone_usuario'], cpfUsuario: coletor['cpf_usuario'], cargoUsuario: coletor['cargo_usuario'], instituicao: coletor['instituicao_usuario'], coletasRealizadas: coletor['coletas_realizadas']));
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

  void logout() {
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