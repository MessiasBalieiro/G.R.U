import 'package:flutter_test/flutter_test.dart';
import 'package:gru_app/data/models/lixeira_model.dart';
import 'package:gru_app/data/models/residuo_model.dart';
import 'package:gru_app/data/services/mock_data_service.dart';

void main() {
  test('status é derivado da ocupação', () {
    expect(StatusLixeira.fromOcupacao(0), StatusLixeira.vazia);
    expect(StatusLixeira.fromOcupacao(25), StatusLixeira.baixa);
    expect(StatusLixeira.fromOcupacao(50), StatusLixeira.media);
    expect(StatusLixeira.fromOcupacao(75), StatusLixeira.alta);
    expect(StatusLixeira.fromOcupacao(95), StatusLixeira.cheia);
  });

  test('material predominante', () {
    final l = LixeiraModel(
      id: 'x',
      nome: 'Lixeira Teste',
      instituicaoId: 'i1',
      endereco: 'Rua A',
      latitude: 0,
      longitude: 0,
      composicao: {TipoResiduo.vidro: 60, TipoResiduo.papel: 40},
    );
    expect(l.materialPredominante, TipoResiduo.vidro);
    expect(l.percentualPredominante, 60);
    expect(l.nomeCurto, 'Teste');
  });

  test('registrar coleta esvazia a lixeira e cria histórico', () {
    final db = MockDataService.instance;
    final coletor = db.autenticar('coletor@gru.com', 'gru123')!;
    final l = db.lixeiraPorId('l2')!;
    final antes = db.visitasDoColetor(coletor.id).length;

    db.registrarColeta(l, coletor);

    expect(l.ocupacao, 0);
    expect(db.visitasDoColetor(coletor.id).length, antes + 1);
  });

  test('coletor novo só vê lixeiras depois do vínculo', () {
    final db = MockDataService.instance;
    final ana = db.autenticar('ana@gru.com', 'gru123')!;
    expect(db.lixeirasDasInstituicoes(ana.instituicaoIds), isEmpty);

    db.vincularColetor(ana.id, 'i1');
    expect(db.lixeirasDasInstituicoes(ana.instituicaoIds), isNotEmpty);
  });
}
