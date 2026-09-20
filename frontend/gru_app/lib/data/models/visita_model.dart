import 'residuo_model.dart';

/// Registro de uma passagem (coleta) de um coletor por uma lixeira.
/// É o que alimenta o "Histórico" do coletor e as atividades do admin.
class VisitaModel {
  const VisitaModel({
    required this.id,
    required this.lixeiraId,
    required this.lixeiraNome,
    required this.endereco,
    required this.instituicaoId,
    required this.coletorId,
    required this.coletorNome,
    required this.dataHora,
    required this.ocupacao,
    this.material,
  });

  final String id;
  final String lixeiraId;
  final String lixeiraNome;
  final String endereco;
  final String instituicaoId;
  final String coletorId;
  final String coletorNome;
  final DateTime dataHora;

  /// Ocupação (%) da lixeira no momento da coleta.
  final int ocupacao;

  /// Material predominante no momento da coleta.
  final TipoResiduo? material;

  String get lixeiraNomeCurto =>
      lixeiraNome.replaceFirst(RegExp(r'^Lixeira\s+'), '');
}
