import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/gru_scaffold.dart';
import '../../widgets/home_greeting.dart';
import '../../widgets/liquid_card.dart';
import '../../widgets/logout_button.dart';

/// "Tela Home - Coletor": Lixeiras, Histórico e Instituições.
class ColetorHomeScreen extends StatelessWidget {
  const ColetorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = SessionService.instance.usuario!;
    final db = MockDataService.instance;
    final restFill = AppColors.dark.withValues(alpha: 0.12);

    return ListenableBuilder(
      listenable: db,
      builder: (context, _) {
        final lixeiras = db.lixeirasDasInstituicoes(usuario.instituicaoIds);
        final prioritarias = lixeiras.where((l) => l.status.codigo >= 3).length;
        final coletas = db.visitasDoColetor(usuario.id).length;
        final nInst = usuario.vinculos.length;

        return GruScaffold(
          title: 'Home',
          background: kFundoColetor,
          showBack: false,
          trailing: const LogoutButton(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 150),
            children: [
              HomeGreeting(
                nome: usuario.primeiroNome,
                papel: 'Coletor',
                detalhe: nInst == 0
                    ? 'Aguardando vínculo'
                    : '$nInst ${nInst == 1 ? 'instituição' : 'instituições'}',
              ),
              const SizedBox(height: 24),
              LiquidCard(
                icon: Icons.delete_rounded,
                title: 'Lixeiras',
                subtitle: lixeiras.isEmpty
                    ? 'Nenhuma lixeira disponível'
                    : '$prioritarias prioritárias · ${lixeiras.length} no total',
                color: AppColors.dark,
                restFill: restFill,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.coletorLixeiras),
              ),
              const SizedBox(height: 18),
              LiquidCard(
                icon: Icons.history_rounded,
                title: 'Histórico',
                subtitle: coletas == 0
                    ? 'Nenhuma coleta registrada ainda'
                    : '$coletas ${coletas == 1 ? 'coleta registrada' : 'coletas registradas'}',
                color: AppColors.dark,
                restFill: restFill,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.coletorHistorico),
              ),
              const SizedBox(height: 18),
              LiquidCard(
                icon: Icons.apartment_rounded,
                title: 'Instituições',
                subtitle: nInst == 0
                    ? 'Você ainda não está vinculado'
                    : '$nInst ${nInst == 1 ? 'vinculada' : 'vinculadas'}',
                color: AppColors.dark,
                restFill: restFill,
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.coletorInstituicoes),
              ),
            ],
          ),
        );
      },
    );
  }
}
