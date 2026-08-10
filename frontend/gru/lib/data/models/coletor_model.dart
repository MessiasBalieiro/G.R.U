/// Representa um membro da equipe de coleta para a seção
/// "Gráficos dos coletores" do Dashboard.
///
/// [MockDataService], da mesma forma que lixeiras e usuários.
class ColetorModel {
  const ColetorModel({
    required this.nome,
    required this.coletasRealizadas,
  });

  final String nome;
  final int coletasRealizadas;
}
