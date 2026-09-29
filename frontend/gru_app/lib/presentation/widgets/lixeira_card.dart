import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/domain_styles.dart';
import '../../core/utils/map_launcher.dart';
import '../../data/models/lixeira_model.dart';
import 'capacity.dart';
import 'white_card.dart';

/// Item de lista de lixeira: nome, endereço, capacidade, status e material
/// predominante. Usado nas listas do Admin e do Coletor.
class LixeiraCard extends StatelessWidget {
  const LixeiraCard({
    super.key,
    required this.lixeira,
    required this.onTap,
    this.mostrarMapa = false,
    this.rodape,
  });

  final LixeiraModel lixeira;
  final VoidCallback onTap;

  /// Mostra o atalho "abrir no mapa" (usado pelo coletor).
  final bool mostrarMapa;

  /// Texto opcional abaixo dos chips (ex.: nome da instituição).
  final String? rodape;

  @override
  Widget build(BuildContext context) {
    final l = lixeira;
    final cor = corDoStatus(l.status);
    final material = l.materialPredominante;

    return WhiteCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delete_rounded, color: cor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.place_rounded,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            l.endereco,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${l.ocupacao}%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: cor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CapacityBar(ocupacao: l.ocupacao),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    StatusChip(status: l.status),
                    if (material != null)
                      MaterialChip(
                          tipo: material, percentual: l.percentualPredominante),
                  ],
                ),
              ),
              if (mostrarMapa)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => abrirNoMapa(context, l),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_rounded,
                        size: 20, color: AppColors.orange),
                  ),
                ),
            ],
          ),
          if (rodape != null) ...[
            const SizedBox(height: 10),
            Text(
              rodape!,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
