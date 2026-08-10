import 'package:flutter/material.dart';

/// Representa um tipo de relatório disponível na tela "Gerar Relatório".
///
/// Esse recurso ainda não tem endpoint correspondente no backend
/// (não existe rota `/reports` em `routes.js`). O model já foi deixado
/// pronto para quando essa API existir.
class RelatorioOpcao {
  const RelatorioOpcao({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.icone,
  });

  final String id;
  final String titulo;
  final String descricao;
  final IconData icone;
}
