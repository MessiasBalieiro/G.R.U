import '../../core/utils/cep.dart';
import 'residuo_model.dart';

/// Status da lixeira. Espelha o enum numérico `status_lixeira: [0..4]` do
/// backend (`trash.model.js`), agora derivado da porcentagem de ocupação.
enum StatusLixeira {
  vazia(0, 'Vazia'),
  baixa(1, 'Ocupação baixa'),
  media(2, 'Ocupação média'),
  alta(3, 'Ocupação alta'),
  cheia(4, 'Cheia');

  const StatusLixeira(this.codigo, this.label);
  final int codigo;
  final String label;

  static StatusLixeira fromOcupacao(int ocupacao) {
    if (ocupacao < 10) return vazia;
    if (ocupacao < 40) return baixa;
    if (ocupacao < 70) return media;
    if (ocupacao < 90) return alta;
    return cheia;
  }

  static StatusLixeira fromCodigo(int codigo) {
    return StatusLixeira.values.firstWhere(
      (s) => s.codigo == codigo,
      orElse: () => StatusLixeira.vazia,
    );
  }
}

/// Lixeira inteligente.
///
/// A localização é o endereço estruturado a partir do **CEP** ([cep],
/// [logradouro], [numero], [bairro], [cidade], [uf]); o mapa abre buscando
/// esse endereço.
///
/// Campos novos em relação ao `trash.model.js` do backend (necessários para
/// o app do coletor): [ocupacao] (% de capacidade usada), [composicao]
/// (% de cada tipo de resíduo lido pelos sensores), os campos de endereço
/// (hoje o backend guarda uma string `coordenada`) e [ultimaColeta].
class LixeiraModel {
  LixeiraModel({
    required this.id,
    required this.nome,
    required this.instituicaoId,
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
    this.ocupacao = 0,
    Map<TipoResiduo, int>? composicao,
    this.ultimaColeta,
    this.observacoes,
  }) : composicao = composicao ?? <TipoResiduo, int>{};

  final String id;
  final String nome;

  /// Instituição dona da lixeira (`codigo_dono_lixeira` no backend).
  final String instituicaoId;
  final String cep;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String uf;
  final String? observacoes;

  /// Porcentagem da capacidade em uso (0 a 100).
  int ocupacao;

  /// Porcentagem de cada tipo de resíduo (soma ≈ 100 quando há dados).
  Map<TipoResiduo, int> composicao;

  DateTime? ultimaColeta;

  StatusLixeira get status => StatusLixeira.fromOcupacao(ocupacao);

  int get livre => 100 - ocupacao;

  /// Nome sem o prefixo "Lixeira " (para rótulos curtos de gráfico).
  String get nomeCurto => nome.replaceFirst(RegExp(r'^Lixeira\s+'), '');

  String get cepFormatado => Cep.formatar(cep);

  /// Linha curta para listas: "Rua X, 123 · Bairro".
  String get endereco => '$logradouro, $numero · $bairro';

  /// "Rua X, 123 - Apto 4".
  String get logradouroNumero {
    final c = (complemento ?? '').trim();
    return c.isEmpty ? '$logradouro, $numero' : '$logradouro, $numero - $c';
  }

  /// "Bairro · Cidade - UF".
  String get bairroCidade => '$bairro · $cidade - $uf';

  /// Endereço completo, usado na busca do mapa.
  String get enderecoCompleto =>
      '$logradouro, $numero, $bairro, $cidade - $uf, $cepFormatado';

  /// Material mais concentrado na lixeira, ou `null` se não há dados.
  TipoResiduo? get materialPredominante {
    TipoResiduo? melhor;
    var maior = 0;
    composicao.forEach((tipo, pct) {
      if (pct > maior) {
        maior = pct;
        melhor = tipo;
      }
    });
    return melhor;
  }

  int get percentualPredominante {
    final m = materialPredominante;
    return m == null ? 0 : (composicao[m] ?? 0);
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'nome_lixeira': nome,
        'codigo_dono_lixeira': instituicaoId,
        'cep': cepFormatado,
        'endereco_lixeira': logradouroNumero,
        'bairro': bairro,
        'cidade': cidade,
        'uf': uf,
        'status_lixeira': status.codigo,
        'ocupacao': ocupacao,
        if (observacoes != null) 'outras_informacoes': observacoes,
      };
}
