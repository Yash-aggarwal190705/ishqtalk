import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

// The standard widget-test binding disables blur on BoxShadows. Golden images
// must exercise the production shadow renderer rather than flat offset masks.
class _PortTestBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get disableShadows => false;
}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  _PortTestBinding();
  WidgetController.hitTestWarningShouldBeFatal = true;
  await testMain();
}
