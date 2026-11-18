import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/lixeira_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LixeiraProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider(context.read<LixeiraProvider>())..restaurarSessao()),
      ],
      child: const GruApp()
    )
  );
}

/// App raiz do G.R.U (Gerenciador de Resíduos Urbanos).
class GruApp extends StatelessWidget {
  const GruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'G.R.U - ' + AppStrings.appFullName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.table,
    );
  }
}
