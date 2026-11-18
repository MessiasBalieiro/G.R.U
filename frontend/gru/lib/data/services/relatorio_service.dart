import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/lixeira_model.dart';
import '../models/residuo_model.dart';

class RelatorioResumoItem {
  const RelatorioResumoItem(this.rotulo, this.valor);
  final String rotulo;
  final String valor;
}

class RelatorioBarra {
  const RelatorioBarra(this.rotulo, this.valor, this.fracao);
  final String rotulo;

  /// Texto mostrado ao lado da barra (ex.: "45%").
  final String valor;

  /// Tamanho da barra, de 0.0 a 1.0.
  final double fracao;
}

class RelatorioEvento {
  const RelatorioEvento(this.texto, this.quando);
  final String texto;
  final String quando;
}

/// Tudo o que um relatório mostra (na tela e no PDF).
class RelatorioDados {
  const RelatorioDados({
    required this.titulo,
    required this.instituicao,
    required this.geradoEm,
    this.resumo = const [],
    this.tituloBarras = '',
    this.barras = const [],
    this.colunas = const [],
    this.linhas = const [],
    this.tituloEventos = '',
    this.eventos = const [],
    this.aviso,
  });

  final String titulo;
  final String instituicao;
  final DateTime geradoEm;
  final List<RelatorioResumoItem> resumo;
  final String tituloBarras;
  final List<RelatorioBarra> barras;
  final List<String> colunas;
  final List<List<String>> linhas;
  final String tituloEventos;
  final List<RelatorioEvento> eventos;

  /// Mensagem quando não há dados para mostrar.
  final String? aviso;

  bool get vazio => linhas.isEmpty;
}

/// Monta os relatórios a partir dos MESMOS dados do Dashboard
/// (lixeiras, coletores e histórico da instituição).
class RelatorioService {
  RelatorioService._();

  static const _capacidade = 120;

  /// Ocupação de 0.0 a 1.0, igual ao gráfico "Ocupação por lixeira".
  static double _ocupacao(LixeiraModel l) =>
      (l.quantidadeResiduo / _capacidade).clamp(0.0, 1.0).toDouble();

  static String _pct(double f) => '${(f * 100).round()}%';

  static List<Map<dynamic, dynamic>> _eventos(List<dynamic> history) => [
        for (final h in history)
          if (h is Map) h,
      ];

  // ── Utilização das lixeiras ────────────────────────────────────────────
  static RelatorioDados utilizacao({
    required String instituicao,
    required List<LixeiraModel> lixeiras,
    required List<dynamic> history,
  }) {
    final eventos = _eventos(history);
    final contagem = <String, int>{
      for (final l in lixeiras)
        l.id: eventos
            .where((h) =>
                h['type_object'] == 'Lixeiras' &&
                h['id_object']?.toString() == l.id)
            .length,
    };
    final total = contagem.values.fold<int>(0, (a, b) => a + b);
    final maior = contagem.values.fold<int>(0, (a, b) => a > b ? a : b);

    LixeiraModel? maisUsada;
    for (final l in lixeiras) {
      if (maior > 0 && contagem[l.id] == maior) {
        maisUsada = l;
        break;
      }
    }

    final ordenadas = [...lixeiras]
      ..sort((a, b) => contagem[b.id]!.compareTo(contagem[a.id]!));

    return RelatorioDados(
      titulo: 'Utilização das lixeiras',
      instituicao: instituicao,
      geradoEm: DateTime.now(),
      aviso: lixeiras.isEmpty ? 'Ainda não há lixeiras cadastradas.' : null,
      resumo: [
        RelatorioResumoItem('Lixeiras', '${lixeiras.length}'),
        RelatorioResumoItem('Movimentações', '$total'),
        RelatorioResumoItem('Mais movimentada', maisUsada?.nomeLixeira ?? '-'),
      ],
      tituloBarras: 'Movimentações por lixeira',
      barras: [
        for (final l in ordenadas)
          RelatorioBarra(l.nomeLixeira, '${contagem[l.id]}',
              maior == 0 ? 0 : contagem[l.id]! / maior),
      ],
      colunas: const [
        'Lixeira',
        'Endereço',
        'Ocupação',
        'Status',
        'Movimentações'
      ],
      linhas: [
        for (final l in ordenadas)
          [
            l.nomeLixeira,
            l.enderecoLixeira,
            _pct(_ocupacao(l)),
            l.statusLixeira.label,
            '${contagem[l.id]}',
          ],
      ],
    );
  }

