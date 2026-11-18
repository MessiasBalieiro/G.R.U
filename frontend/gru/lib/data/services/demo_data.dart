import '../models/residuo_model.dart';

/// Dados de exemplo do de reserva, usados quando o servidor falha.
class DemoData {
  DemoData._();

  static const idUsuario = 'demo-user';
  static const idOrganizacao = 'demo-org';
  static const instituicao = 'Escola Modelo G.R.U';

  static Map<String, dynamic> usuario() => {
        '_id': idUsuario,
        'nome_usuario': 'Visitante Demo',
        'email_usuario': 'demo@gru.app',
        'telefone_usuario': '(11) 91234-5678',
        'cpf_usuario': '000.000.000-00',
        'cargo_usuario': 'CONTRATANTE',
        'instituicao_usuario': instituicao,
        'coletas_realizadas': 0,
      };

  /// (nome, endereço, coordenada, % de ocupação, status 0–4)
  static const _lixeirasBase = [
    ('Lixeira Pátio', 'Pátio central', '-23.5505,-46.6333', 12, 0),
    ('Lixeira Cantina', 'Cantina, térreo', '-23.5510,-46.6340', 38, 1),
    ('Lixeira Biblioteca', 'Biblioteca, 1º andar', '-23.5515,-46.6345', 55, 2),
    ('Lixeira Quadra', 'Quadra esportiva', '-23.5520,-46.6350', 78, 3),
    ('Lixeira Laboratório', 'Bloco B, laboratório', '-23.5525,-46.6355', 100, 4),
    ('Lixeira Entrada', 'Portaria principal', '-23.5530,-46.6360', 92, 4),
  ];

  static String _idLixeira(int i) => 'demo-lixeira-${i + 1}';

  static List<Map<String, dynamic>> lixeiras() => [
        for (var i = 0; i < _lixeirasBase.length; i++)
          {
            '_id': _idLixeira(i),
            'nome_lixeira': _lixeirasBase[i].$1,
            'codigo_dono_lixeira': idUsuario,
            'endereco_lixeira': _lixeirasBase[i].$2,
            'coordenada': _lixeirasBase[i].$3,
            'quantidade_residuo': _lixeirasBase[i].$4,
            'status_lixeira': _lixeirasBase[i].$5,
          },
      ];

  static List<Map<String, dynamic>> coletores() => [
        for (final c in const [
          ('Carlos Silva', 'carlos@gru.app', 14),
          ('Ana Souza', 'ana@gru.app', 9),
          ('Bruno Lima', 'bruno@gru.app', 21),
          ('Marina Costa', 'marina@gru.app', 6),
        ])
          {
            '_id': 'demo-coletor-${c.$1.split(' ').first.toLowerCase()}',
            'nome_usuario': c.$1,
            'email_usuario': c.$2,
            'telefone_usuario': '(11) 98888-0000',
            'cpf_usuario': '111.444.777-35',
            'cargo_usuario': 'COLETOR',
            'instituicao_usuario': instituicao,
            'coletas_realizadas': c.$3,
          },
      ];

  static String _fmt(DateTime d) {
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(d.day)}/${dois(d.month)}/${d.year}, ${dois(d.hour)}:${dois(d.minute)}';
  }

  static Map<String, dynamic> organizacao() {
    final agora = DateTime.now();
    final nomes = [for (final l in _lixeirasBase) l.$1];
    // (minutos atrás, índice da lixeira, texto)
    final eventos = <(int, int, String)>[
      (5, 4, '${nomes[4]} mudou de status para "Cheia"'),
      (22, 5, '${nomes[5]} mudou de status para "Cheia"'),
      (47, 3, '${nomes[3]} mudou de status para "Ocupação alta"'),
      (95, 2, '${nomes[2]} mudou de status para "Ocupação média"'),
      (150, 1, '${nomes[1]} mudou de status para "Ocupação baixa"'),
      (240, 0, '${nomes[0]} foi esvaziada pelo coletor Carlos Silva'),
      (420, 3, '${nomes[3]} mudou de status para "Ocupação média"'),
      (600, 5, '${nomes[5]} foi esvaziada pelo coletor Ana Souza'),
      (1440, 2, '${nomes[2]} foi adicionada'),
      (1500, 1, '${nomes[1]} foi adicionada'),
      (1560, 0, '${nomes[0]} foi adicionada'),
      (2880, 4, '${nomes[4]} foi adicionada'),
    ];
    return {
      '_id': idOrganizacao,
      'id_contratante': idUsuario,
      'organization_name': instituicao,
      'colectors': [for (final c in coletores()) c['_id']],
      'trashes': [for (var i = 0; i < _lixeirasBase.length; i++) _idLixeira(i)],
      'history': [
        for (final e in eventos)
          {
            'type_object': 'Lixeiras',
            'id_object': _idLixeira(e.$2),
            'action_object': e.$3,
            'time_action_object':
                _fmt(agora.subtract(Duration(minutes: e.$1))),
          },
      ],
    };
  }

  static List<ResiduoModel> residuos() {
    final agora = DateTime.now();
    const dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    String dois(int n) => n.toString().padLeft(2, '0');
    const tipos = [
      ...[TipoResiduo.plastico, TipoResiduo.plastico, TipoResiduo.plastico, TipoResiduo.plastico, TipoResiduo.plastico],
      ...[TipoResiduo.papel, TipoResiduo.papel, TipoResiduo.papel, TipoResiduo.papel],
      ...[TipoResiduo.vidro, TipoResiduo.vidro, TipoResiduo.vidro],
      ...[TipoResiduo.metal, TipoResiduo.metal],
    ];
    return [
      for (var i = 0; i < tipos.length; i++)
        () {
          final d = agora.subtract(Duration(hours: 5 * i + 2));
          return ResiduoModel(
            id: 'demo-residuo-$i',
            idLixeira: _idLixeira(i % _lixeirasBase.length),
            tipoResiduo: tipos[i],
            dataResiduo: '${dois(d.day)}/${dois(d.month)}/${d.year}',
            diaSemanaResiduo: dias[d.weekday - 1],
            horarioResiduo: '${dois(d.hour)}:${dois(d.minute)}',
          );
        }(),
    ];
  }
}
