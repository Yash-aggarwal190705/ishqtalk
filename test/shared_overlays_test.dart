import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/shared/dialog.dart';
import 'package:ishqtalk/shared/empty_state.dart';
import 'package:ishqtalk/shared/sheet.dart';

import 'support/port_fixture.dart';

void main() {
  testWidgets(
    'Sheet caps height at 90% of its own bounds and ignores panel taps',
    (tester) async {
      usePortViewport(tester);
      var closed = 0;
      await tester.pumpWidget(
        PortFixture(
          child: Center(
            child: SizedBox(
              width: 320,
              height: 500,
              child: Stack(
                children: [
                  Sheet(
                    instant: true,
                    close: () => closed++,
                    child: const SizedBox(
                      height: 1000,
                      child: Text('sheet content'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(SingleChildScrollView)).height, 450);
      await tester.tapAt(
        tester.getTopLeft(find.byType(SingleChildScrollView)) +
            const Offset(24, 40),
      );
      expect(closed, 0);
      await tester.tapAt(const Offset(50, 180));
      expect(closed, 1);
    },
  );

  testWidgets(
    'Dialog and EmptyState have functional custom actions without Material effects',
    (tester) async {
      usePortViewport(tester);
      var closed = 0;
      var activated = false;
      await tester.pumpWidget(
        PortFixture(
          child: Stack(
            children: [
              EmptyState(
                title: 'No conversations yet',
                body: "Start one from someone's profile.",
                action: 'Explore people',
                onAction: () => activated = true,
              ),
              AppDialog(
                title: 'Title',
                body: 'Body',
                close: () => closed++,
                instant: true,
                children: const [Text('Action')],
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Body'));
      expect(closed, 0);
      await tester.tapAt(const Offset(10, 10));
      expect(closed, 1);
      await tester.pumpWidget(
        PortFixture(
          child: EmptyState(
            title: 'No conversations yet',
            body: "Start one from someone's profile.",
            action: 'Explore people',
            onAction: () => activated = true,
          ),
        ),
      );
      await tester.tap(find.text('Explore people'));
      expect(activated, isTrue);
    },
  );
}
