import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/ciclo_model.dart';

/// Envolve um gráfico do Dashboard e o liga ao Ciclo:
///  * botão "Perguntar ao Ciclo" no canto (abre o chat com uma pergunta
///    sobre aquele gráfico);
///  * contorno verde pulsante quando o Ciclo usou esse gráfico na resposta.
class CicloChartFrame extends StatefulWidget {
  const CicloChartFrame({
    super.key,
    required this.grafico,
    required this.destacado,
    required this.onPerguntar,
    required this.child,
  });

  final CicloGrafico grafico;
  final bool destacado;
  final void Function(CicloGrafico) onPerguntar;
  final Widget child;

  @override
  State<CicloChartFrame> createState() => _CicloChartFrameState();
}

class _CicloChartFrameState extends State<CicloChartFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulso = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    if (widget.destacado) _pulso.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(CicloChartFrame old) {
    super.didUpdateWidget(old);
    if (widget.destacado && !_pulso.isAnimating) {
      _pulso.repeat(reverse: true);
    } else if (!widget.destacado && _pulso.isAnimating) {
      _pulso
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulso,
      builder: (context, child) {
        final t = widget.destacado ? _pulso.value : 0.0;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: widget.destacado ? AppColors.green : Colors.transparent,
              width: 3,
            ),
            boxShadow: widget.destacado
                ? [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.25 + 0.35 * t),
                      blurRadius: 8 + 14 * t,
                      spreadRadius: 1 + 2 * t,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 8,
            right: 8,
            child: Tooltip(
              message: 'Perguntar ao Ciclo',
              child: Material(
                color: AppColors.green.withValues(alpha: 0.14),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => widget.onPerguntar(widget.grafico),
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: Icon(Icons.auto_awesome_rounded,
                        size: 17, color: AppColors.greenDark),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
