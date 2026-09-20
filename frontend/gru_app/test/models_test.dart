import 'package:flutter_test/flutter_test.dart';
import 'package:gru_app/core/utils/cep.dart';
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
      cep: '01001-000',
      logradouro: 'Praça da Sé',
      numero: '100',
      bairro: 'Sé',
      cidade: 'São Paulo',
      uf: 'SP',
      composicao: {TipoResiduo.vidro: 60, TipoResiduo.papel: 40},
    );
    expect(l.materialPredominante, TipoResiduo.vidro);
    expect(l.percentualPredominante, 60);
    expect(l.nomeCurto, 'Teste');
  });

  test('endereço é montado a partir do CEP', () {
    final l = LixeiraModel(
      id: 'y',
      nome: 'Lixeira Teste',
      instituicaoId: 'i1',
      cep: '01001000',
      logradouro: 'Praça da Sé',
      numero: '100',
      complemento: 'Lado B',
      bairro: 'Sé',
      cidade: 'São Paulo',
      uf: 'SP',
    );
    expect(l.cepFormatado, '01001-000');
    expect(l.logradouroNumero, 'Praça da Sé, 100 - Lado B');
    expect(l.enderecoCompleto,
        'Praça da Sé, 100, Sé, São Paulo - SP, 01001-000');
  });

  test('utilitários de CEP', () {
    expect(Cep.digitos('01001-000'), '01001000');
    expect(Cep.valido('01001-000'), isTrue);
    expect(Cep.valido('0100'), isFalse);
    expect(Cep.formatar('01001000'), '01001-000');
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
