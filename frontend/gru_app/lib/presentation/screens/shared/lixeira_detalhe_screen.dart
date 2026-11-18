import 'package:flutter/material.dart';
import 'package:gru_app/data/repositories/lixeira_repository.dart';
import 'package:gru_app/providers/lixeira_provider.dart';
import 'package:gru_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/domain_styles.dart';
import '../../../core/utils/map_launcher.dart';
import '../../../data/models/lixeira_model.dart';
import '../../widgets/capacity.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gru_button.dart';
import '../../widgets/gru_scaffold.dart';
import '../../widgets/white_card.dart';

/// Detalhe da lixeira (recebe o `id` em `arguments`).
///
/// Mostra capacidade, material mais concentrado, localização e coletas.
/// O Coletor ainda vê "Suas visitas aqui" e o botão "Registrar coleta".
class LixeiraDetalheScreen extends StatelessWidget {
  const LixeiraDetalheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final providerWatch = context.watch<LixeiraProvider>();
    final providerWatchUsuario = context.watch<AuthProvider>();
    final repo = LixeiraRepository();

    final id = ModalRoute.of(context)?.settings.arguments as String?;
    final usuario = providerWatchUsuario.usuario;
    final fundo = usuario?.cargoUsuario == "CONTRATANTE" ? kFundoAdmin : kFundoColetor;

