import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

/// Volta para a Área de Trabalho
void _irParaAreaTrabalho(BuildContext context) {
  final navigator = Navigator.of(context);
  var encontrada = false;
  navigator.popUntil((route) {
    if (route.settings.name == AppRoutes.areaTrabalho) {
      encontrada = true;
      return true;
    }
    return route.isFirst;
  });
  if (!encontrada) {
    navigator.pushNamed(AppRoutes.areaTrabalho);
  }
}

class WorkspaceHeader extends StatelessWidget {
  const WorkspaceHeader({
    super.key,
    required this.title,
    this.accentColor = AppColors.orange,
    this.onBack,
  });

  final String title;
  final Color accentColor;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppColors.dark,
            tooltip: 'Voltar',
          )
        else
          Tooltip(
            message: 'Ir para a Área de Trabalho',
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _irParaAreaTrabalho(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.work_outline_rounded, color: accentColor),
              ),
            ),
          ),
        const Spacer(),
        Text(
          title,
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
