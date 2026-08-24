// Teste básico de smoke test do app G.R.U.
//
// Garante que o app sobe na Home sem erros e que o botão de Login
// leva até a tela de Login.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gru/main.dart';

void main() {
  testWidgets('App inicia na Home e navega para o Login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GruApp());
    await tester.pumpAndSettle();

    expect(find.text('G.R.U'), findsWidgets);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Não possui conta?'), findsOneWidget);
  });
}
