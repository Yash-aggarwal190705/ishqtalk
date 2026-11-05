import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ishqtalk/foundation/app_motion.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/screens/onboarding/notif_dialog.dart';
import 'package:ishqtalk/screens/onboarding/payment_sheet.dart';
import 'package:ishqtalk/screens/onboarding/welcome_offer.dart';
import 'package:ishqtalk/state/app_context.dart';
import 'package:ishqtalk/state/onboarding_state.dart';

import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);

  testWidgets(
    'production prompt is delayed 600ms; both choices persist and remove immediately',
    (tester) async {
      usePortViewport(tester);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final state = OnboardingState(preferences: prefs);
      for (final choice in ['allow', 'deny']) {
        await tester.pumpWidget(
          PortFixture(
            onboarding: state,
            child: WelcomeOffer(key: ValueKey(choice)),
          ),
        );
        await tester.pump(const Duration(milliseconds: 599));
        expect(find.byType(NotifDialog), findsNothing);
        await tester.pump(const Duration(milliseconds: 1));
        expect(find.byType(NotifDialog), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 280));
        await tester.tapAt(const Offset(10, 10));
        await tester.pump();
        expect(find.byType(NotifDialog), findsOneWidget);
        await tester.tap(
          find.text(choice == 'allow' ? 'Allow' : "Don't allow"),
        );
        await tester.pump();
        expect(find.byType(NotifDialog), findsNothing);
        expect(state.notificationChoice, choice);
        expect(prefs.getString(OnboardingState.notificationsKey), choice);
        await tester.pumpWidget(const SizedBox.shrink());
      }
      state.dispose();
    },
  );

  testWidgets(
    'tooltip retains production 1000/4000ms timers with prompt injection only',
    (tester) async {
      usePortViewport(tester);
      await tester.pumpWidget(
        const PortFixture(
          child: WelcomeOffer(
            instant: true,
            testOverrides: WelcomeOfferTestOverrides(
              suppressNotificationPrompt: true,
            ),
          ),
        ),
      );
      AnimatedOpacity tip() =>
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(tip().opacity, 0);
      await tester.pump(const Duration(milliseconds: 999));
      expect(tip().opacity, 0);
      await tester.pump(const Duration(milliseconds: 1));
      expect(tip().opacity, 1);
      expect(tip().duration, const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(NotifDialog), findsNothing);
      await tester.pump(const Duration(milliseconds: 2700));
      expect(tip().opacity, 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'payment radio, scrim lock, exact completion and tab stack clearing',
    (tester) async {
      usePortViewport(tester);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final state = OnboardingState(preferences: prefs);
      final app = AppContextState();
      final nav = NavigationState(app: app)..push('payment-sheet');
      await tester.pumpWidget(
        PortFixture(
          app: app,
          onboarding: state,
          navigation: nav,
          child: const WelcomeOffer(
            forcePay: true,
            instant: true,
            testOverrides: WelcomeOfferTestOverrides(disableTimers: true),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('UPI')).flagsCollection.isChecked,
        CheckedState.isTrue,
      );
      await tester.tap(find.text('Card'));
      await tester.pump();
      expect(
        tester.getSemantics(find.text('Card')).flagsCollection.isChecked,
        CheckedState.isTrue,
      );
      await tester.tap(find.text('Pay ₹119.99'));
      await tester.pump();
      expect(find.text('Processing…'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pump(const Duration(milliseconds: 1199));
      expect(state.onboarded, isFalse);
      expect(find.byType(PaymentSheet), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1));
      expect(state.onboarded, isTrue);
      expect(prefs.getString(OnboardingState.onboardedKey), '1');
      expect(nav.screen, 'live');
      expect(nav.stack, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
      nav.dispose();
      app.dispose();
    },
  );

  testWidgets('idle payment scrim dismisses but panel does not', (
    tester,
  ) async {
    usePortViewport(tester);
    await tester.pumpWidget(
      const PortFixture(
        child: WelcomeOffer(
          forcePay: true,
          instant: true,
          testOverrides: WelcomeOfferTestOverrides(disableTimers: true),
        ),
      ),
    );
    await tester.tap(find.text('Payment method'));
    await tester.pump();
    expect(find.byType(PaymentSheet), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    expect(find.byType(PaymentSheet), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Continue scales only while pressed and opens payment on release',
    (tester) async {
      usePortViewport(tester);
      await tester.pumpWidget(
        const PortFixture(
          child: WelcomeOffer(
            instant: true,
            testOverrides: WelcomeOfferTestOverrides(disableTimers: true),
          ),
        ),
      );
      final press = find.byType(PressScale);
      final gesture = await tester.startGesture(tester.getCenter(press));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 150));
      final scale = tester.widget<AnimatedScale>(
        find.descendant(of: press, matching: find.byType(AnimatedScale)),
      );
      expect(scale.scale, .98);
      await gesture.up();
      await tester.pump();
      expect(find.byType(PaymentSheet), findsOneWidget);
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Skip persists onboarding and clears navigation history', (
    tester,
  ) async {
    usePortViewport(tester);
    final app = AppContextState();
    final nav = NavigationState(app: app)..push('welcome-offer');
    final state = OnboardingState();
    await tester.pumpWidget(
      PortFixture(
        onboarding: state,
        navigation: nav,
        child: const WelcomeOffer(
          testOverrides: WelcomeOfferTestOverrides(disableTimers: true),
        ),
      ),
    );
    await tester.tap(find.text('Skip'));
    expect(state.onboarded, isTrue);
    expect(nav.screen, 'live');
    expect(nav.stack, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
    nav.dispose();
    app.dispose();
  });
}
