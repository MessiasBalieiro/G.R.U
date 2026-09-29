/// Formatação de datas em português, sem depender do pacote `intl`.
class Fmt {
  Fmt._();

  static String _dois(int n) => n.toString().padLeft(2, '0');

  static const _dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  static String data(DateTime d) =>
      '${_dois(d.day)}/${_dois(d.month)}/${d.year}';

  static String hora(DateTime d) => '${_dois(d.hour)}:${_dois(d.minute)}';

  static String dataHora(DateTime d) => '${data(d)} às ${hora(d)}';

  static String mesAno(DateTime d) => '${_dois(d.month)}/${d.year}';

  static String diaSemana(DateTime d) => _dias[d.weekday - 1];

  /// "Hoje", "Ontem" ou "Seg, 14/09".
  static String rotuloDia(DateTime d) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final dia = DateTime(d.year, d.month, d.day);
    final diff = hoje.difference(dia).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Ontem';
    return '${diaSemana(d)}, ${_dois(d.day)}/${_dois(d.month)}';
  }

  /// "Agora", "Há 5 min", "Há 3h", "Há 2 dias" ou a data completa.
  static String relativo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    if (diff.inDays < 7) {
      return diff.inDays == 1 ? 'Há 1 dia' : 'Há ${diff.inDays} dias';
    }
    return data(d);
  }
}
