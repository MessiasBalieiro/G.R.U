import 'package:flutter/material.dart';

import '../../core/constants/app_images.dart';
import '../../core/theme/app_colors.dart';

/// Botão flutuante "Pergunte ao Ciclo" (mascote + rótulo) que abre o chat,
/// com um leve movimento de "flutuar".
class CicloFab extends StatefulWidget {
  const CicloFab({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<CicloFab> createState() => _CicloFabState();
}

class _CicloFabState extends State<CicloFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -4 * Curves.easeInOut.transform(_c.value)),
        child: child,
      ),
      child: Material(
        color: AppColors.green,
        elevation: 6,
        shadowColor: Colors.black45,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 7, 18, 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(AppImages.gruMascot),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Pergunte ao Ciclo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
