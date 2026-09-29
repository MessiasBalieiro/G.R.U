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
}
