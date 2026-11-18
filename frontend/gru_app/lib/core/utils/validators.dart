/// Validadores simples usados nos formulários.
class Validators {
  Validators._();

  static String? obrigatorio(String? v, [String campo = 'Campo']) {
    if (v == null || v.trim().isEmpty) return '$campo obrigatório';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'E-mail obrigatório';
    final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim());
    return ok ? null : 'E-mail inválido';
  }

  static String? senha(String? v) {
    if (v == null || v.isEmpty) return 'Senha obrigatória';
    if (v.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  static String? telefone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Telefone obrigatório';

    final ok = RegExp(r'^\(\d{2}\) \d{5}-\d{4}$').hasMatch(v.trim());

    return ok ? null : 'Telefone inválido';
  }

  static String? cpf(String? v) {
    if (v == null || v.trim().isEmpty) return 'CPF obrigatório';

    final ok = RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$').hasMatch(v.trim());

    return ok ? null : 'CPF inválido';
  }
}
