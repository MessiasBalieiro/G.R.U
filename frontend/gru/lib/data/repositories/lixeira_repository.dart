import '../models/lixeira_model.dart';
import '../services/mock_data_service.dart';

/// Repositório de Lixeiras.
///
/// Hoje delega para [MockDataService]. Quando o backend expuser
/// `POST /trashes` e `GET /trashes/:id`, basta trocar a implementação
/// dos métodos abaixo para chamadas HTTP - as telas não precisam mudar.
class LixeiraRepository {
  Future<List<LixeiraModel>> listar({String? termoBusca}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final todas = MockDataService.instance.lixeiras;
    if (termoBusca == null || termoBusca.trim().isEmpty) return todas;

    final termo = termoBusca.toLowerCase();
    return todas
        .where((l) =>
            l.nome.toLowerCase().contains(termo) ||
            (l.id ?? '').toLowerCase().contains(termo))
        .toList();
  }

  Future<void> cadastrar(LixeiraModel lixeira) async {
    await Future.delayed(const Duration(milliseconds: 200));
    MockDataService.instance.adicionarLixeira(lixeira);
  }
}
