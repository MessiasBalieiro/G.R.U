import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/domain_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/instituicao_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gru_scaffold.dart';
import '../../widgets/white_card.dart';

/// "Tela Instituições - Coletor": instituições às quais o coletor está
/// vinculado, com as lixeiras de cada uma.
class ColetorInstituicoesScreen extends StatelessWidget {
  const ColetorInstituicoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = SessionService.instance.usuario!;
    final db = MockDataService.instance;

    return ListenableBuilder(
      listenable: db,
      builder: (context, _) {
        final vinculos = usuario.vinculos.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (vinculos.isEmpty) {
          return const GruScaffold(
            title: 'Instituições',
            background: kFundoColetor,
            child: EmptyState(
              icon: Icons.apartment_rounded,
              titulo: 'Nenhum vínculo ainda',
              mensagem:
                  'O administrador da sua instituição precisa vincular você para que as lixeiras apareçam.',
            ),
          );
        }

        return GruScaffold(
          title: 'Instituições',
          background: kFundoColetor,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 150),
            itemCount: vinculos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final inst = db.instituicaoPorId(vinculos[i].key);
              if (inst == null) return const SizedBox.shrink();
              return _InstituicaoCard(
                instituicao: inst,
                desde: vinculos[i].value,
              );
            },
          ),
        );
      },
    );
  }
}

class _InstituicaoCard extends StatefulWidget {
  const _InstituicaoCard({required this.instituicao, required this.desde});

  final InstituicaoModel instituicao;
  final DateTime desde;

  @override
  State<_InstituicaoCard> createState() => _InstituicaoCardState();
}

class _InstituicaoCardState extends State<_InstituicaoCard> {
  bool _aberto = false;

  @override
  Widget build(BuildContext context) {
    final db = MockDataService.instance;
    final inst = widget.instituicao;
    final lixeiras = db.lixeirasDasInstituicoes([inst.id])
      ..sort((a, b) => b.ocupacao.compareTo(a.ocupacao));
    final prioritarias = lixeiras.where((l) => l.status.codigo >= 3).length;

    return WhiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _aberto = !_aberto),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.dark,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        inst.inicial,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inst.nome,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.dark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${inst.cidade} · desde ${Fmt.mesAno(widget.desde)}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${lixeiras.length} '
                          '${lixeiras.length == 1 ? 'lixeira' : 'lixeiras'}'
                          '${prioritarias > 0 ? ' · $prioritarias prioritárias' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: prioritarias > 0
                                ? AppColors.orange
                                : AppColors.greenDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _aberto ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded,
                        color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _aberto
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      children: [
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        if (lixeiras.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text('Nenhuma lixeira cadastrada.',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textMuted)),
                          ),
                        for (final l in lixeiras)
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.lixeira,
                                arguments: l.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 2),
                              child: Row(
                                children: [
                                  Icon(Icons.delete_rounded,
                                      size: 18, color: corDoStatus(l.status)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(l.nome,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.dark)),
                                  ),
                                  Text('${l.ocupacao}%',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: corDoStatus(l.status))),
                                  const Icon(Icons.chevron_right_rounded,
                                      size: 18, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
