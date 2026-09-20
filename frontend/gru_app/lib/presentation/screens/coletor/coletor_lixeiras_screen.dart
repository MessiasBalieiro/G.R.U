import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/session_service.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gru_scaffold.dart';
import '../../widgets/lixeira_card.dart';
import '../../widgets/search_field.dart';

enum _Filtro { todas, prioridade, atencao, tranquilas }

/// "Tela Lixeiras - Coletor": capacidade, material predominante e
/// localização das lixeiras das instituições do coletor.
class ColetorLixeirasScreen extends StatefulWidget {
  const ColetorLixeirasScreen({super.key});

  @override
  State<ColetorLixeirasScreen> createState() => _ColetorLixeirasScreenState();
}

class _ColetorLixeirasScreenState extends State<ColetorLixeirasScreen> {
  final _busca = TextEditingController();
  String _termo = '';
  _Filtro _filtro = _Filtro.todas;

  static const _rotulos = {
    _Filtro.todas: 'Todas',
    _Filtro.prioridade: 'Prioridade',
    _Filtro.atencao: 'Atenção',
    _Filtro.tranquilas: 'Tranquilas',
  };

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  bool _passa(int codigo) {
    switch (_filtro) {
      case _Filtro.todas:
        return true;
      case _Filtro.prioridade:
        return codigo >= 3;
      case _Filtro.atencao:
        return codigo == 2;
      case _Filtro.tranquilas:
        return codigo <= 1;
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
                _passa(l.status.codigo) &&
                (termo.isEmpty ||
                    l.nome.toLowerCase().contains(termo) ||
                    l.endereco.toLowerCase().contains(termo)))
            .toList()
          ..sort((a, b) => b.ocupacao.compareTo(a.ocupacao));

        return GruScaffold(
          title: 'Lixeiras',
          background: kFundoColetor,
          child: todas.isEmpty
              ? EmptyState(
                  icon: Icons.link_off_rounded,
                  titulo: 'Sem lixeiras por aqui',
                  mensagem: usuario.vinculos.isEmpty
                      ? 'Você ainda não está vinculado a nenhuma instituição. '
                          'Peça ao administrador para vincular você.'
                      : 'As instituições vinculadas ainda não têm lixeiras.',
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: SearchField(
                        controller: _busca,
                        onChanged: (v) => setState(() => _termo = v),
                      ),
                    ),
                    SizedBox(
                      height: 52,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                        children: [
                          for (final f in _Filtro.values) ...[
                            _FiltroChip(
                              rotulo: _rotulos[f]!,
                              selecionado: _filtro == f,
                              onTap: () => setState(() => _filtro = f),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: lista.isEmpty
                          ? const EmptyState(
                              icon: Icons.search_off_rounded,
                              titulo: 'Nada encontrado',
                              mensagem:
                                  'Tente outro filtro ou outra busca.',
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 6, 20, 150),
                              itemCount: lista.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final l = lista[i];
                                final inst =
                                    db.instituicaoPorId(l.instituicaoId);
                                return LixeiraCard(
                                  lixeira: l,
                                  mostrarMapa: true,
                                  rodape: inst?.nome,
                                  onTap: () => Navigator.of(context)
                                      .pushNamed(AppRoutes.lixeira,
                                          arguments: l.id),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _FiltroChip extends StatelessWidget {
  const _FiltroChip({
    required this.rotulo,
    required this.selecionado,
    required this.onTap,
  });

  final String rotulo;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selecionado ? AppColors.dark : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          rotulo,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
