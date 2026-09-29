import 'package:flutter/material.dart';
import '../models/coletor_model.dart';
import '../models/lixeira_model.dart';
import '../models/relatorio_model.dart';

/// Fonte de dados fake (em memória) usada pelas telas enquanto o backend
/// não expõe os endpoints de login, cadastro e criação de lixeira
/// (hoje `backend/src` só tem GET /all-users, /all-trashes, all-residues).
///
/// Quando os endpoints reais existirem, troque as implementações dos
/// repositórios em `data/repositories` para chamar a API via `http`,
/// mantendo a mesma assinatura de métodos usada pelas telas.
class MockDataService {
  MockDataService._();
  static final MockDataService instance = MockDataService._();

  final List<LixeiraModel> _lixeiras = [
    const LixeiraModel(
      id: '1',
      nome: 'Lixeira Praça Central',
      codigoDonoLixeira: 'INST-001',
      enderecoLixeira: 'Praça Central, 100',
      coordenada: '-23.5505,-46.6333',
      statusLixeira: StatusLixeira.media,
      outrasInformacoes: 'Coleta seletiva - plástico e papel',
    ),
    const LixeiraModel(
      id: '2',
      nome: 'Lixeira Campus Norte',
      codigoDonoLixeira: 'INST-001',
      enderecoLixeira: 'Av. Universitária, 500',
      coordenada: '-23.5605,-46.6433',
      statusLixeira: StatusLixeira.cheia,
      outrasInformacoes: 'Coleta seletiva - vidro e metal',
    ),
    const LixeiraModel(
      id: '3',
      nome: 'Lixeira Terminal Rodoviário',
      codigoDonoLixeira: 'INST-002',
      enderecoLixeira: 'Terminal Rodoviário, Portão 3',
      coordenada: '-23.5705,-46.6533',
      statusLixeira: StatusLixeira.baixa,
      outrasInformacoes: 'Coleta geral',
    ),
  ];

  List<LixeiraModel> get lixeiras => List.unmodifiable(_lixeiras);

  void adicionarLixeira(LixeiraModel lixeira) {
    _lixeiras.add(lixeira);
  }

  /// Leituras dos sensores (mock) usadas pelo Ciclo: data da última coleta
  /// e composição de material (%) de cada lixeira, pelo `id`.
  /// Ainda não existem no backend; quando existirem, virão da API junto com
  /// a lixeira e este mapa pode ser removido.
  static Map<String, ({DateTime ultimaColeta, Map<String, int> composicao})>
      get sensores {
    final agora = DateTime.now();
    return {
      '1': (
        ultimaColeta: agora.subtract(const Duration(days: 2)),
        composicao: {'Plástico': 45, 'Papel': 30, 'Vidro': 15, 'Metal': 10},
      ),
      '2': (
        ultimaColeta: agora.subtract(const Duration(days: 3)),
        composicao: {'Vidro': 50, 'Metal': 25, 'Plástico': 15, 'Papel': 10},
      ),
      '3': (
        ultimaColeta: agora.subtract(const Duration(days: 1)),
        composicao: {'Plástico': 60, 'Papel': 20, 'Metal': 12, 'Vidro': 8},
      ),
    };
  }

  static const List<ColetorModel> coletores = [
    ColetorModel(nome: 'João Silva', coletasRealizadas: 14),
    ColetorModel(nome: 'Maria Souza', coletasRealizadas: 9),
    ColetorModel(nome: 'Pedro Lima', coletasRealizadas: 11),
  ];

  static const List<RelatorioOpcao> relatorios = [
    RelatorioOpcao(
      id: 'utilizacao',
      titulo: 'Utilização das lixeiras',
      descricao: 'Frequência de uso por lixeira em um período.',
      icone: Icons.delete_outline_rounded,
    ),
    RelatorioOpcao(
      id: 'tipos_residuo',
      titulo: 'Tipos dos Resíduos',
      descricao: 'Distribuição por tipo de resíduo descartado.',
      icone: Icons.category_outlined,
    ),
    RelatorioOpcao(
      id: 'ocupacao',
      titulo: 'Nível de ocupação',
      descricao: 'Histórico de ocupação das lixeiras monitoradas.',
      icone: Icons.trending_up_rounded,
    ),
    RelatorioOpcao(
      id: 'coletas',
      titulo: 'Coletas realizadas',
      descricao: 'Quantidade de coletas concluídas por período.',
      icone: Icons.local_shipping_outlined,
    ),
  ];
}
