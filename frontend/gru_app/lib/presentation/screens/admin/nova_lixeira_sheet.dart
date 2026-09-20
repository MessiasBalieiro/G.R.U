import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/session_service.dart';
import '../../widgets/gru_button.dart';
import '../../widgets/gru_text_field.dart';

/// Formulário (bottom sheet) para cadastrar uma nova lixeira inteligente.
class NovaLixeiraSheet extends StatefulWidget {
  const NovaLixeiraSheet({super.key});

  @override
  State<NovaLixeiraSheet> createState() => _NovaLixeiraSheetState();
}

class _NovaLixeiraSheetState extends State<NovaLixeiraSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _endereco = TextEditingController();
  final _coord = TextEditingController();
  final _obs = TextEditingController();

  @override
  void dispose() {
    _nome.dispose();
    _endereco.dispose();
    _coord.dispose();
    _obs.dispose();
    super.dispose();
  }

  /// Aceita "-23.5505, -46.6333" (vírgula, ponto e vírgula ou espaço).
  static (double, double)? _parseCoord(String s) {
    final p =
        s.split(RegExp(r'[;,\s]+')).where((e) => e.isNotEmpty).toList();
    if (p.length != 2) return null;
    final lat = double.tryParse(p[0]);
    final lng = double.tryParse(p[1]);
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
    return (lat, lng);
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    final usuario = SessionService.instance.usuario!;
    final instId = usuario.instituicaoPrincipalId;
    final coord = _parseCoord(_coord.text)!;
    if (instId == null) return;

    MockDataService.instance.adicionarLixeira(
      nome: _nome.text,
      endereco: _endereco.text,
      latitude: coord.$1,
      longitude: coord.$2,
      instituicaoId: instId,
      observacoes: _obs.text.trim().isEmpty ? null : _obs.text.trim(),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Theme(
      data: tema.copyWith(
        inputDecorationTheme: tema.inputDecorationTheme.copyWith(
          fillColor: AppColors.background,
          errorStyle: const TextStyle(
            color: AppColors.danger,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dark.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Cadastrar lixeira inteligente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 18),
                GruTextField(
                  label: 'Nome da lixeira',
                  labelColor: AppColors.dark,
                  controller: _nome,
                  hint: 'Ex.: Lixeira Praça Central',
                  validator: (v) => Validators.obrigatorio(v, 'Nome'),
                ),
                const SizedBox(height: 14),
                GruTextField(
                  label: 'Endereço',
                  labelColor: AppColors.dark,
                  controller: _endereco,
                  hint: 'Rua, número',
                  validator: (v) => Validators.obrigatorio(v, 'Endereço'),
                ),
                const SizedBox(height: 14),
                GruTextField(
                  label: 'Coordenadas (latitude, longitude)',
                  labelColor: AppColors.dark,
                  controller: _coord,
                  hint: '-23.5505, -46.6333',
                  keyboardType: TextInputType.text,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Coordenadas obrigatórias';
                    }
                    return _parseCoord(v) == null
                        ? 'Use o formato: -23.5505, -46.6333'
                        : null;
                  },
                ),
                const SizedBox(height: 14),
                GruTextField(
                  label: 'Outras informações (opcional)',
                  labelColor: AppColors.dark,
                  controller: _obs,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 22),
                Center(
                  child: GruButton(
                    label: 'Cadastrar',
                    width: double.infinity,
                    onPressed: _salvar,
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
