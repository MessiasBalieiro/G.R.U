import 'package:flutter/material.dart';

/// Paleta de cores oficial do G.R.U (Gerenciador de Resíduos Urbanos).
class AppColors {
  AppColors._();

  /// Laranja principal - usado em botões de destaque (Login, Cadastre-se,
  /// Download, Gerar Relatório) e em ícones/detalhes da área de trabalho.
  static const Color orange = Color(0xFFE67818);

  /// Verde principal - usado em seções de destaque (Lixeira Inteligente),
  /// telas de autenticação e como cor de "sucesso"/ação positiva.
  static const Color green = Color(0xFF2ECC71);

  /// Azul escuro - usado como cor de fundo dos cards "Quem Somos",
  /// do painel de Login/Cadastro e como cor de texto principal.
  static const Color dark = Color(0xFF2C3E50);

  // Tons derivados
  static const Color orangeDark = Color(0xFFC7650F);
  static const Color orangeLight = Color(0xFFFFB877);
  static const Color greenDark = Color(0xFF239954);
  static const Color greenLight = Color(0xFFA9F0C6);
  static const Color darkLight = Color(0xFF3E5771);

  static const Color background = Color(0xFFF5F6F8);
  static const Color surface = Colors.white;
  static const Color placeholder = Color(0xFFD9D9D9);
  static const Color textMuted = Color(0xFF8592A0);
}
