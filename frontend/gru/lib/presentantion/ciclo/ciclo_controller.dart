import 'package:flutter/foundation.dart';

import '../../data/models/ciclo_model.dart';
import '../../data/services/ciclo_service.dart';

/// Estado do chat do Ciclo, compartilhado entre o Dashboard e a janela do
/// chat. Guarda as mensagens e qual gráfico está em destaque, e é isso que
/// liga as respostas do Ciclo aos gráficos na tela.
class CicloController extends ChangeNotifier {
  CicloController({
    required this.snapshot,
    CicloService? service,
  }) : _service = service ?? CicloService();

  /// Função que monta o snapshot com os dados atuais do Dashboard.
  final Map<String, dynamic> Function() snapshot;
  final CicloService _service;

  final List<CicloMensagem> _mensagens = [
    const CicloMensagem(
      autor: CicloAutor.ciclo,
      texto: 'Oi! Eu sou o Ciclo 🌱. Posso resumir o dashboard, dizer quais '
          'lixeiras coletar primeiro, prever quando elas vão encher e analisar '
          'materiais e coletores. Como posso ajudar?',
    ),
  ];

  bool _carregando = false;
  CicloGrafico? _destaque;
  String? _modo;

  List<CicloMensagem> get mensagens => List.unmodifiable(_mensagens);
  bool get carregando => _carregando;

  /// Gráfico destacado no Dashboard (o último que o Ciclo usou ou o que o
  /// usuário pediu para ver).
  CicloGrafico? get destaque => _destaque;

  /// "llm" ou "offline", conforme o servidor respondeu.
  String? get modo => _modo;

  Future<void> enviar(String texto) async {
    final pergunta = texto.trim();
    if (pergunta.isEmpty || _carregando) return;

    final historico = List<CicloMensagem>.of(_mensagens);
    _mensagens.add(CicloMensagem(autor: CicloAutor.usuario, texto: pergunta));
    _carregando = true;
    notifyListeners();

    try {
      final r = await _service.perguntar(
        pergunta: pergunta,
        snapshot: snapshot(),
        historico: historico.skip(1).toList(), // sem a saudação
      );
      _modo = r.modo;
      _mensagens.add(CicloMensagem(
        autor: CicloAutor.ciclo,
        texto: r.resposta,
        graficos: r.graficos,
      ));
      if (r.graficos.isNotEmpty) _destaque = r.graficos.first;
    } on CicloException catch (e) {
      _mensagens.add(CicloMensagem(
        autor: CicloAutor.ciclo,
        texto: e.mensagem,
        erro: true,
      ));
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  void destacar(CicloGrafico? g) {
    _destaque = g;
    notifyListeners();
  }
}
