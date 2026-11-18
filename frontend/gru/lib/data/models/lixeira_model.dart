/// Status possíveis de uma lixeira, espelhando o enum numérico
/// `status_lixeira: [0, 1, 2, 3, 4]` do backend (`trash.model.js`).
///
/// O backend não documenta o significado de cada número, então a ordem
/// abaixo segue a hipótese mais comum (nível de ocupação crescente).
/// Ajuste os rótulos aqui se o significado real for outro.
enum StatusLixeira {
  vazia(0, 'Vazia'),
  baixa(1, 'Ocupação baixa'),
  media(2, 'Ocupação média'),
  alta(3, 'Ocupação alta'),
  cheia(4, 'Cheia');

  const StatusLixeira(this.codigo, this.label);
  final int codigo;
  final String label;

  static StatusLixeira fromCodigo(int codigo) {
    return StatusLixeira.values.firstWhere(
      (s) => s.codigo == codigo,
      orElse: () => StatusLixeira.vazia,
    );
  }
}

class LixeiraModel {
  const LixeiraModel({
    required this.id,
    required this.nomeLixeira,
    required this.codigoDonoLixeira,
    required this.enderecoLixeira,
    required this.coordenada,
    required this.quantidadeResiduo,
    required this.statusLixeira,
  });

  final String id;
  final String nomeLixeira;
  final String codigoDonoLixeira;
  final String enderecoLixeira;
  final String coordenada;
  final int quantidadeResiduo;
  final StatusLixeira statusLixeira;

  factory LixeiraModel.fromJson(Map<String, dynamic> json) {
    return LixeiraModel(
      id: json['_id'] as String? ?? '',
      nomeLixeira: json['nome_lixeira'] as String? ?? '',
      codigoDonoLixeira: json['codigo_dono_lixeira'] as String? ?? '',
      enderecoLixeira: json['endereco_lixeira'] as String? ?? '',
      coordenada: json['coordenada'] as String? ?? '',
      quantidadeResiduo: json['quantidade_residuo'] as int? ?? 0,
      statusLixeira:
        StatusLixeira.fromCodigo(json['status_lixeira'] as int? ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nome_lixeira': nomeLixeira,
      'codigo_dono_lixeira': codigoDonoLixeira,
      'endereco_lixeira': enderecoLixeira,
      'coordenada': coordenada,
      'quantidade_residuo': quantidadeResiduo,
      'status_lixeira': statusLixeira.codigo,
    };
  }
}
