/// Instituição (prefeitura, universidade, terminal…) dona de lixeiras e
/// à qual coletores são vinculados.
class InstituicaoModel {
  const InstituicaoModel({
    required this.id,
    required this.nome,
    required this.cidade,
  });

  final String id;
  final String nome;
  final String cidade;

  String get inicial => nome.isEmpty ? '?' : nome[0].toUpperCase();
}
