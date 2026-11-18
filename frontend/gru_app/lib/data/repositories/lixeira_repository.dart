import 'dart:convert';
import 'package:http/http.dart' as http;

/// Repositório de Lixeiras.
///
/// Hoje delega para [MockDataService]. Quando o backend expuser
/// `POST /trashes` e `GET /trashes/:id`, basta trocar a implementação
/// dos métodos abaixo para chamadas HTTP - as telas não precisam mudar.
class LixeiraRepository {
  Future<dynamic> listar({required String codigoDonoLixeira}) async {
    // final todas = MockDataService.instance.lixeiras;
    final url = Uri.parse("https://backend-gru.vercel.app/trashes/all-trashes-by-user?userId=$codigoDonoLixeira");

    final resposta = await http.get(url);

    if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
      final dados = jsonDecode(resposta.body);
      return dados;
    } 
    else if (resposta.statusCode == 200 && resposta.body.isEmpty) {
      return null;
    } 
    else {
      throw Exception('Falha ao buscar lixeiras do usuário');
    }
  }

  Future<dynamic> cadastrar(String cpfContratante, String nomeContratante, String nomeLixeira, String enderecoLixeira, String coordenada, String idOrg) async {
    final url = Uri.parse("https://backend-gru.vercel.app/organizations/add-trash?rl=ADMINISTRADOR");

    final resposta = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'cpf_contratante': cpfContratante,
        'nome_contratante': nomeContratante,
        'nome_lixeira': nomeLixeira,
        'endereco_lixeira': enderecoLixeira,
        'coordenada': coordenada,
        'status_lixeira': 0,
        'idOrg': idOrg
      })
    );

    if (resposta.statusCode == 201 || resposta.statusCode == 200) {
      return jsonDecode(resposta.body);
    } 
    else {
      throw Exception('Falha ao cadastrar lixeira');
    }
  }

  Future<dynamic> coletarLixeira(String trashId, String idColector, String nameColector, String organizationId) async {
    final url = Uri.parse("https://backend-gru.vercel.app/trashes/colect-trash");

    final resposta = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'trashId': trashId,
        'residuos': -1,
        'idColector': idColector,
        'nameColector': nameColector,
        'organizationId': organizationId,
        'tipoResiduo': ""
      })
    );

    if (resposta.statusCode == 201 || resposta.statusCode == 200) {
      return jsonDecode(resposta.body);
    } 
    else {
      throw Exception('Falha ao cadastrar lixeira');
    }
  }


}