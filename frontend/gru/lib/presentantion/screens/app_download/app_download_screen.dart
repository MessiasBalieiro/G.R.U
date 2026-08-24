import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/gru_mascot.dart';
import '../../widgets/animated_svg_wave.dart';

class AppDownloadScreen extends StatelessWidget {
  const AppDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -10,
              left: 0,
              child: AnimatedSvgWave(
                assetPath: AppWaves.cornerGreenBottom,
                width: 300,
                height: 110,
                fit: BoxFit.fill,
                amplitude: 8,
                period: const Duration(seconds: 5),
              ),
            ),
            Positioned(
              bottom: -10,
              right: 0,
              child: AnimatedSvgWave(
                assetPath: AppWaves.cornerDark,
                width: 300,
                height: 100,
                fit: BoxFit.fill,
                amplitude: 8,
                period: const Duration(seconds: 6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  LayoutBuilder(builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 640;
                    final textoEBotao = Column(
                      crossAxisAlignment: isMobile
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Instale nosso aplicativo para o seu celular',
                          textAlign:
                              isMobile ? TextAlign.center : TextAlign.start,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: isMobile ? double.infinity : 320,
                          height: 130,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.dark),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Conteúdo do app',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Download disponível em breve.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('DOWNLOAD'),
                        ),
                      ],
                    );

                    final mascoteGrande = Padding(
                      padding: const EdgeInsets.all(20),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          const GruMascot(size: 130),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.attach_money_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          textoEBotao,
                          const SizedBox(height: 20),
                          mascoteGrande,
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(child: textoEBotao),
                        const SizedBox(width: 36),
                        mascoteGrande,
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
