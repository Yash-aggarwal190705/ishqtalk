import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/foundation/app_icons.dart';
import 'package:ishqtalk/foundation/app_theme.dart';
import 'package:ishqtalk/shared/age_chip.dart';
import 'package:ishqtalk/shared/avail_label.dart';
import 'package:ishqtalk/shared/badge.dart';
import 'package:ishqtalk/shared/bottom_nav.dart';
import 'package:ishqtalk/shared/call_button.dart';
import 'package:ishqtalk/shared/coin.dart';
import 'package:ishqtalk/shared/frog_avatar.dart';
import 'package:ishqtalk/shared/header.dart';
import 'package:ishqtalk/shared/logo.dart';
import 'package:ishqtalk/shared/lv_chip.dart';
import 'package:ishqtalk/shared/offline_banner.dart';
import 'package:ishqtalk/shared/portrait.dart';
import 'package:ishqtalk/shared/spinner.dart';
import 'package:ishqtalk/shared/token_pill.dart';
import 'package:ishqtalk/shared/topic_chip.dart';

import 'support/port_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPoppins);
  testWidgets('foundation vectors and light/dark navigation at 390 x 844', (
    tester,
  ) async {
    usePortViewport(tester);
    await tester.pumpWidget(
      PortFixture(
        child: ColoredBox(
          color: AppColors.screen,
          child: Column(
            children: <Widget>[
              Header(
                title: 'Foundation',
                onBack: () {},
                right: const Coin(size: 24),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  children: [
                    for (final name in appIconNames)
                      AppIcon(name: name, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Portrait(seed: 2, width: 80, height: 100),
                  FrogAvatar(),
                  Logo(size: 80),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TokenPill(variant: TokenPillVariant.soft),
                  TokenPill(variant: TokenPillVariant.dark),
                  CallButton(),
                  CallButton(onList: true),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AgeChip(age: 22, country: 'India'),
                  AgeChip(age: 23, country: 'Pakistan'),
                  LvChip(level: 3),
                  LvChip(level: 0, gray: true),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TopicChip(label: 'Music', selected: true, onTap: () {}),
                  TopicChip(label: 'Talk', selected: false, onTap: () {}),
                  const Badge(number: 12),
                  const Spinner(),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AvailLabel(
                    availability: Availability.online,
                    textStyle: TextStyle(fontSize: 11),
                  ),
                  AvailLabel(
                    availability: Availability.away,
                    textStyle: TextStyle(fontSize: 11),
                  ),
                  AvailLabel(
                    availability: Availability.unavailable,
                    textStyle: TextStyle(fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OfflineBanner(onRetry: () {}),
              const Spacer(),
              SizedBox(
                height: 72,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppGradients.bgBrand,
                        ),
                      ),
                    ),
                    BottomNav(
                      active: 'live',
                      onTab: (_) {},
                      dark: true,
                      badge: 3,
                      dot: true,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 72,
                child: Stack(
                  children: [
                    BottomNav(
                      active: 'messages',
                      onTab: (_) {},
                      badge: 12,
                      dot: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(goldenSurface),
      matchesGoldenFile('goldens/foundation.png'),
    );
  });
}
