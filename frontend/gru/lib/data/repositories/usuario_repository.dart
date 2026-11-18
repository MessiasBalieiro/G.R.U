import 'package:http/http.dart' as http;
import 'dart:convert';

/// Repositório de autenticação/cadastro de usuário.
///
/// O backend ainda não tem rotas de login (`POST /users/login`) nem de
/// criação (`POST /users`) - só `GET /users/all-users`. Por isso o login e
/// o cadastro aqui são simulados (qualquer preenchimento válido "funciona").
///
/// Quando o backend tiver os endpoints reais, troque o corpo dos métodos
/// por chamadas HTTP mantendo a mesma assinatura.
class UsuarioRepository {
  Future<dynamic> login({required String email, required String senha}) async {
    final url = Uri.parse('https://backend-gru.vercel.app/users/login');

    final resposta = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'email_usuario': email,
        'senha_usuario': senha
      })
    );

    if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
      final dados = jsonDecode(resposta.body);
      return dados;
    }
    else if (resposta.statusCode == 200 && resposta.body.isEmpty) {
      return null;
    }
    else {
      throw Exception('Falha ao autenticar usuário');
    }
  }

  Future<dynamic> cadastrar({required String nome, required String email, required String telefone, required String cpf, required String senha, required String instituicao}) async {
    final url = Uri.parse('https://backend-gru.vercel.app/users/create-user');

    final resposta = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'nome_usuario': nome,
        'email_usuario': email,
        'telefone_usuario': telefone,
        'cpf_usuario': cpf,
        'senha_usuario': senha,
        'instituicao_usuario': instituicao,
        'cargo_usuario': 'CONTRATANTE'
      })
    );

    final dados = jsonDecode(resposta.body);

    if ((resposta.statusCode == 201 || resposta.statusCode == 200) && resposta.body.isNotEmpty) {
      final urlOrg = Uri.parse('https://backend-gru.vercel.app/organizations/create-org?rl=CONTRATANTE');

      final respostaOrg = await http.post(
        urlOrg,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'id_contratante': dados['_id'],
          'trashes': [],
          'colectors': [],
          'organization_name': instituicao,
          'history': []
        })
      );

      if ((respostaOrg.statusCode == 201 || respostaOrg.statusCode == 200) && respostaOrg.body.isNotEmpty) {
        return dados;
      }
      else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<dynamic> buscarUsuario({required String cpf, required String cargo}) async {
    final url = Uri.parse('https://backend-gru.vercel.app/users/this-user?rl=CONTRATANTE');

    final resposta = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'cpf_usuario': cpf,
        'cargo_usuario': cargo
      })
    );

    if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
      final dados = jsonDecode(resposta.body);
      return dados;
    } else if (resposta.statusCode == 200 && resposta.body.isEmpty) {
      return {};
    } else {
      throw Exception('Falha ao buscar contratante');
    }
  }

  Future<dynamic> buscarOrganizacao({required String idContratante}) async {
    final url = Uri.parse('https://backend-gru.vercel.app/organizations/this-org?rl=CONTRATANTE&idCon=$idContratante');

    final resposta = await http.get(
      url,
    );

    if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
      final dados = jsonDecode(resposta.body);

      return dados;
    } else if (resposta.statusCode == 200 && resposta.body.isEmpty) {
      return {};
    } else {
      throw Exception('Falha ao buscar organização');
    }
  }

  Future<dynamic> buscarColetores({required List<dynamic> ids}) async {
    final url = Uri.parse('https://backend-gru.vercel.app/users/this-colectors');

    final resposta = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'ids': ids
      })
    );

    if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
      final dados = jsonDecode(resposta.body);

      return dados;
    } else if (resposta.statusCode == 200 && resposta.body.isEmpty) {
      return {};
    } else {
      throw Exception('Falha ao buscar organização');
    }
  }

  Future<dynamic> adicionarColetorParaOrganizacao({required String cpf, required String idOrg}) async {
    final url = Uri.parse('https://backend-gru.vercel.app/organizations/add-colector?rl=CONTRATANTE');

    final resposta = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'cltCpf': cpf,
        'idOrg': idOrg
      })
    );

    if (resposta.statusCode == 200 && resposta.body != "") {
      final dados = resposta.body;
      return dados;
    } else {
      throw Exception('Falha ao adicionar coletor para organização');
    }
  }

  Future<dynamic> removerColetorDaOrganizacao({required String cltCpf, required String idOrg}) async {
    final url = Uri.parse('https://backend-gru.vercel.app/organizations/remove-colector?rl=CONTRATANTE');

    final resposta = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'cltId': cltCpf,
        'idOrg': idOrg
      })
    );

    if (resposta.statusCode == 200 && resposta != "") {
      final dados = resposta;
      return dados;
    } else {
      throw Exception('Falha ao adicionar coletor para organização');
    }
  }
}
