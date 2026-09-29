import 'package:flutter/material.dart';

/// Paleta oficial do G.R.U (mesma da versão web).
///
/// Cores de marca: [orange], [green] e [dark]. As demais são apoio
/// (severidade de ocupação, tipos de resíduo, textos e fundos).
class AppColors {
  AppColors._();

  // ── Marca ────────────────────────────────────────────────────────────────
  static const Color orange = Color(0xFFE67818);
  static const Color green = Color(0xFF2ECC71);
  static const Color dark = Color(0xFF2C3E50);

  // ── Variações ────────────────────────────────────────────────────────────
  static const Color orangeDark = Color(0xFFC7650F);
  static const Color orangeLight = Color(0xFFFFB877);
  static const Color greenDark = Color(0xFF239954);
  static const Color greenLight = Color(0xFFA9F0C6);
  static const Color darkLight = Color(0xFF3E5771);

  // ── Apoio ────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F6F8);
  static const Color surface = Colors.white;
  static const Color textMuted = Color(0xFF8592A0);
  static const Color danger = Color(0xFFE74C3C);
  static const Color amber = Color(0xFFF2B84B);
  static const Color sky = Color(0xFF5DADE2);
}
