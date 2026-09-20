import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo com rótulo acima e input em pílula branca (Login/Cadastro).
class GruTextField extends StatefulWidget {
  const GruTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.labelColor = Colors.white,
    this.hint,
    this.inputFormatters,
    this.onChanged,
    this.suffix,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final Color labelColor;
  final String? hint;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  /// Widget no fim do campo (ignorado quando [obscure] é verdadeiro).
  final Widget? suffix;
  final TextCapitalization textCapitalization;

  @override
  State<GruTextField> createState() => _GruTextFieldState();
}

class _GruTextFieldState extends State<GruTextField> {
  late bool _oculto = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: widget.labelColor,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _oculto,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: () => setState(() => _oculto = !_oculto),
                    icon: Icon(
                      _oculto
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      size: 20,
                    ),
                  )
                : widget.suffix,
          ),
        ),
      ],
    );
  }
}
