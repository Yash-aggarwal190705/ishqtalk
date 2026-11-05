import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/shared/call_sheet.dart';
import 'package:ishqtalk/state/app_context.dart';
import 'package:ishqtalk/state/models.dart';

import 'support/port_fixture.dart';

Widget _fixture(
  AppContextState app,
  NavigationState navigation, {
  PermissionRequester? requester,
  VoidCallback? onClose,
}) {
  return PortFixture(
    app: app,
    navigation: navigation,
    child: CallSheet(
      user: users.first,
      close: onClose ?? () {},
      requester: requester,
    ),
  );
}

void main() {
  testWidgets('low balance routes to Get Tokens and closes', (tester) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'explore')..coins = 2;
    var closed = false;
    await tester.pumpWidget(_fixture(app, nav, onClose: () => closed = true));
    await tester.pump();
    expect(find.text('Video call with Ragini'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(nav.screen, 'tokens');
    expect(closed, isTrue);
    expect(app.sentCount, 0); // no tokens deducted anywhere
    nav.dispose();
    app.dispose();
  });

  testWidgets(
    'permission granted shows the call placeholder without deduction',
    (tester) async {
      final app = AppContextState();
      final nav = NavigationState(app: app, screen: 'explore')..coins = 40;
      var closed = false;
      await tester.pumpWidget(
        _fixture(
          app,
          nav,
          requester: () async => true,
          onClose: () => closed = true,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Call started'), findsOneWidget);
      expect(find.textContaining('[debug] Placeholder'), findsOneWidget);
      expect(closed, isFalse);
      expect(nav.screen, 'explore');
      expect(nav.coins, 40);
      nav.dispose();
      app.dispose();
    },
  );

  testWidgets('permission denied shows the chat-by-message state', (
    tester,
  ) async {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'explore')..coins = 40;
    await tester.pumpWidget(_fixture(app, nav, requester: () async => false));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Camera or microphone blocked'), findsOneWidget);
    expect(find.text('You can still chat by message.'), findsOneWidget);
    expect(find.text('Open app settings'), findsOneWidget);
    nav.dispose();
    app.dispose();
  });
}
