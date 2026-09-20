import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/cep.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/cep_service.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/session_service.dart';
import '../../widgets/gru_button.dart';
import '../../widgets/gru_text_field.dart';

/// Formulário (bottom sheet) para cadastrar uma nova lixeira inteligente.
///
/// A localização é informada pelo **CEP**: ao digitar os 8 dígitos o endereço
/// é preenchido automaticamente (ViaCEP). Se a consulta falhar (sem internet
/// ou CEP genérico), os campos podem ser preenchidos à mão.
class NovaLixeiraSheet extends StatefulWidget {
  const NovaLixeiraSheet({super.key});

  @override
  State<NovaLixeiraSheet> createState() => _NovaLixeiraSheetState();
}

class _NovaLixeiraSheetState extends State<NovaLixeiraSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cepService = CepService();

  final _nome = TextEditingController();
  final _cep = TextEditingController();
  final _logradouro = TextEditingController();
  final _numero = TextEditingController();
  final _complemento = TextEditingController();
  final _bairro = TextEditingController();
  final _cidade = TextEditingController();
  final _uf = TextEditingController();
  final _obs = TextEditingController();

  bool _buscando = false;
  String? _erroCep;
  String? _ultimoCep;

  @override
  void dispose() {
    for (final c in [
      _nome,
      _cep,
      _logradouro,
      _numero,
      _complemento,
      _bairro,
      _cidade,
      _uf,
      _obs,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _aoDigitarCep(String _) {
    // Se o usuário apagou dígitos, limpa o aviso de erro.
    if (Cep.digitos(_cep.text).length < 8 && _erroCep != null) {
      setState(() => _erroCep = null);
    }
    if (Cep.digitos(_cep.text).length == 8) _buscarCep();
  }

  Future<void> _buscarCep() async {
    final d = Cep.digitos(_cep.text);
    if (d.length != 8 || d == _ultimoCep || _buscando) return;
    _ultimoCep = d;
    setState(() {
      _buscando = true;
      _erroCep = null;
    });
    try {
      final e = await _cepService.buscar(d);
      if (!mounted) return;
      setState(() {
        _logradouro.text = e.logradouro;
        _bairro.text = e.bairro;
        _cidade.text = e.cidade;
        _uf.text = e.uf;
        _buscando = false;
      });
    } on CepException catch (e) {
      if (!mounted) return;
      _ultimoCep = null; // permite tentar de novo
      setState(() {
        _buscando = false;
        _erroCep = '${e.mensagem} Preencha o endereço manualmente.';
      });
    }
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    final instId = SessionService.instance.usuario!.instituicaoPrincipalId;
    if (instId == null) return;

    MockDataService.instance.adicionarLixeira(
      nome: _nome.text,
      cep: Cep.formatar(_cep.text),
      logradouro: _logradouro.text,
      numero: _numero.text,
      complemento: _complemento.text,
      bairro: _bairro.text,
      cidade: _cidade.text,
      uf: _uf.text,
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
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
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
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => Validators.obrigatorio(v, 'Nome'),
                ),
                const SizedBox(height: 14),
                GruTextField(
                  label: 'CEP',
                  labelColor: AppColors.dark,
                  controller: _cep,
                  hint: '00000-000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [CepInputFormatter()],
                  onChanged: _aoDigitarCep,
                  suffix: _buscando
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          ),
                        )
                      : IconButton(
                          tooltip: 'Buscar endereço',
                          icon: const Icon(Icons.search_rounded, size: 22),
                          onPressed: _buscarCep,
                        ),
                  validator: (v) => Cep.valido(v ?? '')
                      ? null
                      : 'Informe um CEP com 8 dígitos',
                ),
                if (_erroCep != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, top: 6),
                    child: Text(
                      _erroCep!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                GruTextField(
                  label: 'Rua / Avenida',
                  labelColor: AppColors.dark,
                  controller: _logradouro,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.obrigatorio(v, 'Rua'),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: GruTextField(
                        label: 'Número',
                        labelColor: AppColors.dark,
                        controller: _numero,
                        hint: '100 ou s/n',
                        validator: (v) => Validators.obrigatorio(v, 'Número'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: GruTextField(
                        label: 'Complemento',
                        labelColor: AppColors.dark,
                        controller: _complemento,
                        hint: 'Opcional',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GruTextField(
                  label: 'Bairro',
                  labelColor: AppColors.dark,
                  controller: _bairro,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.obrigatorio(v, 'Bairro'),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: GruTextField(
                        label: 'Cidade',
                        labelColor: AppColors.dark,
                        controller: _cidade,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => Validators.obrigatorio(v, 'Cidade'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GruTextField(
                        label: 'UF',
                        labelColor: AppColors.dark,
                        controller: _uf,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(2),
                        ],
                        validator: (v) => (v ?? '').trim().length == 2
                            ? null
                            : 'UF inválida',
                      ),
                    ),
                  ],
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
