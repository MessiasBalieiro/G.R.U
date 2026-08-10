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

/// Espelha o schema `residue.model.js` do backend (coleção `Residuos`).
class ResiduoModel {
  const ResiduoModel({
    this.id,
    required this.idLixeira,
    required this.tipoResiduo,
    required this.dataResiduo,
    required this.diaSemanaResiduo,
    required this.horarioResiduo,
  });

  final String? id;
  final String idLixeira;
  final TipoResiduo tipoResiduo;

  /// Formato esperado pelo backend: dd/MM/yyyy
  final String dataResiduo;
  final String diaSemanaResiduo;

  /// Formato esperado pelo backend: HH:mm
  final String horarioResiduo;

  factory ResiduoModel.fromJson(Map<String, dynamic> json) {
    return ResiduoModel(
      id: json['_id'] as String?,
      idLixeira: json['id_lixeira'] as String? ?? '',
      tipoResiduo:
          TipoResiduo.fromLabel(json['tipo_residuo'] as String? ?? ''),
      dataResiduo: json['data_residuo'] as String? ?? '',
      diaSemanaResiduo: json['dia_semana_residuo'] as String? ?? '',
      horarioResiduo: json['horario_residuo'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'id_lixeira': idLixeira,
      'tipo_residuo': tipoResiduo.label,
      'data_residuo': dataResiduo,
      'dia_semana_residuo': diaSemanaResiduo,
      'horario_residuo': horarioResiduo,
    };
  }
}