  // ── Nível de ocupação ──────────────────────────────────────────────────
  static RelatorioDados ocupacao({
    required String instituicao,
    required List<LixeiraModel> lixeiras,
    required List<dynamic> history,
  }) {
    final ordenadas = [...lixeiras]
      ..sort((a, b) => _ocupacao(b).compareTo(_ocupacao(a)));
    final media = lixeiras.isEmpty
        ? 0.0
        : lixeiras.map(_ocupacao).reduce((a, b) => a + b) / lixeiras.length;
    final paraColetar =
        lixeiras.where((l) => l.statusLixeira.codigo >= 3).length;

    final mudancas = _eventos(history)
        .where((h) =>
            (h['action_object']?.toString().toLowerCase() ?? '')
                .contains('status'))
        .toList()
        .reversed
        .take(8);

    return RelatorioDados(
      titulo: 'Nível de ocupação',
      instituicao: instituicao,
      geradoEm: DateTime.now(),
      aviso: lixeiras.isEmpty ? 'Ainda não há lixeiras cadastradas.' : null,
      resumo: [
        RelatorioResumoItem('Ocupação média', _pct(media)),
        RelatorioResumoItem(
            'Mais cheia',
            ordenadas.isEmpty
                ? '-'
                : '${ordenadas.first.nomeLixeira} (${_pct(_ocupacao(ordenadas.first))})'),
        RelatorioResumoItem('Para coletar', '$paraColetar'),
      ],
      tituloBarras: 'Ocupação por lixeira',
      barras: [
        for (final l in ordenadas)
          RelatorioBarra(l.nomeLixeira, _pct(_ocupacao(l)), _ocupacao(l)),
      ],
      colunas: const ['Lixeira', 'Resíduo (un.)', 'Ocupação', 'Status'],
      linhas: [
        for (final l in ordenadas)
          [
            l.nomeLixeira,
            '${l.quantidadeResiduo}',
            _pct(_ocupacao(l)),
            l.statusLixeira.label,
          ],
      ],
      tituloEventos: 'Últimas mudanças de status',
      eventos: [
        for (final h in mudancas)
          RelatorioEvento(h['action_object']?.toString() ?? '',
              h['time_action_object']?.toString() ?? ''),
      ],
    );
  }

  // ── Tipos dos resíduos ─────────────────────────────────────────────────
  /// Busca os resíduos registrados no backend (`GET /residues/all-residues`).
  static Future<List<ResiduoModel>> buscarResiduos() async {
    final resposta = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/residues/all-residues'))
        .timeout(const Duration(seconds: 20));
    if (resposta.statusCode != 200) {
      throw Exception('Falha ao buscar resíduos');
    }
    final dados = jsonDecode(resposta.body);
    if (dados is! List) return const [];
    return [
      for (final d in dados)
        if (d is Map<String, dynamic>) ResiduoModel.fromJson(d),
    ];
  }

  static RelatorioDados tiposResiduo({
    required String instituicao,
    required List<LixeiraModel> lixeiras,
    required List<ResiduoModel> residuos,
  }) {
    final ids = lixeiras.map((l) => l.id).toSet();
    final meus = residuos.where((r) => ids.contains(r.idLixeira)).toList();
    final contagem = <TipoResiduo, int>{
      for (final t in TipoResiduo.values)
        t: meus.where((r) => r.tipoResiduo == t).length,
    };
    final total = meus.length;
    final tipos = [...TipoResiduo.values]
      ..sort((a, b) => contagem[b]!.compareTo(contagem[a]!));
    final maior = total == 0 ? null : tipos.first;

    return RelatorioDados(
      titulo: 'Tipos dos Resíduos',
      instituicao: instituicao,
      geradoEm: DateTime.now(),
      aviso: total == 0
          ? 'Ainda não há resíduos registrados para as lixeiras da sua instituição.'
          : null,
      resumo: [
        RelatorioResumoItem('Resíduos registrados', '$total'),
        RelatorioResumoItem('Mais descartado', maior?.label ?? '-'),
        RelatorioResumoItem('Lixeiras', '${lixeiras.length}'),
      ],
      tituloBarras: 'Distribuição por tipo',
      barras: [
        for (final t in tipos)
          RelatorioBarra(t.label, '${contagem[t]}',
              total == 0 ? 0 : contagem[t]! / total),
      ],
      colunas: const ['Tipo', 'Quantidade', 'Participação'],
      linhas: total == 0
          ? const []
          : [
              for (final t in tipos)
                [t.label, '${contagem[t]}', _pct(contagem[t]! / total)],
            ],
    );
  }
}
