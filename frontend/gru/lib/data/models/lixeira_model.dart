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

/// Espelha o schema `trash.model.js` do backend (coleção `Lixeiras`).
class LixeiraModel {
  const LixeiraModel({
    this.id,
    required this.nome,
    required this.codigoDonoLixeira,
    required this.enderecoLixeira,
    required this.coordenada,
    required this.statusLixeira,
    this.outrasInformacoes,
  });

  final String? id;

  /// "Nome Lixeira" pedido no design - não existe ainda no schema do
  /// backend (só existe endereço/coordenada/status). Adicione
  /// `nome_lixeira` no `trash.model.js` para persistir esse campo.
  final String nome;

  final String codigoDonoLixeira;
  final String enderecoLixeira;
  final String coordenada;
  final StatusLixeira statusLixeira;
  final String? outrasInformacoes;

  factory LixeiraModel.fromJson(Map<String, dynamic> json) {
    return LixeiraModel(
      id: json['_id'] as String?,
      nome: json['nome_lixeira'] as String? ?? '',
      codigoDonoLixeira: json['codigo_dono_lixeira'] as String? ?? '',
      enderecoLixeira: json['endereco_lixeira'] as String? ?? '',
      coordenada: json['coordenada'] as String? ?? '',
      statusLixeira:
          StatusLixeira.fromCodigo(json['status_lixeira'] as int? ?? 0),
      outrasInformacoes: json['outras_informacoes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'nome_lixeira': nome,
      'codigo_dono_lixeira': codigoDonoLixeira,
      'endereco_lixeira': enderecoLixeira,
      'coordenada': coordenada,
      'status_lixeira': statusLixeira.codigo,
      if (outrasInformacoes != null) 'outras_informacoes': outrasInformacoes,
    };
  }
}
