import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/app_theme.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    this.hint,
    this.error = false,
    this.digit = false,
    this.autofocus = false,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String? hint;
  final bool error;
  final bool digit;
  final bool autofocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: focusNode,
    builder: (context, _) => Semantics(
      label: label,
      child: Container(
        height: digit ? 56 : 52,
        padding: EdgeInsets.symmetric(horizontal: digit ? 0 : 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(digit ? 12 : 14),
          border: Border.all(
            color: error
                ? AppColors.badge
                : focusNode.hasFocus
                ? AppColors.primary
                : AppColors.divider,
          ),
          boxShadow: digit && focusNode.hasFocus
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .3),
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.done,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            autofillHints: autofillHints,
            autocorrect: false,
            enableSuggestions: false,
            textAlign: digit ? TextAlign.center : TextAlign.start,
            textAlignVertical: TextAlignVertical.center,
            // Reveal the entire 52/56px field, including its focus ring, rather
            // than only the 24/28px caret when a keyboard is already open.
            scrollPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 16,
            ),
            cursorColor: AppColors.ink,
            cursorWidth: 1,
            style: TextStyle(
              fontFamily: 'Poppins',
              letterSpacing: 0,
              fontSize: digit ? 20 : 16,
              height: digit ? 1.4 : 1.5,
              fontWeight: digit ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.ink,
              leadingDistribution: TextLeadingDistribution.even,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.ink.withValues(alpha: .5)),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    ),
  );
}
