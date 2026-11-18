import 'package:flutter/material.dart';
import 'package:gru_app/providers/lixeira_provider.dart';
import 'package:gru_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/gru_scaffold.dart';
import '../../widgets/home_greeting.dart';
import '../../widgets/liquid_card.dart';
import '../../widgets/logout_button.dart';

/// "Tela Home - Admin": Lixeiras, Dashboard e Coletores.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final providerWatch = context.watch<LixeiraProvider>();
    // final providerRead = context.read<LixeiraProvider>();
    // final providerReadUsuario = context.read<AuthProvider>();
    final providerWatchUsuario = context.watch<AuthProvider>();

    final usuario = providerWatchUsuario.usuario;

    return ListenableBuilder(
      listenable: providerWatchUsuario,
      builder: (context, _) {
        final inst = usuario?.instituicao;
        final lixeiras = providerWatch.lixeiras;
        final prioritarias = lixeiras.where((l) => l.statusLixeira.codigo >= 3).length;
        final vinculados = providerWatchUsuario.coletores.length;

        // final pendentes = db.coletoresSemVinculo().length;

        return GruScaffold(
          title: 'Home',
          background: kFundoAdmin,
          showBack: false,
          trailing: const LogoutButton(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 150),
            children: [
              HomeGreeting(
                nome: usuario?.instituicao ?? "",
                papel: 'Administrador',
                detalhe: inst ?? 'Sem instituição',
              ),
              const SizedBox(height: 24),
              LiquidCard(
                icon: Icons.delete_rounded,
                title: 'Lixeiras',
                subtitle: '${lixeiras.length} monitoradas · '
                    '$prioritarias precisam de coleta',
                color: AppColors.green,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.adminLixeiras),
              ),
              const SizedBox(height: 18),
              LiquidCard(
                icon: Icons.bar_chart_rounded,
                title: 'Dashboard',
                subtitle: 'Ocupação, tipos de resíduo e atividade',
                color: AppColors.green,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.adminDashboard),
              ),
              const SizedBox(height: 18),
              LiquidCard(
                icon: Icons.groups_rounded,
                title: 'Coletores',
                subtitle: '$vinculados vinculados',
                color: AppColors.green,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.adminColetores),
              ),
            ],
          ),
        );
      },
    );
  }
}
