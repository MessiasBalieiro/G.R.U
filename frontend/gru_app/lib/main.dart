import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gru_app/providers/lixeira_provider.dart';
import 'package:gru_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LixeiraProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider(context.read<LixeiraProvider>())),
      ],
      child: const GruApp()
    )
  );
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
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
