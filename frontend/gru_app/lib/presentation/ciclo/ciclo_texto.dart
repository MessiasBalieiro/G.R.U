import 'package:flutter/material.dart';

/// Renderiza o texto do Ciclo com um markdown mínimo: **negrito**, e linhas
/// de lista começando com "- ", "* ", "• " ou "1. ".
class CicloTexto extends StatelessWidget {
  const CicloTexto(this.texto, {super.key, required this.cor});

  final String texto;
  final Color cor;

  static final _lista = RegExp(r'^\s*(?:[-*•]|\d+[.)])\s+');
  static final _negrito = RegExp(r'\*\*(.+?)\*\*');

  List<InlineSpan> _spans(String linha, TextStyle base) {
    final spans = <InlineSpan>[];
    var i = 0;
    for (final m in _negrito.allMatches(linha)) {
      if (m.start > i) spans.add(TextSpan(text: linha.substring(i, m.start)));
      spans.add(TextSpan(
        text: m.group(1),
        style: base.copyWith(fontWeight: FontWeight.w800),
      ));
      i = m.end;
    }
    if (i < linha.length) spans.add(TextSpan(text: linha.substring(i)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(color: cor, fontSize: 14, height: 1.38);
    final linhas = texto
        .replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
        .split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final linha in linhas)
          if (linha.trim().isEmpty)
            const SizedBox(height: 6)
          else if (_lista.hasMatch(linha))
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    RegExp(r'^\s*(\d+[.)])').firstMatch(linha)?.group(1) ?? '•',
                    style: base.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: base,
                        children: _spans(linha.replaceFirst(_lista, ''), base),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Text.rich(TextSpan(style: base, children: _spans(linha, base))),
      ],
    );
  }
}
