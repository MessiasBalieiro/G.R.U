/// Representa um coletor (membro da equipe de coleta) para a seção
/// "Gráficos dos coletores" do Dashboard.
///
/// Esse recurso ainda não existe no backend (não há model/rota de
/// coletores em `backend/src`) - por enquanto os dados vêm do
/// [MockDataService], da mesma forma que lixeiras e usuários.
class ColetorModel {
  const ColetorModel({
    required this.nome,
    required this.coletasRealizadas,
  });

  final String nome;
  final int coletasRealizadas;
}
