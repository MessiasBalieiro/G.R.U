import 'dart:async';
import 'dart:convert';

import 'package:gru_app/providers/lixeira_provider.dart';
import 'package:gru_app/providers/user_provider.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../models/ciclo_model.dart';
import '../models/usuario_model.dart';

class CicloException implements Exception {
  CicloException(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Comunicação com o Ciclo (backend `POST /ciclo/chat`).
///
/// A chave do LLM fica SÓ no servidor: o app nunca a conhece. O app envia a
/// pergunta, o histórico e o "snapshot" do Dashboard (os mesmos números dos
/// gráficos), e o servidor faz o RAG + agente.
class CicloService {
  CicloService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<CicloResposta> perguntar({
    required String pergunta,
    required Map<String, dynamic> snapshot,
    List<CicloMensagem> historico = const [],
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/ciclo/chat');
    try {
      final resp = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'pergunta': pergunta,
              'snapshot': snapshot,
              'historico': historico
                  .where((m) => !m.erro)
                  .map((m) => m.toJson())
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 45));

      final json = jsonDecode(utf8.decode(resp.bodyBytes));
      if (resp.statusCode != 200) {
        throw CicloException(
          (json is Map && json['erro'] is String)
              ? json['erro'] as String
              : 'O Ciclo não conseguiu responder agora.',
        );
      }
      return CicloResposta.fromJson(json as Map<String, dynamic>);
    } on CicloException {
      rethrow;
    } on TimeoutException {
      throw CicloException('O Ciclo demorou demais para responder. Tente de novo.');
    } catch (_) {
      throw CicloException(
        'Não consegui falar com o servidor do Ciclo (${ApiConfig.baseUrl}). '
        'Verifique se o backend está rodando e se o celular está na mesma rede.',
      );
    }
  }

  // Monta o snapshot com os MESMOS dados/fórmulas dos gráficos do Dashboard.

  static Map<String, dynamic> montarSnapshot(AuthProvider authProvider, LixeiraProvider lixeiraProvider) {
    // final db = MockDataService.instance;
    // final lixeiras = db.lixeirasDasInstituicoes(admin.instituicaoIds);
    final lixeiras = lixeiraProvider.lixeiras;
    // final instId = admin.instituicaoPrincipalId;
    // final instId = authProvider.organizacao['_id'];
    final ranking = <({UsuarioModel coletor, int coletas})>[];
    final inst = authProvider.organizacao;
    final visitas = authProvider.organizacao['history'];
    final agora = DateTime.now();


    for (final c in authProvider.coletores) {
      final n = c.coletasRealizadas;
      ranking.add((coletor: c, coletas: n));
    }

    if(ranking.isNotEmpty) {
      ranking.sort((a, b) => b.coletas.compareTo(a.coletas));
    }


    final media = lixeiras.isEmpty
        ? 0
        : (lixeiras.map((l) => l.quantidadeResiduo).reduce((a, b) => a + b) /
                lixeiras.length)
            .round();
    // final limite = agora.subtract(const Duration(days: 30));

    // Composição geral ponderada pela ocupação (igual ao gráfico de rosca).
    final soma = lixeiras.fold(0, (soma, lixeira) => soma + lixeira.quantidadeResiduo);
    final somaPlastico = lixeiras.fold(0, (soma, lixeira) => soma + lixeira.composicao['quantPlastico']!);
    final somaVidro = lixeiras.fold(0, (soma, lixeira) => soma + lixeira.composicao['quantVidro']!);
    final somaMetal = lixeiras.fold(0, (soma, lixeira) => soma + lixeira.composicao['quantMetal']!);
    final somaPapel = lixeiras.fold(0, (soma, lixeira) => soma + lixeira.composicao['quantPapel']!);

    // final soma = {for (final t in TipoResiduo.values) t: 0.0};

    // for (final l in lixeiras) {
    //   l.composicao.forEach((t, pct) => soma[t] = soma[t]! + l.ocupacao * pct / 100);
    // }

    return {
      'instituicao': inst['organization_name'] ?? 'Minha instituição',
      'geradoEm': agora.toUtc().toIso8601String(),
      'kpis': {
        'lixeiras': lixeiras.length,
        'ocupacaoMedia': media,
        'paraColetar': lixeiras.where((l) => l.statusLixeira.codigo >= 3).length,
        'coletas30d': visitas.length,
      },
      'lixeiras': [
        for (final l in lixeiras)
          {
            'id': l.id,
            'nome': l.nomeLixeira,
            'endereco': l.enderecoLixeira,
            'cep': "",
            'ocupacao': l.quantidadeResiduo,
            'status': l.statusLixeira.label,
            'composicao': {
              for (final e in l.composicao.entries) e.key: e.value,
            },
          },
      ],
      'composicaoGeral': {
          "quantPlastico": (somaPlastico * 100) / soma,
          "quantVidro": (somaVidro * 100) / soma,
          "quantMetal": (somaMetal * 100) / soma,
          "quantPapel": (somaPapel * 100) / soma
          // "Papel": (l.composicao['quantPapel']! * 100) / l.quantidadeResiduo
      },
      'ranking': [
        if (ranking.isEmpty)
          for (final r in ranking)
            {'nome': r.coletor.nomeUsuario, 'coletas': r.coletas},
      ],
      'atividades': [
        for (final v in visitas.take(10))
          {
            'coletor': v.coletorNome,
            'lixeira': v.lixeiraNome,
            'dataHora': v.dataHora.toUtc().toIso8601String(),
            'ocupacao': v.ocupacao,
          },
      ],
    };
  }
}

      // 'composicaoGeral': {
      //   for (final e in soma.entries)
      //     e.key.label: total == 0 ? 0 : (e.value / total * 100).round(),
      // },