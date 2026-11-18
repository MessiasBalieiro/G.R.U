import 'package:flutter/material.dart';
import '../../core/constants/app_images.dart';
import '../../data/services/social_auth_service.dart';
import 'hover_lift.dart';

/// Linha com os botões de login social (Google / Apple / Microsoft)
/// das telas de Login e Cadastro.
///
/// [onSelecionar] é chamado ao tocar num provedor. Enquanto ele roda, os
/// botões ficam desativados e o escolhido mostra um indicador de carregamento.
class SocialLoginRow extends StatefulWidget {
  const SocialLoginRow({super.key, this.onSelecionar, this.iconSize = 26});

  final Future<void> Function(ProvedorSocial provedor)? onSelecionar;

  /// Tamanho de cada logo - permite deixar a linha maior em telas largas.
  final double iconSize;

  @override
  State<SocialLoginRow> createState() => _SocialLoginRowState();
}

class _SocialLoginRowState extends State<SocialLoginRow> {
  ProvedorSocial? _ocupado;

  Future<void> _tocar(ProvedorSocial p) async {
    if (_ocupado != null) return;
    final acao = widget.onSelecionar;
    if (acao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login social em breve.')),
      );
      return;
    }
    setState(() => _ocupado = p);
    try {
      await acao(p);
    } finally {
      if (mounted) setState(() => _ocupado = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.iconSize;
    final gap = size * 0.9;

    Widget icone(ProvedorSocial p, String asset, String dica) => _SocialIcon(
          asset: asset,
          dica: dica,
          size: size,
          carregando: _ocupado == p,
          desativado: _ocupado != null && _ocupado != p,
          onTap: () => _tocar(p),
        );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size * 0.9, vertical: size * 0.55),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icone(ProvedorSocial.google, AppImages.googleLogo, 'Entrar com Google'),
          SizedBox(width: gap),
          icone(ProvedorSocial.apple, AppImages.appleLogo, 'Entrar com Apple'),
          SizedBox(width: gap),
          icone(ProvedorSocial.microsoft, AppImages.microsoftLogo,
              'Entrar com Microsoft'),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({
    required this.asset,
    required this.dica,
    required this.size,
    required this.onTap,
    required this.carregando,
    required this.desativado,
  });

  final String asset;
  final String dica;
  final double size;
  final VoidCallback onTap;
  final bool carregando;
  final bool desativado;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: dica,
      child: HoverLift(
        radius: 20,
        lift: 2,
        scale: 1.18,
        enabled: !desativado,
        glowColor: Colors.black,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: desativado ? 0.35 : 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: desativado || carregando ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: size,
                height: size,
                child: carregando
                    ? const Padding(
                        padding: EdgeInsets.all(3),
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : Image.asset(asset, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
