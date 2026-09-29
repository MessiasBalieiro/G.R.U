/// Espelha o enum `tipo_residuo` do backend (`residue.model.js`).
enum TipoResiduo {
  plastico('Plástico'),
  vidro('Vidro'),
  metal('Metal'),
  papel('Papel');

  const TipoResiduo(this.label);
  final String label;

  static TipoResiduo fromLabel(String label) {
    return TipoResiduo.values.firstWhere(
      (t) => t.label == label,
      orElse: () => TipoResiduo.plastico,
    );
  }
}