    return ListenableBuilder(
      listenable: providerWatch,
      builder: (context, _) {
        final l = id == null ? null : providerWatch.lixeiras.where((lix) => lix.id == id).first;
        if (l == null) {
          return GruScaffold(
            title: 'Lixeira',
            background: fundo,
            child: const EmptyState(
              icon: Icons.search_off_rounded,
              titulo: 'Lixeira não encontrada',
              mensagem: 'Ela pode ter sido removida.',
            ),
          );
        }

        final inst = providerWatchUsuario.organizacoes.where((item) => item['id_contratante'] == l.codigoDonoLixeira).first;
        final Iterable<dynamic> visitas = inst['history'].where((hist) => hist['id_object'] == id);
        final Iterable<dynamic> minhas = usuario!.history.where((hist) => hist['trash_id'] == id);
        final lista = usuario.cargoUsuario == "COLETOR" ? minhas : visitas;

        return GruScaffold(
          title: 'Lixeira',
          background: fundo,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 150),
            children: [
              _CapacidadeCard(lixeira: l, instituicao: inst['organization_name']),
              const SizedBox(height: 14),
              _MaterialCard(lixeira: l),
              const SizedBox(height: 14),
              _LocalizacaoCard(lixeira: l),
              const SizedBox(height: 14),
              WhiteCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Titulo(
                      icone: Icons.history_rounded,
                      texto: usuario.cargoUsuario == "COLETOR"
                          ? 'Suas visitas aqui'
                          : 'Coletas nesta lixeira',
                    ),
                    const SizedBox(height: 12),
                    if (lista.isEmpty)
                      Text(
                        usuario.cargoUsuario == "COLETOR"
                            ? 'Você ainda não coletou nesta lixeira.'
                            : 'Sem coletas para mostrar.',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.dark),
                      ),
                    for (final v in lista.take(4))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 18, color: AppColors.green),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                usuario.cargoUsuario == "COLETOR"
                                    ? '${v['time_action']}'
                                    : '${v['username_action_object'].split(' ').first} · ${v['time_action_object']}',
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.dark),
                              ),
                            ),
                            Text('${v.ocupacao}%',
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (usuario.cargoUsuario == "COLETOR") ...[
                const SizedBox(height: 20),
                Center(
                  child: GruButton(
                    label: 'Registrar coleta',
                    icon: Icons.local_shipping_rounded,
                    width: double.infinity,
                    onPressed: () => _confirmar(context, l, providerWatchUsuario, repo),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmar(BuildContext context, LixeiraModel l, AuthProvider provider, LixeiraRepository repo) async {
    final usuario = provider.usuario;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Registrar coleta?'),
        content: Text(
          'A ${l.nomeLixeira} está ${((l.quantidadeResiduo * 100) / 120).round()}% ocupada. Ao confirmar, a coleta entra no seu histórico e a lixeira volta a 0%.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmar',
                style: TextStyle(
                    color: AppColors.orange, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final thisOrg = provider.organizacoes.where((org) => org['id_contratante'] == l.id).first;
      final horarioAtual = DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.now());
      await repo.coletarLixeira(l.id, usuario!.id, usuario.nomeUsuario, thisOrg['_id']);
      
      provider.adicionarHistorico('Você recolheu os resíduos da Lixeira "${l.nomeLixeira}" pertencente à "${thisOrg['organization_name']}"', horarioAtual, l.id, l.nomeLixeira);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coleta registrada no seu histórico!')),
      );
    }
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 18, color: AppColors.dark),
        const SizedBox(width: 8),
        Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }
}

// ── Capacidade ──────────────────────────────────────────────────────────────
class _CapacidadeCard extends StatelessWidget {
  const _CapacidadeCard({required this.lixeira, required this.instituicao});

  final LixeiraModel lixeira;
  final String? instituicao;

  @override
  Widget build(BuildContext context) {
    final l = lixeira;
    final cor = corDoStatus(l.statusLixeira);
    final precisaColeta = l.statusLixeira.codigo >= 3;

    return WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.nomeLixeira,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 19,
              color: AppColors.dark,
            ),
          ),
          if (instituicao != null) ...[
            const SizedBox(height: 2),
            Text(instituicao!,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textMuted)),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              CapacityRing(lixeira: l),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Capacidade',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '${(100 - ((l.quantidadeResiduo * 100) / 120)).round()}% livre',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatusChip(status: l.statusLixeira),
                    if (precisaColeta) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 16, color: cor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Coleta recomendada',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: cor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Material ────────────────────────────────────────────────────────────────
class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.lixeira});

  final LixeiraModel lixeira;

  @override
  Widget build(BuildContext context) {
    final l = lixeira;
    final ordenados = l.composicao.entries.toList()..sort((a, b) {
      return (b.value as num).compareTo(a.value as num);
    });

    Map<String, dynamic> predominante = {};

    switch(ordenados[0].key) {
      case "quantPlastico":
        predominante = {
          "cor": AppColors.orange,
          "icone": Icons.shopping_bag_outlined,
          "label": "Plástico"
        };
      case "quantVidro":
        predominante = {
          "cor": AppColors.green,
          "icone": Icons.wine_bar,
          "label": "Vidro"
        };
      case "quantMetal":
        predominante = {
          "cor": AppColors.darkLight,
          "icone": Icons.settings,
          "label": "Metal"
        };
      case "quantPapel":
        predominante = {
          "cor": AppColors.sky,
          "icone": Icons.newspaper,
          "label": "Papel"
        };
    }

    return WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Titulo(
              icone: Icons.pie_chart_rounded, texto: 'Material mais concentrado'),
          const SizedBox(height: 14),
          ...[
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: predominante['cor'].withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(predominante['icone'],
                    color: predominante['cor'], size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    predominante['label'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: AppColors.dark,
                    ),
                  ),
                  Text(
                    '${(l.composicao[ordenados[0].key]! * 100) / l.quantidadeResiduo}% do conteúdo',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final t in ordenados)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 62,
                    child: Text(t.key == "quantPlastico" ? "Plástico" : t.key == "quantVidro" ? "Vidro" : t.key == "quantMetal" ? "Metal" : t.key == "quantPapel" ? "Papel" : "",
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.dark)),
                  ),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                          begin: 0, end: (t.value / l.quantidadeResiduo)),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 8,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ColoredBox(
                                    color: AppColors.dark
                                        .withValues(alpha: 0.08)),
                              ),
                              Positioned.fill(
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: v.clamp(0.0, 1.0),
                                  child: ColoredBox(color: t.key == "quantPlastico" ? AppColors.orange : t.key == "quantVidro" ? AppColors.green : t.key == "quantMetal" ? AppColors.darkLight : t.key == "quantPapel" ? AppColors.sky : AppColors.background),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 42,
                    child: Text(
                      '${l.composicao[t] ?? 0}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark),
                    ),
                  ),
                ],
              ),
            ),
        ],
        ],
      ),
    );
  }
}

// ── Localização ─────────────────────────────────────────────────────────────
class _LocalizacaoCard extends StatelessWidget {
  const _LocalizacaoCard({required this.lixeira});

  final LixeiraModel lixeira;

  @override
  Widget build(BuildContext context) {
    final l = lixeira;
    return WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Titulo(icone: Icons.place_rounded, texto: 'Localização'),
          const SizedBox(height: 12),
          Text(l.enderecoLixeira,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark)
            ),
          const SizedBox(height: 14),
          GruButton(
            label: 'Abrir no mapa',
            icon: Icons.directions_rounded,
            color: AppColors.dark,
            width: double.infinity,
            onPressed: () => abrirNoMapa(context, l),
          ),
        ],
      ),
    );
  }
}
