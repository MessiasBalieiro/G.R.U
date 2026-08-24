import 'package:flutter/material.dart';
import '../presentantion/screens/home/home_screen.dart';
import '../presentantion/screens/auth/login_screen.dart';
import '../presentantion/screens/auth/cadastro_screen.dart';
import '../presentantion/screens/app_download/app_download_screen.dart';
import '../presentantion/screens/workspace/area_trabalho_screen.dart';
import '../presentantion/screens/workspace/cadastro_lixeira_screen.dart';
import '../presentantion/screens/workspace/gerar_relatorio_screen.dart';
import '../presentantion/screens/workspace/dashboard_screen.dart';

/// Nomes de rota + tabela de rotas do app, na mesma ordem das telas do
/// design: Home, Login, Cadastro, App, Área de Trabalho, Cadastro Lixeira,
/// Gerar Relatório e Dashboard.
class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const login = '/login';
  static const cadastro = '/cadastro';
  static const appDownload = '/app';
  static const areaTrabalho = '/area-trabalho';
  static const cadastroLixeira = '/cadastro-lixeira';
  static const gerarRelatorio = '/gerar-relatorio';
  static const dashboard = '/dashboard';

  static Map<String, WidgetBuilder> get table => {
        home: (_) => const HomeScreen(),
        login: (_) => const LoginScreen(),
        cadastro: (_) => const CadastroScreen(),
        appDownload: (_) => const AppDownloadScreen(),
        areaTrabalho: (_) => const AreaTrabalhoScreen(),
        cadastroLixeira: (_) => const CadastroLixeiraScreen(),
        gerarRelatorio: (_) => const GerarRelatorioScreen(),
        dashboard: (_) => const DashboardScreen(),
      };
}
