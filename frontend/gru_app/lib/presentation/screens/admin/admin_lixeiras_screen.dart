import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gru_scaffold.dart';
import '../../widgets/lixeira_card.dart';
import '../../widgets/search_field.dart';
import 'nova_lixeira_sheet.dart';

/// "Tela Lixeiras - Admin": lista das lixeiras da instituição + cadastro.
class AdminLixeirasScreen extends StatefulWidget {
  const AdminLixeirasScreen({super.key});

  @override
  State<AdminLixeirasScreen> createState() => _AdminLixeirasScreenState();
}

class _AdminLixeirasScreenState extends State<AdminLixeirasScreen> {
  final _busca = TextEditingController();
  String _termo = '';

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  Future<void> _nova() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const NovaLixeiraSheet(),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lixeira cadastrada!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = SessionService.instance.usuario!;
    final db = MockDataService.instance;

    return ListenableBuilder(
      listenable: db,
      builder: (context, _) {
        final todas = db.lixeirasDasInstituicoes(usuario.instituicaoIds);
        final termo = _termo.trim().toLowerCase();
        final lista = todas
            .where((l) =>
                termo.isEmpty ||
                l.nome.toLowerCase().contains(termo) ||
                l.endereco.toLowerCase().contains(termo))
            .toList()
          ..sort((a, b) => b.ocupacao.compareTo(a.ocupacao));

        return GruScaffold(
          title: 'Lixeiras',
          background: kFundoAdmin,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: SearchField(
                        controller: _busca,
                        onChanged: (v) => setState(() => _termo = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: AppColors.orange,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _nova,
                        child: const Padding(
                          padding: EdgeInsets.all(13),
                          child: Icon(Icons.add_rounded,
                              color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${lista.length} '
                    '${lista.length == 1 ? 'lixeira' : 'lixeiras'} · '
                    'ordenadas por ocupação',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                child: lista.isEmpty
                    ? EmptyState(
                        icon: Icons.delete_outline_rounded,
                        titulo: todas.isEmpty
                            ? 'Nenhuma lixeira ainda'
                            : 'Nada encontrado',
                        mensagem: todas.isEmpty
                            ? 'Toque no + para cadastrar sua primeira lixeira inteligente.'
                            : 'Tente buscar por outro nome ou endereço.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 150),
                        itemCount: lista.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => LixeiraCard(
                          lixeira: lista[i],
                          onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.lixeira,
                              arguments: lista[i].id),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
