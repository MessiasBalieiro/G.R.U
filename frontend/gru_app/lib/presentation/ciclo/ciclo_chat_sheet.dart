import 'package:flutter/material.dart';

import '../../core/constants/app_images.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/ciclo_model.dart';
import 'ciclo_controller.dart';
import 'ciclo_texto.dart';

/// Abre o chat do Ciclo por cima do Dashboard.
///
/// [perguntaInicial] já é enviada ao abrir (usado pelo botão "Perguntar ao
/// Ciclo" de cada gráfico). Devolve o gráfico que o usuário pediu para ver
/// (chip "Ver gráfico"), para o Dashboard rolar até ele.
Future<CicloGrafico?> abrirCiclo(
  BuildContext context,
  CicloController controller, {
  String? perguntaInicial,
}) {
  if (perguntaInicial != null) controller.enviar(perguntaInicial);
  return showModalBottomSheet<CicloGrafico>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CicloSheet(controller: controller),
  );
}

class _CicloSheet extends StatelessWidget {
  const _CicloSheet({required this.controller});
  final CicloController controller;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, _) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: _CicloChat(controller: controller),
        ),
      ),
    );
  }
}

class _CicloChat extends StatefulWidget {
  const _CicloChat({required this.controller});
  final CicloController controller;

  @override
  State<_CicloChat> createState() => _CicloChatState();
}

class _CicloChatState extends State<_CicloChat> {
  final _texto = TextEditingController();

  static const _sugestoes = [
    'Me dá um resumo geral',
    'Qual a rota de coleta de hoje?',
    'Quando as lixeiras vão encher?',
    'Qual material predomina?',
    'Como estão os coletores?',
  ];

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _enviar([String? t]) {
    final texto = t ?? _texto.text;
    if (texto.trim().isEmpty) return;
    _texto.clear();
    widget.controller.enviar(texto);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final msgs = c.mensagens;
        return Column(
          children: [
            _Cabecalho(modo: c.modo),
            Expanded(
              child: ListView.builder(
                reverse: true, // a mais recente fica embaixo, perto do teclado
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                itemCount: msgs.length + (c.carregando ? 1 : 0),
                itemBuilder: (context, i) {
                  if (c.carregando && i == 0) return const _Digitando();
                  final m = msgs[msgs.length - 1 - (i - (c.carregando ? 1 : 0))];
                  return _Bolha(
                    mensagem: m,
                    onVerGrafico: (g) => Navigator.of(context).pop(g),
                  );
                },
              ),
            ),
            if (msgs.length <= 1 && !c.carregando)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _sugestoes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ActionChip(
                    label: Text(_sugestoes[i]),
                    labelStyle: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.dark,
                        fontWeight: FontWeight.w600),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.green),
                    shape: const StadiumBorder(),
                    onPressed: () => _enviar(_sugestoes[i]),
                  ),
                ),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _texto,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _enviar(),
                        decoration: InputDecoration(
                          hintText: 'Pergunte ao Ciclo…',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                                color: AppColors.dark.withValues(alpha: 0.12)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: c.carregando
                          ? AppColors.orange.withValues(alpha: 0.5)
                          : AppColors.orange,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: c.carregando ? null : _enviar,
                        child: const Padding(
                          padding: EdgeInsets.all(13),
                          child: Icon(Icons.send_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.modo});
  final String? modo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 10, 12),
      decoration: const BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const _Avatar(size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ciclo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                    Text(
                      modo == 'offline'
                          ? 'Assistente do Dashboard · modo offline'
                          : 'Assistente do Dashboard',
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Fechar',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.size = 30});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: const BoxDecoration(
        color: AppColors.greenLight,
        shape: BoxShape.circle,
      ),
      child: Image.asset(AppImages.mascot, fit: BoxFit.contain),
    );
  }
}

class _Bolha extends StatelessWidget {
  const _Bolha({required this.mensagem, required this.onVerGrafico});

  final CicloMensagem mensagem;
  final void Function(CicloGrafico) onVerGrafico;

  @override
  Widget build(BuildContext context) {
    final m = mensagem;
    final eu = m.doUsuario;
    final fundo = eu
        ? AppColors.dark
        : m.erro
            ? const Color(0xFFFFEBE8)
            : Colors.white;
    final cor = eu
        ? Colors.white
        : m.erro
            ? const Color(0xFFB23A2B)
            : AppColors.dark;

    // Largura máxima relativa ao espaço do chat (tela no celular, painel
    // no desktop), não à tela inteira.
    return LayoutBuilder(builder: (context, box) {
    final bolha = Container(
      constraints: BoxConstraints(maxWidth: box.maxWidth * (eu ? 0.78 : 0.8)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(eu ? 18 : 4),
          bottomRight: Radius.circular(eu ? 4 : 18),
        ),
        boxShadow: eu
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          eu
              ? Text(m.texto,
                  style: TextStyle(color: cor, fontSize: 14, height: 1.35))
              : CicloTexto(m.texto, cor: cor),
          if (m.graficos.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final g in m.graficos)
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onVerGrafico(g),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bar_chart_rounded,
                              size: 14, color: AppColors.greenDark),
                          const SizedBox(width: 4),
                          Text('Ver ${g.titulo}',
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.greenDark)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: eu ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!eu) ...[const _Avatar(), const SizedBox(width: 6)],
          Flexible(child: bolha),
        ],
      ),
    );
    });
  }
}

/// Três pontinhos animados enquanto o Ciclo "pensa".
class _Digitando extends StatefulWidget {
  const _Digitando();

  @override
  State<_Digitando> createState() => _DigitandoState();
}

class _DigitandoState extends State<_Digitando>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const _Avatar(),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) => Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.green.withValues(
                          alpha: 0.35 +
                              0.65 *
                                  ((((_c.value * 3) - i) % 3) < 1 ? 1.0 : 0.0),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
