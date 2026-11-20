import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/auth_state.dart';
import '../../foundation/app_icons.dart';
import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';
import 'country_code_picker.dart';
import 'login_form_layout.dart';
import 'login_primary_button.dart';
import 'login_text_field.dart';
import 'onboarding_modal.dart';
import 'otp_step.dart';

enum ContactKind { email, phone }

class ContactSheet extends StatefulWidget {
  const ContactSheet({
    super.key,
    required this.kind,
    required this.done,
    required this.close,
    this.startAtOtp = false,
    this.instant = false,
  });
  final ContactKind kind;
  final VoidCallback done;
  final VoidCallback close;
  final bool startAtOtp;
  final bool instant;

  @override
  State<ContactSheet> createState() => _ContactSheetState();
}

class _ContactSheetState extends State<ContactSheet> {
  late final TextEditingController _email;
  final TextEditingController _phone = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  late bool _otp;
  bool _touched = false;
  bool _countries = false;
  String _country = '+91';
  String _sendError = '';

  bool get _isEmail => widget.kind == ContactKind.email;
  bool get _valid => _isEmail
      ? RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(_email.text.trim())
      : RegExp(r'^\d{7,12}$').hasMatch(_phone.text);
  String get _error => !_touched || _valid
      ? ''
      : _isEmail
      ? 'Enter a valid email address.'
      : 'Enter a valid phone number.';
  String get _target =>
      _isEmail ? _email.text.trim() : '$_country ${_phone.text}';

  @override
  void initState() {
    super.initState();
    _otp = widget.startAtOtp;
    _email = TextEditingController(text: _otp ? 'alex.morgan@example.com' : '');
    _inputFocus.addListener(_focusChanged);
  }

  void _focusChanged() {
    if (!_inputFocus.hasFocus) setState(() => _touched = true);
  }

  Future<void> _send() async {
    setState(() {
      _touched = true;
      _sendError = '';
    });
    if (!_valid) return;
    if (_isEmail) {
      // Real Supabase email OTP: send the code before showing the OTP step.
      final bool ok = await context.read<AuthState>().sendEmailOtp(
        _email.text.trim(),
      );
      if (!mounted) return;
      if (!ok) {
        setState(() => _sendError = 'Could not send code. Please try again.');
        return;
      }
    }
    setState(() => _otp = true);
  }

  void _closeCountries([String? value]) {
    setState(() {
      _countries = false;
      if (value != null) _country = value;
    });
    _inputFocus.requestFocus();
  }

  @override
  void dispose() {
    _inputFocus.removeListener(_focusChanged);
    _inputFocus.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Widget _form() => LoginFormLayout(
    body: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isEmail ? 'Continue with Email' : 'Continue with Phone',
          style: const TextStyle(
            fontSize: 18,
            height: 28 / 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'We will send you a verification code.',
          style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.ink2),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (!_isEmail) ...[
              AppTap(
                label: 'Country code',
                onTap: () {
                  _inputFocus.unfocus();
                  setState(() => _countries = true);
                },
                child: Container(
                  width: 96,
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _country,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const RotatedBox(
                        quarterTurns: 1,
                        child: AppIcon(
                          name: 'chev',
                          size: 12,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: LoginTextField(
                key: ValueKey(_isEmail ? 'email-input' : 'phone-input'),
                controller: _isEmail ? _email : _phone,
                focusNode: _inputFocus,
                label: _isEmail ? 'Email address' : 'Phone number',
                hint: _isEmail ? 'Email address' : 'Phone number',
                autofocus: true,
                error: _error.isNotEmpty,
                keyboardType: _isEmail
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                inputFormatters: _isEmail
                    ? null
                    : [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                      ],
                onChanged: (_) => setState(() => _sendError = ''),
                onSubmitted: (_) => _send(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 20),
          child: Semantics(
            liveRegion: true,
            child: Text(
              _sendError.isNotEmpty ? _sendError : _error,
              style: const TextStyle(
                fontSize: 12,
                height: 16 / 12,
                color: AppColors.badge,
              ),
            ),
          ),
        ),
      ],
    ),
    actions: Padding(
      padding: const EdgeInsets.only(top: 12),
      child: LoginPrimaryButton(
        label: 'Send code',
        onTap: _valid ? _send : null,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      OnboardingModal(
        sheet: true,
        form: true,
        instant: widget.instant,
        close: widget.close,
        child: IgnorePointer(
          ignoring: _countries,
          child: ExcludeFocus(
            excluding: _countries,
            child: _otp
                ? OtpStep(
                    target: _target,
                    check: _isEmail
                        ? (code) => context.read<AuthState>().verifyEmailOtp(
                            _email.text.trim(),
                            code,
                          )
                        : (code) async => code == '123456',
                    showDemoHint: !_isEmail,
                    onVerify: widget.done,
                    onBack: () => setState(() => _otp = false),
                  )
                : _form(),
          ),
        ),
      ),
      if (_countries)
        CountryCodePicker(
          selected: _country,
          onSelect: _closeCountries,
          close: _closeCountries,
          instant: widget.instant,
        ),
    ],
  );
}
