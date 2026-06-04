/// Echo — Custom Text Field Widget
///
/// Styled text input used across login, register, and add memory screens.

import 'package:flutter/material.dart';
import '../core/theme.dart';

class EchoTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool autofocus;
  final void Function(String)? onChanged;

  const EchoTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.autofocus = false,
    this.onChanged,
  });

  @override
  State<EchoTextField> createState() => _EchoTextFieldState();
}

class _EchoTextFieldState extends State<EchoTextField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText && !_showPassword,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      style: Theme.of(context).textTheme.bodyLarge,
      cursorColor: EchoColors.primary,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: EchoColors.textMuted, size: 20)
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                  color: EchoColors.textMuted,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _showPassword = !_showPassword),
              )
            : null,
      ),
    );
  }
}
