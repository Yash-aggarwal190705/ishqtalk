import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import 'login_form_layout.dart';
import 'login_primary_button.dart';
import 'login_text_field.dart';

class OtpStep extends StatefulWidget {
  const OtpStep({
    super.key,
    required this.target,
    required this.check,
    required this.onVerify,
    required this.onBack,
    this.showDemoHint = true,
  });

  final String target;

  /// Returns true when [code] is accepted. Errors surface in the UI.
  final Future<bool> Function(String code) check;
  final VoidCallback onVerify;
  final VoidCallback onBack;

  /// Demo-only hint (phone flow). Hidden for real email OTP.
  final bool showDemoHint;

  @override
  State<OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<OtpStep> {
  // An invisible editing sentinel lets software keyboards report Backspace on
  // an otherwise empty box. It is never part of the code or its semantics.
  static const _empty = '\u200b';
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focus;
  late final TapGestureRecognizer _change;
  final List<String> _digits = List.filled(6, '');
  final List<String?> _pasted = List.filled(6, null);
  Timer? _timer;
  int _seconds = 30;
  int _shake = 0;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      6,
      (_) => TextEditingController.fromValue(
        const TextEditingValue(
          text: _empty,
          selection: TextSelection.collapsed(offset: 1),
        ),
      ),
    );
    _focus = List.generate(6, (_) => FocusNode());
    _change = TapGestureRecognizer()..onTap = () => widget.onBack();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds--);
      if (_seconds == 0) timer.cancel();
    });
  }

  void _write(int i, String digit) {
    _digits[i] = digit;
    final String text = digit.isEmpty ? _empty : digit;
    _controllers[i].value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _changed(int i, String value) {
    final String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final bool wasEmpty = _digits[i].isEmpty;
    final String? pasted = _pasted[i];
    _pasted[i] = null;
    if (pasted != null && pasted.isNotEmpty) {
      final String code = pasted.substring(0, math.min(6, pasted.length));
      setState(() {
        for (int j = 0; j < 6; j++) {
          _write(j, j < code.length ? code[j] : '');
        }
      });
      _focus[math.min(code.length, 5)].requestFocus();
      return;
    }
    final String digit = digits.isEmpty ? '' : digits[digits.length - 1];
    setState(() {
      _error = false;
      _write(i, digit);
    });
    if (digit.isNotEmpty && i < 5) {
      _focus[i + 1].requestFocus();
    } else if (wasEmpty && value.isEmpty && i > 0) {
      _focus[i - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    if (_digits.any((d) => d.isEmpty)) return;
    final bool ok = await widget.check(_digits.join());
    if (!mounted) return;
    if (ok) {
      widget.onVerify();
    } else {
      setState(() {
        _error = true;
        _shake++;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _change.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focus) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LoginFormLayout(
    body: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter the 6-digit code',
          style: TextStyle(
            fontSize: 18,
            height: 28 / 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Sent to ${widget.target} '),
              TextSpan(
                text: 'Change',
                recognizer: _change,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: AppColors.ink2,
          ),
        ),
        const SizedBox(height: 20),
        Shake(
          play: _shake > 0,
          trigger: _shake,
          child: Row(
            key: const ValueKey('otp-row'),
            children: [
              for (int i = 0; i < 6; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Focus(
                    onKeyEvent: (_, event) {
                      if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
                        return KeyEventResult.ignored;
                      }
                      if (event.logicalKey == LogicalKeyboardKey.backspace &&
                          _digits[i].isEmpty &&
                          i > 0) {
                        _focus[i - 1].requestFocus();
                        return KeyEventResult.handled;
                      }
                      if (event.logicalKey == LogicalKeyboardKey.enter ||
                          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
                        _verify();
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: LoginTextField(
                      key: ValueKey('otp-digit-$i'),
                      controller: _controllers[i],
                      focusNode: _focus[i],
                      label: 'Digit ${i + 1}',
                      digit: true,
                      error: _error,
                      autofocus: i == 0,
                      keyboardType: TextInputType.number,
                      autofillHints: i == 0
                          ? const [AutofillHints.oneTimeCode]
                          : null,
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String all = newValue.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          // Full-code autofill replaces the editing value. A
                          // clipboard insertion may instead retain an old digit.
                          if (all.length == 6) {
                            _pasted[i] = all;
                          } else {
                            int prefix = 0;
                            while (prefix < oldValue.text.length &&
                                prefix < newValue.text.length &&
                                oldValue.text[prefix] ==
                                    newValue.text[prefix]) {
                              prefix++;
                            }
                            int suffix = 0;
                            while (suffix < oldValue.text.length - prefix &&
                                suffix < newValue.text.length - prefix &&
                                oldValue.text[oldValue.text.length -
                                        1 -
                                        suffix] ==
                                    newValue.text[newValue.text.length -
                                        1 -
                                        suffix]) {
                              suffix++;
                            }
                            final String inserted = newValue.text.substring(
                              prefix,
                              newValue.text.length - suffix,
                            );
                            _pasted[i] = inserted.length > 1
                                ? inserted.replaceAll(RegExp(r'[^0-9]'), '')
                                : null;
                          }
                          return newValue;
                        }),
                      ],
                      onChanged: (value) => _changed(i, value),
                      onSubmitted: (_) => _verify(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 20),
          child: Semantics(
            liveRegion: true,
            child: Text(
              _error ? 'Incorrect code. Please try again.' : '',
              style: const TextStyle(
                fontSize: 12,
                height: 16 / 12,
                color: AppColors.badge,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (widget.showDemoHint)
          const Text(
            'Demo code: 123456',
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              color: AppColors.ink2,
            ),
          ),
      ],
    ),
    actions: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        LoginPrimaryButton(
          label: 'Verify',
          onTap: _digits.any((d) => d.isEmpty) ? null : _verify,
        ),
        const SizedBox(height: 8),
        AppTap(
          enabled: _seconds == 0,
          onTap: () {
            setState(() => _seconds = 30);
            _startCountdown();
          },
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: Center(
              child: Text(
                _seconds > 0 ? 'Resend code in ${_seconds}s' : 'Resend code',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: _seconds > 0 ? AppColors.ink2 : AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
