import 'package:flutter/services.dart';

/// Utilitários de CEP (formato 00000-000).
class Cep {
  Cep._();

  static String digitos(String s) => s.replaceAll(RegExp(r'\D'), '');

  static bool valido(String s) => digitos(s).length == 8;

  /// "01001000" → "01001-000". Se não tiver 8 dígitos, devolve o texto como veio.
  static String formatar(String s) {
    final d = digitos(s);
    if (d.length != 8) return s;
    return '${d.substring(0, 5)}-${d.substring(5)}';
  }
}

/// Máscara de digitação: só números, no formato 00000-000.
class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var d = Cep.digitos(newValue.text);
    if (d.length > 8) d = d.substring(0, 8);
    final texto = d.length > 5 ? '${d.substring(0, 5)}-${d.substring(5)}' : d;
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
