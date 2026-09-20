import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/session_service.dart';
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
    final usuario = SessionService.instance.usuario!;
    final db = MockDataService.instance;

    return ListenableBuilder(
      listenable: db,
      builder: (context, _) {
        final instId = usuario.instituicaoPrincipalId;
        final inst = instId == null ? null : db.instituicaoPorId(instId);
        final lixeiras = db.lixeirasDasInstituicoes(usuario.instituicaoIds);
        final prioritarias = lixeiras.where((l) => l.status.codigo >= 3).length;
        final vinculados =
            instId == null ? 0 : db.coletoresDaInstituicao(instId).length;
        final pendentes = db.coletoresSemVinculo().length;

        return GruScaffold(
          title: 'Home',
          background: kFundoAdmin,
          showBack: false,
          trailing: const LogoutButton(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 150),
            children: [
              HomeGreeting(
                nome: usuario.primeiroNome,
                papel: 'Administrador',
                detalhe: inst?.nome ?? 'Sem instituição',
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
                subtitle: '$vinculados vinculados'
                    '${pendentes > 0 ? ' · $pendentes aguardando vínculo' : ''}',
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
