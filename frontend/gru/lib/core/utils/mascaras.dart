import 'package:flutter/services.dart';

String formatarCpf(String digitos) {
  final b = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i == 3 || i == 6) b.write('.');
    if (i == 9) b.write('-');
    b.write(digitos[i]);
  }
  return b.toString();
}

String formatarTelefone(String digitos) {
  final b = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i == 0) b.write('(');
    if (i == 2) b.write(') ');
    if (digitos.length == 11 ? i == 7 : i == 6) b.write('-');
    b.write(digitos[i]);
  }
  return b.toString();
}

/// Aceita só números e aplica a máscara enquanto a pessoa digita.
class MascaraFormatter extends TextInputFormatter {
  const MascaraFormatter(this.formatar, this.maxDigitos);

  /// CPF: `000.000.000-00`
  const MascaraFormatter.cpf() : this(formatarCpf, 11);

  /// Telefone: `(11) 91234-5678`
  const MascaraFormatter.telefone() : this(formatarTelefone, 11);

  final String Function(String digitos) formatar;
  final int maxDigitos;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue antigo, TextEditingValue novo) {
    var d = novo.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > maxDigitos) d = d.substring(0, maxDigitos);
    final t = formatar(d);
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}

/// Validações usadas nos formulários.
class Validadores {
  Validadores._();

  static String? obrigatorio(String? v, String campo) =>
      (v == null || v.trim().isEmpty) ? 'Informe $campo' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe seu email';
    return RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim())
        ? null
        : 'Email inválido';
  }

  static String? telefone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe seu telefone';
    return RegExp(r'^\(\d{2}\) \d{4,5}-\d{4}$').hasMatch(v.trim())
        ? null
        : 'Use o formato (11) 91234-5678';
  }

  static String? cpf(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe seu CPF';
    final d = v.replaceAll(RegExp(r'\D'), '');
    if (d.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(d)) {
      return 'CPF inválido';
    }
    int digito(int tamanho) {
      var soma = 0;
      for (var i = 0; i < tamanho; i++) {
        soma += int.parse(d[i]) * (tamanho + 1 - i);
      }
      final r = (soma * 10) % 11;
      return r == 10 ? 0 : r;
    }

    return (digito(9) == int.parse(d[9]) && digito(10) == int.parse(d[10]))
        ? null
        : 'CPF inválido';
  }

  static String? senha(String? v) {
    if (v == null || v.isEmpty) return 'Informe uma senha';
    return v.length >= 4 ? null : 'Use ao menos 4 caracteres';
  }
}
