import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../models/ciclo_model.dart';
import '../models/residuo_model.dart';
import '../models/usuario_model.dart';
import 'mock_data_service.dart';

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

  /// Monta o snapshot com os MESMOS dados/fórmulas dos gráficos do Dashboard.
  static Map<String, dynamic> montarSnapshot(UsuarioModel admin) {
    final db = MockDataService.instance;
    final lixeiras = db.lixeirasDasInstituicoes(admin.instituicaoIds);
    final instId = admin.instituicaoPrincipalId;
    final inst = instId == null ? null : db.instituicaoPorId(instId);
    final visitas = db.visitasDasInstituicoes(admin.instituicaoIds);
    final agora = DateTime.now();

    final media = lixeiras.isEmpty
        ? 0
        : (lixeiras.map((l) => l.ocupacao).reduce((a, b) => a + b) /
                lixeiras.length)
            .round();
    final limite = agora.subtract(const Duration(days: 30));

    // Composição geral ponderada pela ocupação (igual ao gráfico de rosca).
    final soma = {for (final t in TipoResiduo.values) t: 0.0};
    for (final l in lixeiras) {
      l.composicao.forEach((t, pct) => soma[t] = soma[t]! + l.ocupacao * pct / 100);
    }
    final total = soma.values.fold<double>(0, (a, b) => a + b);

    return {
      'instituicao': inst?.nome ?? 'Minha instituição',
      'geradoEm': agora.toUtc().toIso8601String(),
      'kpis': {
        'lixeiras': lixeiras.length,
        'ocupacaoMedia': media,
        'paraColetar': lixeiras.where((l) => l.status.codigo >= 3).length,
        'coletas30d': visitas.where((v) => v.dataHora.isAfter(limite)).length,
      },
      'lixeiras': [
        for (final l in lixeiras)
          {
            'id': l.id,
            'nome': l.nome,
            'endereco': l.endereco,
            'cep': l.cepFormatado,
            'ocupacao': l.ocupacao,
            'status': l.status.label,
            'composicao': {
              for (final e in l.composicao.entries) e.key.label: e.value,
            },
            'ultimaColeta': l.ultimaColeta?.toUtc().toIso8601String(),
          },
      ],
      'composicaoGeral': {
        for (final e in soma.entries)
          e.key.label: total == 0 ? 0 : (e.value / total * 100).round(),
      },
      'ranking': [
        if (instId != null)
          for (final r in db.ranking(instId))
            {'nome': r.coletor.nome, 'coletas': r.coletas},
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
