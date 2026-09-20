import 'package:flutter/foundation.dart';

import '../models/instituicao_model.dart';
import '../models/lixeira_model.dart';
import '../models/residuo_model.dart';
import '../models/usuario_model.dart';
import '../models/visita_model.dart';

/// Fonte de dados fake (em memória) do app, no mesmo espírito do
/// `MockDataService` da versão web. Notifica os ouvintes a cada mudança,
/// então as telas usam `ListenableBuilder` para se atualizar sozinhas.
///
/// Quando o backend expuser as rotas de login, lixeiras, visitas e
/// vínculos, troque a implementação dos repositórios por chamadas HTTP.
///
/// Contas de teste: `admin@gru.com` e `coletor@gru.com` (senha `gru123`).
class MockDataService extends ChangeNotifier {
  MockDataService._() {
    _seed();
  }
  static final MockDataService instance = MockDataService._();

  final List<InstituicaoModel> _instituicoes = [];
  final List<UsuarioModel> _usuarios = [];
  final List<LixeiraModel> _lixeiras = [];
  final List<VisitaModel> _visitas = [];
  int _seq = 100;

  String _novoId(String prefixo) => '$prefixo${_seq++}';

  // ═══════════════════════════════════════════════════════════════════════
  // SEED
  // ═══════════════════════════════════════════════════════════════════════
  void _seed() {
    final agora = DateTime.now();
    DateTime atras({int dias = 0, int horas = 0}) =>
        agora.subtract(Duration(days: dias, hours: horas));

    _instituicoes.addAll(const [
      InstituicaoModel(
          id: 'i1', nome: 'Prefeitura Municipal', cidade: 'São Paulo, SP'),
      InstituicaoModel(
          id: 'i2', nome: 'Universidade Campus Norte', cidade: 'São Paulo, SP'),
      InstituicaoModel(
          id: 'i3', nome: 'Terminal Rodoviário Central', cidade: 'São Paulo, SP'),
    ]);

    _usuarios.addAll([
      UsuarioModel(
        id: 'a1',
        nome: 'Administrador G.R.U',
        email: 'admin@gru.com',
        senha: 'gru123',
        tipo: TipoUsuario.administrador,
        vinculos: {'i1': atras(dias: 180)},
      ),
      UsuarioModel(
        id: 'c1',
        nome: 'João Silva',
        email: 'coletor@gru.com',
        senha: 'gru123',
        tipo: TipoUsuario.coletor,
        vinculos: {'i1': atras(dias: 120), 'i2': atras(dias: 45)},
      ),
      UsuarioModel(
        id: 'c2',
        nome: 'Maria Souza',
        email: 'maria@gru.com',
        senha: 'gru123',
        tipo: TipoUsuario.coletor,
        vinculos: {'i1': atras(dias: 90)},
      ),
      UsuarioModel(
        id: 'c3',
        nome: 'Pedro Lima',
        email: 'pedro@gru.com',
        senha: 'gru123',
        tipo: TipoUsuario.coletor,
        vinculos: {'i1': atras(dias: 60), 'i3': atras(dias: 30)},
      ),
      // Sem vínculo: aparece em "Aguardando vínculo" para o admin.
      UsuarioModel(
        id: 'c4',
        nome: 'Ana Costa',
        email: 'ana@gru.com',
        senha: 'gru123',
        tipo: TipoUsuario.coletor,
      ),
    ]);

    _lixeiras.addAll([
      LixeiraModel(
        id: 'l1',
        nome: 'Lixeira Praça Central',
        instituicaoId: 'i1',
        endereco: 'Praça Central, 100',
        latitude: -23.5505,
        longitude: -46.6333,
        ocupacao: 58,
        composicao: {
          TipoResiduo.plastico: 45,
          TipoResiduo.papel: 30,
          TipoResiduo.vidro: 15,
          TipoResiduo.metal: 10,
        },
        observacoes: 'Coleta seletiva - plástico e papel',
      ),
      LixeiraModel(
        id: 'l2',
        nome: 'Lixeira Campus Norte',
        instituicaoId: 'i2',
        endereco: 'Av. Universitária, 500',
        latitude: -23.5605,
        longitude: -46.6433,
        ocupacao: 92,
        composicao: {
          TipoResiduo.vidro: 50,
          TipoResiduo.metal: 25,
          TipoResiduo.plastico: 15,
          TipoResiduo.papel: 10,
        },
        observacoes: 'Coleta seletiva - vidro e metal',
      ),
      LixeiraModel(
        id: 'l3',
        nome: 'Lixeira Terminal Rodoviário',
        instituicaoId: 'i3',
        endereco: 'Terminal Rodoviário, Portão 3',
        latitude: -23.5705,
        longitude: -46.6533,
        ocupacao: 24,
        composicao: {
          TipoResiduo.plastico: 60,
          TipoResiduo.papel: 20,
          TipoResiduo.metal: 12,
          TipoResiduo.vidro: 8,
        },
        observacoes: 'Coleta geral',
      ),
      LixeiraModel(
        id: 'l4',
        nome: 'Lixeira Parque das Águas',
        instituicaoId: 'i1',
        endereco: 'Rua das Águas, 230',
        latitude: -23.5874,
        longitude: -46.6576,
        ocupacao: 81,
        composicao: {
          TipoResiduo.plastico: 55,
          TipoResiduo.papel: 20,
          TipoResiduo.metal: 15,
          TipoResiduo.vidro: 10,
        },
      ),
      LixeiraModel(
        id: 'l5',
        nome: 'Lixeira Biblioteca Municipal',
        instituicaoId: 'i1',
        endereco: 'Rua da Consolação, 42',
        latitude: -23.5489,
        longitude: -46.6388,
        ocupacao: 37,
        composicao: {
          TipoResiduo.papel: 62,
          TipoResiduo.plastico: 28,
          TipoResiduo.metal: 6,
          TipoResiduo.vidro: 4,
        },
      ),
      LixeiraModel(
        id: 'l6',
        nome: 'Lixeira Feira Livre',
        instituicaoId: 'i1',
        endereco: 'Rua do Mercado, 15',
        latitude: -23.5432,
        longitude: -46.6291,
        ocupacao: 68,
        composicao: {
          TipoResiduo.metal: 40,
          TipoResiduo.plastico: 30,
          TipoResiduo.vidro: 20,
          TipoResiduo.papel: 10,
        },
      ),
      LixeiraModel(
        id: 'l7',
        nome: 'Lixeira Refeitório Central',
        instituicaoId: 'i2',
        endereco: 'Av. Universitária, 520',
        latitude: -23.5612,
        longitude: -46.6440,
        ocupacao: 45,
        composicao: {
          TipoResiduo.plastico: 40,
          TipoResiduo.vidro: 30,
          TipoResiduo.papel: 20,
          TipoResiduo.metal: 10,
        },
      ),
    ]);

    void visita(String lixeiraId, String coletorId, DateTime quando, int ocup) {
      final l = _lixeiras.firstWhere((x) => x.id == lixeiraId);
      final c = _usuarios.firstWhere((x) => x.id == coletorId);
      _visitas.add(VisitaModel(
        id: _novoId('v'),
        lixeiraId: l.id,
        lixeiraNome: l.nome,
        endereco: l.endereco,
        instituicaoId: l.instituicaoId,
        coletorId: c.id,
        coletorNome: c.nome,
        dataHora: quando,
        ocupacao: ocup,
        material: l.materialPredominante,
      ));
    }

    // João Silva (c1)
    visita('l1', 'c1', atras(horas: 26), 81);
    visita('l2', 'c1', atras(horas: 50), 95);
    visita('l4', 'c1', atras(dias: 3, horas: 2), 78);
    visita('l6', 'c1', atras(dias: 4, horas: 5), 74);
    visita('l7', 'c1', atras(dias: 5), 66);
    visita('l5', 'c1', atras(dias: 6, horas: 3), 55);
    visita('l1', 'c1', atras(dias: 8), 77);
    visita('l2', 'c1', atras(dias: 10, horas: 4), 90);
    // Maria Souza (c2)
    visita('l5', 'c2', atras(horas: 20), 48);
    visita('l4', 'c2', atras(horas: 30), 85);
    visita('l1', 'c2', atras(dias: 5, horas: 6), 70);
    visita('l6', 'c2', atras(dias: 7), 72);
    // Pedro Lima (c3)
    visita('l6', 'c3', atras(dias: 2), 72);
    visita('l3', 'c3', atras(dias: 4), 60);
    visita('l4', 'c3', atras(dias: 9), 88);

    for (final l in _lixeiras) {
      final vs = _visitas.where((v) => v.lixeiraId == l.id);
      if (vs.isNotEmpty) {
        l.ultimaColeta =
            vs.map((v) => v.dataHora).reduce((a, b) => a.isAfter(b) ? a : b);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // USUÁRIOS / AUTENTICAÇÃO
  // ═══════════════════════════════════════════════════════════════════════
  UsuarioModel? usuarioPorEmail(String email) {
    final e = email.trim().toLowerCase();
    for (final u in _usuarios) {
      if (u.email.toLowerCase() == e) return u;
    }
    return null;
  }

  UsuarioModel? autenticar(String email, String senha) {
    final u = usuarioPorEmail(email);
    if (u == null || u.senha != senha) return null;
    return u;
  }

  UsuarioModel registrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required TipoUsuario tipo,
    String? instituicaoId,
  }) {
    final u = UsuarioModel(
      id: _novoId(tipo == TipoUsuario.administrador ? 'a' : 'c'),
      nome: nome.trim(),
      email: email.trim(),
      senha: senha,
      tipo: tipo,
      vinculos: instituicaoId == null
          ? null
          : {instituicaoId: DateTime.now()},
    );
    _usuarios.add(u);
    notifyListeners();
    return u;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // INSTITUIÇÕES
  // ═══════════════════════════════════════════════════════════════════════
  InstituicaoModel? instituicaoPorId(String id) {
    for (final i in _instituicoes) {
      if (i.id == id) return i;
    }
    return null;
  }

  InstituicaoModel criarInstituicao(String nome) {
    final i = InstituicaoModel(
        id: _novoId('i'), nome: nome.trim(), cidade: 'Não informada');
    _instituicoes.add(i);
    notifyListeners();
    return i;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LIXEIRAS
  // ═══════════════════════════════════════════════════════════════════════
  List<LixeiraModel> lixeirasDasInstituicoes(Iterable<String> ids) {
    final s = ids.toSet();
    return _lixeiras.where((l) => s.contains(l.instituicaoId)).toList();
  }

  LixeiraModel? lixeiraPorId(String id) {
    for (final l in _lixeiras) {
      if (l.id == id) return l;
    }
    return null;
  }

  LixeiraModel adicionarLixeira({
    required String nome,
    required String endereco,
    required double latitude,
    required double longitude,
    required String instituicaoId,
    String? observacoes,
  }) {
    final l = LixeiraModel(
      id: _novoId('l'),
      nome: nome.trim(),
      instituicaoId: instituicaoId,
      endereco: endereco.trim(),
      latitude: latitude,
      longitude: longitude,
      observacoes: observacoes,
    );
    _lixeiras.add(l);
    notifyListeners();
    return l;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // COLETORES / VÍNCULOS
  // ═══════════════════════════════════════════════════════════════════════
  List<UsuarioModel> coletoresDaInstituicao(String instituicaoId) => _usuarios
      .where((u) => u.ehColetor && u.vinculos.containsKey(instituicaoId))
      .toList();

  List<UsuarioModel> coletoresSemVinculo() =>
      _usuarios.where((u) => u.ehColetor && u.vinculos.isEmpty).toList();

  void vincularColetor(String coletorId, String instituicaoId) {
    final u = _usuarios.firstWhere((x) => x.id == coletorId);
    u.vinculos[instituicaoId] = DateTime.now();
    notifyListeners();
  }

  void desvincularColetor(String coletorId, String instituicaoId) {
    final u = _usuarios.firstWhere((x) => x.id == coletorId);
    u.vinculos.remove(instituicaoId);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // VISITAS / HISTÓRICO
  // ═══════════════════════════════════════════════════════════════════════
  List<VisitaModel> _ordenadas(Iterable<VisitaModel> vs) =>
      vs.toList()..sort((a, b) => b.dataHora.compareTo(a.dataHora));

  List<VisitaModel> visitasDoColetor(String coletorId) =>
      _ordenadas(_visitas.where((v) => v.coletorId == coletorId));

  List<VisitaModel> visitasDaLixeira(String lixeiraId) =>
      _ordenadas(_visitas.where((v) => v.lixeiraId == lixeiraId));

  List<VisitaModel> visitasDasInstituicoes(Iterable<String> ids) {
    final s = ids.toSet();
    return _ordenadas(_visitas.where((v) => s.contains(v.instituicaoId)));
  }

  /// Ranking de coletores por número de coletas nas lixeiras da instituição.
  List<({UsuarioModel coletor, int coletas})> ranking(String instituicaoId) {
    final lista = <({UsuarioModel coletor, int coletas})>[];
    for (final c in coletoresDaInstituicao(instituicaoId)) {
      final n = _visitas
          .where((v) => v.coletorId == c.id && v.instituicaoId == instituicaoId)
          .length;
      lista.add((coletor: c, coletas: n));
    }
    lista.sort((a, b) => b.coletas.compareTo(a.coletas));
    return lista;
  }

  /// Registra a coleta: cria a visita no histórico e esvazia a lixeira.
  VisitaModel registrarColeta(LixeiraModel l, UsuarioModel coletor) {
    final agora = DateTime.now();
    final v = VisitaModel(
      id: _novoId('v'),
      lixeiraId: l.id,
      lixeiraNome: l.nome,
      endereco: l.endereco,
      instituicaoId: l.instituicaoId,
      coletorId: coletor.id,
      coletorNome: coletor.nome,
      dataHora: agora,
      ocupacao: l.ocupacao,
      material: l.materialPredominante,
    );
    _visitas.add(v);
    l.ocupacao = 0;
    l.ultimaColeta = agora;
    notifyListeners();
    return v;
  }
}
