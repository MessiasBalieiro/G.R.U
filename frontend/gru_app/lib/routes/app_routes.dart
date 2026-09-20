import 'package:flutter/material.dart';

import '../data/models/usuario_model.dart';
import '../presentation/screens/admin/admin_coletores_screen.dart';
import '../presentation/screens/admin/admin_dashboard_screen.dart';
import '../presentation/screens/admin/admin_home_screen.dart';
import '../presentation/screens/admin/admin_lixeiras_screen.dart';
import '../presentation/screens/auth/cadastro_coletor_screen.dart';
import '../presentation/screens/auth/cadastro_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/welcome_screen.dart';
import '../presentation/screens/coletor/coletor_historico_screen.dart';
import '../presentation/screens/coletor/coletor_home_screen.dart';
import '../presentation/screens/coletor/coletor_instituicoes_screen.dart';
import '../presentation/screens/coletor/coletor_lixeiras_screen.dart';
import '../presentation/screens/shared/lixeira_detalhe_screen.dart';
import '../presentation/screens/splash/loading_screen.dart';

/// Rotas do app, na ordem do Figma: Loading → Bem-vindo → Login/Cadastro →
/// Home (Admin ou Coletor) → telas internas.
class AppRoutes {
  AppRoutes._();

  static const loading = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const cadastro = '/cadastro';
  static const cadastroColetor = '/cadastro-coletor';

  static const adminHome = '/admin';
  static const adminLixeiras = '/admin/lixeiras';
  static const adminDashboard = '/admin/dashboard';
  static const adminColetores = '/admin/coletores';

  static const coletorHome = '/coletor';
  static const coletorLixeiras = '/coletor/lixeiras';
  static const coletorHistorico = '/coletor/historico';
  static const coletorInstituicoes = '/coletor/instituicoes';

  /// Recebe o `id` da lixeira em `arguments`.
  static const lixeira = '/lixeira';

  static String homePara(TipoUsuario tipo) =>
      tipo == TipoUsuario.administrador ? adminHome : coletorHome;

  static Map<String, WidgetBuilder> get table => {
        loading: (_) => const LoadingScreen(),
        welcome: (_) => const WelcomeScreen(),
        login: (_) => const LoginScreen(),
        cadastro: (_) => const CadastroScreen(),
        cadastroColetor: (_) => const CadastroColetorScreen(),
        adminHome: (_) => const AdminHomeScreen(),
        adminLixeiras: (_) => const AdminLixeirasScreen(),
        adminDashboard: (_) => const AdminDashboardScreen(),
        adminColetores: (_) => const AdminColetoresScreen(),
        coletorHome: (_) => const ColetorHomeScreen(),
        coletorLixeiras: (_) => const ColetorLixeirasScreen(),
        coletorHistorico: (_) => const ColetorHistoricoScreen(),
        coletorInstituicoes: (_) => const ColetorInstituicoesScreen(),
        lixeira: (_) => const LixeiraDetalheScreen(),
      };
}
