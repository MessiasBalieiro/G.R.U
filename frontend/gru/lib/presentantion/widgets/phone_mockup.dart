import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'gru_mascot.dart';

/// Moldura de celular que exibe o print do app.
/// Se a imagem não existir, mostra uma tela ilustrativa no lugar.
class PhoneMockup extends StatelessWidget {
  const PhoneMockup({super.key, required this.imageAsset, this.width = 260});

  final String imageAsset;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 2.05;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2733),
        borderRadius: BorderRadius.circular(width * 0.14),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withOpacity(0.35),
            blurRadius: 40,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.11),
        child: Image.asset(
          imageAsset,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => const _TelaIlustrativa(),
        ),
      ),
    );
  }
}

class _TelaIlustrativa extends StatelessWidget {
  const _TelaIlustrativa();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F6F8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.green,
            padding: const EdgeInsets.fromLTRB(14, 26, 14, 14),
            child: const Row(
              children: [
                GruMascot(size: 28),
                SizedBox(width: 8),
                Text('G.R.U',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: _indicador('Lixeiras', '24', AppColors.green)),
                const SizedBox(width: 8),
                Expanded(child: _indicador('Cheias', '3', AppColors.orange)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final h in [0.35, 0.6, 0.45, 0.8, 0.55, 0.7])
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: h,
                        child: Container(
                          width: 18,
                          decoration: BoxDecoration(
                            color: h > 0.7 ? AppColors.orange : AppColors.dark,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.home_rounded, color: AppColors.green),
                Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
                Icon(Icons.bar_chart_rounded, color: AppColors.textMuted),
                Icon(Icons.chat_bubble_outline, color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicador(String titulo, String valor, Color cor) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted)),
            Text(valor,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: cor)),
          ],
        ),
      );
}
