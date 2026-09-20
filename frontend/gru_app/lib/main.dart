import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const GruApp());
}

/// App G.R.U (Gerenciador de Resíduos Urbanos) para Android.
class GruApp extends StatelessWidget {
  const GruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'G.R.U',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.loading,
      routes: AppRoutes.table,
    );
  }
}
