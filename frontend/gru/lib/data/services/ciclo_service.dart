import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../models/ciclo_model.dart';
import '../models/lixeira_model.dart';
import 'mock_data_service.dart';

class CicloException implements Exception {
  CicloException(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Comunicação com o Ciclo (backend `POST /ciclo/chat`).
///
/// A chave do LLM fica SÓ no servidor: o site nunca a conhece (qualquer
/// pessoa conseguiria lê-la no JavaScript do navegador). O site envia a
/// pergunta, o histórico e o "snapshot" do Dashboard, e o servidor faz o
/// RAG + agente.
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
        'Verifique se o backend está rodando.',
      );
    }
  }

  /// Ocupação (%) exatamente como o gráfico de barras do site desenha:
  /// `(código do status + 1) / 5`.
  static int ocupacaoDoGrafico(LixeiraModel l) =>
      ((l.statusLixeira.codigo + 1) * 20);

  /// Monta o snapshot com os MESMOS dados/fórmulas dos gráficos do site.
  static Map<String, dynamic> montarSnapshot() {
    final db = MockDataService.instance;
    final lixeiras = db.lixeiras;
    final sensores = MockDataService.sensores;
    final coletores = MockDataService.coletores;

    final media = lixeiras.isEmpty
        ? 0
        : (lixeiras.map(ocupacaoDoGrafico).reduce((a, b) => a + b) /
                lixeiras.length)
            .round();

    // Composição geral ponderada pela ocupação de cada lixeira.
    final soma = <String, double>{};
    for (final l in lixeiras) {
      final comp = sensores[l.id]?.composicao ?? const <String, int>{};
      comp.forEach((tipo, pct) =>
          soma[tipo] = (soma[tipo] ?? 0) + ocupacaoDoGrafico(l) * pct / 100);
    }
    final total = soma.values.fold<double>(0, (a, b) => a + b);

    return {
      'instituicao': 'Minha instituição',
      'geradoEm': DateTime.now().toUtc().toIso8601String(),
      'kpis': {
        'lixeiras': lixeiras.length,
        'ocupacaoMedia': media,
        'paraColetar':
            lixeiras.where((l) => l.statusLixeira.codigo >= 3).length,
        'coletores': coletores.length,
        'coletasSemana':
            coletores.fold<int>(0, (t, c) => t + c.coletasRealizadas),
      },
      'lixeiras': [
        for (final l in lixeiras)
          {
            'id': l.id,
            'nome': l.nome,
            'endereco': l.enderecoLixeira,
            'ocupacao': ocupacaoDoGrafico(l),
            'status': l.statusLixeira.label,
            'composicao': sensores[l.id]?.composicao ?? const <String, int>{},
            'ultimaColeta':
                sensores[l.id]?.ultimaColeta.toUtc().toIso8601String(),
          },
      ],
      'composicaoGeral': {
        for (final e in soma.entries)
          e.key: total == 0 ? 0 : (e.value / total * 100).round(),
      },
      'ranking': [
        for (final c in [...coletores]
          ..sort((a, b) => b.coletasRealizadas.compareTo(a.coletasRealizadas)))
          {'nome': c.nome, 'coletas': c.coletasRealizadas},
      ],
      // Mesmas atividades mostradas no card "Atividades recentes".
      'atividades': const [
        {'descricao': 'Lixeira Central coletada', 'quando': 'Há 2h'},
        {'descricao': 'Lixeira Campus Norte: nível alto', 'quando': 'Há 4h'},
        {'descricao': 'Nova lixeira cadastrada', 'quando': 'Há 1d'},
        {'descricao': 'Coleta do Terminal concluída', 'quando': 'Há 1d'},
      ],
    };
  }
}
