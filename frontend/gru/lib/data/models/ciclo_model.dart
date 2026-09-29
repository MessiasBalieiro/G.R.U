/// Gráficos do Dashboard que o Ciclo consegue relacionar às respostas.
/// O `id` é o mesmo devolvido pelo backend no campo `graficos`.
enum CicloGrafico {
  kpis('kpis', 'Indicadores', 'Me dá um resumo geral do dashboard'),
  ocupacao('ocupacao', 'Ocupação por lixeira',
      'Quais lixeiras devo coletar primeiro e quando as outras vão encher?'),
  residuos('residuos', 'Status das lixeiras',
      'O que a distribuição de status e de materiais indica?'),
  ranking('ranking', 'Gráficos dos coletores',
      'Como está o desempenho dos coletores?'),
  atividades('atividades', 'Atividades recentes',
      'O que aconteceu nas últimas atividades?');

  const CicloGrafico(this.id, this.titulo, this.perguntaSugerida);

  final String id;
  final String titulo;

  /// Pergunta enviada ao tocar em "Perguntar ao Ciclo" no gráfico.
  final String perguntaSugerida;

  static CicloGrafico? fromId(String id) {
    for (final g in values) {
      if (g.id == id) return g;
    }
    return null;
  }
}

enum CicloAutor { usuario, ciclo }

/// Uma mensagem do chat.
class CicloMensagem {
  const CicloMensagem({
    required this.autor,
    required this.texto,
    this.graficos = const [],
    this.erro = false,
  });

  final CicloAutor autor;
  final String texto;

  /// Gráficos usados na resposta (vira os chips "Ver gráfico").
  final List<CicloGrafico> graficos;

  /// Mensagem de falha (servidor fora do ar, sem internet...).
  final bool erro;

  bool get doUsuario => autor == CicloAutor.usuario;

  /// Formato do histórico esperado pelo backend.
  Map<String, String> toJson() =>
      {'papel': doUsuario ? 'usuario' : 'ciclo', 'texto': texto};
}

/// Resposta da rota `POST /ciclo/chat`.
class CicloResposta {
  const CicloResposta({
    required this.resposta,
    required this.graficos,
    required this.modo,
  });

  final String resposta;
  final List<CicloGrafico> graficos;

  /// "llm" (Gemini) ou "offline" (sem chave de API no servidor).
  final String modo;

  factory CicloResposta.fromJson(Map<String, dynamic> json) {
    final ids = (json['graficos'] as List? ?? const []).cast<String>();
    return CicloResposta(
      resposta: (json['resposta'] as String? ?? '').trim(),
      graficos: ids.map(CicloGrafico.fromId).whereType<CicloGrafico>().toList(),
      modo: json['modo'] as String? ?? 'llm',
    );
  }
}
