import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/utils/cep.dart';

class CepException implements Exception {
  CepException(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Endereço devolvido pela consulta de CEP.
class EnderecoCep {
  const EnderecoCep({
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  final String cep;
  final String logradouro;
  final String bairro;
  final String cidade;
  final String uf;
}

/// Consulta de CEP na API pública ViaCEP (https://viacep.com.br).
/// Precisa de internet e da permissão INTERNET no AndroidManifest.
class CepService {
  Future<EnderecoCep> buscar(String cep) async {
    final d = Cep.digitos(cep);
    if (d.length != 8) throw CepException('O CEP deve ter 8 dígitos.');

    try {
      final resp = await http
          .get(Uri.parse('https://viacep.com.br/ws/$d/json/'))
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 400) throw CepException('CEP inválido.');
      if (resp.statusCode != 200) {
        throw CepException('Não foi possível consultar o CEP agora.');
      }

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      if (json['erro'] == true || json['erro'] == 'true') {
        throw CepException('CEP não encontrado.');
      }

      String campo(String k) => ((json[k] ?? '') as String).trim();
      return EnderecoCep(
        cep: Cep.formatar(d),
        logradouro: campo('logradouro'),
        bairro: campo('bairro'),
        cidade: campo('localidade'),
        uf: campo('uf'),
      );
    } on CepException {
      rethrow;
    } on TimeoutException {
      throw CepException('A consulta demorou demais.');
    } catch (_) {
      throw CepException('Sem conexão para consultar o CEP.');
    }
  }
}
