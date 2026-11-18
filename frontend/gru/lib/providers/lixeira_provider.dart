import 'package:flutter/material.dart';
import '../data/models/lixeira_model.dart';

class LixeiraProvider extends ChangeNotifier {
  final List<LixeiraModel> _lixeiras = [];

  List<LixeiraModel> get lixeiras => _lixeiras;

  void definirLixeiras(dynamic lixeiras) {
    lixeiras.forEach((lixeira) {
      _lixeiras.add(LixeiraModel(id: lixeira['_id'], nomeLixeira: lixeira['nome_lixeira'], codigoDonoLixeira: lixeira['codigo_dono_lixeira'], enderecoLixeira: lixeira['endereco_lixeira'], coordenada: lixeira['coordenada'], quantidadeResiduo: lixeira['quantidade_residuo'] ?? 0, statusLixeira: StatusLixeira.fromCodigo(lixeira['status_lixeira'])));
    });
    notifyListeners();
  }

  void adicionarLixeira(LixeiraModel lixeira) {
    _lixeiras.add(lixeira);
    notifyListeners();
  }

  void limparLixeiras() {
    _lixeiras.clear();
    notifyListeners();
  }

  Future<List<LixeiraModel>> buscarLixeiras({String? termoBusca}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final todas = _lixeiras;
    if (termoBusca == null || termoBusca.trim().isEmpty) return todas;

    final termo = termoBusca.toLowerCase();
    return todas
        .where((l) =>
            l.nomeLixeira.toLowerCase().contains(termo) ||
            (l.id).toLowerCase().contains(termo))
        .toList();
  }
}