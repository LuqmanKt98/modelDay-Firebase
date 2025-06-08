import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class Input extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final Widget? prefix;
  final Widget? suffix;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool enabled;
  final Widget? prefixIcon;
  final String? hintText;

  const Input({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.textInputAction,
    this.focusNode,
    this.onTap,
    this.autofocus = false,
    this.enabled = true,
    this.prefixIcon,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            child: Text(
              label!,
              style: AppTheme.labelLarge,
            ),
          ),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          maxLines: maxLines,
          textInputAction: textInputAction,
          focusNode: focusNode,
          onTap: onTap,
          autofocus: autofocus,
          enabled: enabled,
          decoration: AppTheme.textFieldDecoration.copyWith(
            prefixIcon: prefixIcon,
            hintText: hintText ?? placeholder,
            hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
          ),
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }
}
