import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/lixeira_model.dart';

/// Abre o endereço da lixeira (montado a partir do CEP) no app de mapas.
///
/// Tenta primeiro o esquema `geo:` (Google Maps, Waze, etc. — o Android deixa
/// o usuário escolher) e, se não houver app, cai para o Google Maps no
/// navegador.
Future<void> abrirNoMapa(BuildContext context, LixeiraModel l) async {
  final consulta = Uri.encodeComponent(l.enderecoCompleto);
  final geo = Uri.parse('geo:0,0?q=$consulta');
  final web =
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$consulta');

  var ok = false;
  try {
    ok = await launchUrl(geo, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok) {
    try {
      ok = await launchUrl(web, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir o mapa.')),
    );
  }
}
