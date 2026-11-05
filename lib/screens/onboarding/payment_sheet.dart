import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../foundation/app_motion.dart';
import '../../foundation/app_theme.dart';

class PaymentSheet extends StatefulWidget {
  const PaymentSheet({
    super.key,
    required this.safeBottom,
    required this.onClose,
    required this.onSuccess,
    this.instant = false,
  });
  final bool instant;
  final double safeBottom;
  final VoidCallback onClose;
  final VoidCallback onSuccess;
  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  int _method = 0;
  bool _paying = false;
  Timer? _successTimer;

  @override
  void dispose() {
    _successTimer?.cancel();
    super.dispose();
  }

  void _pay() {
    if (_paying) return;
    setState(() => _paying = true);
    _successTimer = Timer(const Duration(milliseconds: 1200), widget.onSuccess);
  }

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: FadeIn(
      instant: widget.instant,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Keep the full barrier interactive while busy, so taps never fall through.
        onTap: _paying ? () {} : widget.onClose,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              color: AppColors.ink35,
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {},
                child: SlideUp(
                  instant: widget.instant,
                  child: Semantics(
                    scopesRoute: true,
                    explicitChildNodes: true,
                    namesRoute: true,
                    label: 'Payment',
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        24 + widget.safeBottom,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: const BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.all(
                                Radius.circular(99),
                              ),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Payment method',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                height: 28 / 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (int index = 0; index < 2; index++)
                            _PaymentMethodRow(
                              label: index == 0 ? 'UPI' : 'Card',
                              selected: _method == index,
                              onTap: () => setState(() => _method = index),
                            ),
                          const SizedBox(height: 20),
                          Opacity(
                            opacity: _paying ? .6 : 1,
                            child: AppTap(
                              onTap: _pay,
                              enabled: !_paying,
                              child: Container(
                                height: 52,
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.bgBrand,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  _paying ? 'Processing…' : 'Pay ₹119.99',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Simulated payment. No money is charged.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              height: 16 / 12,
                              color: AppColors.ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _PaymentMethodRow extends StatelessWidget {
  const _PaymentMethodRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    checked: selected,
    inMutuallyExclusiveGroup: true,
    child: AppTap(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.lvGray,
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    ),
  );
}
