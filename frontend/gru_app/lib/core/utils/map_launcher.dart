import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/lixeira_model.dart';

/// Abre a localização da lixeira no app de mapas do celular.
///
/// Tenta primeiro o esquema `geo:` (Google Maps, Waze, etc. — o Android deixa
/// o usuário escolher) e, se não houver app, cai para o Google Maps no
/// navegador.
Future<void> abrirNoMapa(BuildContext context, LixeiraModel l) async {
  final label = Uri.encodeComponent(l.nome);
  final geo = Uri.parse(
    'geo:${l.latitude},${l.longitude}?q=${l.latitude},${l.longitude}($label)',
  );
  final web = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${l.latitude},${l.longitude}',
  );

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
