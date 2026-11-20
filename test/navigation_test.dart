import 'package:flutter_test/flutter_test.dart';
import 'package:ishqtalk/navigation/nav.dart';
import 'package:ishqtalk/navigation/screens.dart';
import 'package:ishqtalk/state/app_context.dart';
import 'package:ishqtalk/state/models.dart';

void main() {
  test('push/back/goto/tab preserve React stack semantics', () {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'live');
    nav.push('profile');
    nav.push('chat');
    nav.goto('settings');
    expect(nav.stack, ['live', 'profile']);
    nav.back();
    expect(nav.screen, 'profile');
    nav.back();
    expect(nav.screen, 'live');
    nav.back();
    expect(nav.screen, 'live');
    nav.push('tokens');
    nav.tab('me');
    expect(nav.stack, isEmpty);
    expect(nav.screen, 'me');
    nav.dispose();
    app.dispose();
  });

  test('user/chat actions and overlays preserve independent context', () {
    final app = AppContextState();
    final nav = NavigationState(app: app, screen: 'explore');
    expect(nav.user, users.first);
    nav.openUser(users[2]);
    expect(nav.user, users[2]);
    expect(nav.screen, 'profile');
    nav.messageUser(users[4]);
    expect(app.convos[4]?.user, users[4]);
    expect(nav.chatId, 4);
    expect(nav.user, users[2]);
    nav.call(users[4]);
    nav.pay('₹119.99');
    nav.signIn();
    expect(nav.screen, 'chat');
    expect(nav.signed, isTrue);
    nav.openChat(-1);
    expect(nav.screen, 'explore');
    expect(nav.stack, isEmpty);
    nav.jump('welcome-offer');
    expect(nav.callUser, isNull);
    expect(nav.paymentPrice, isNull);
    expect(nav.instant, isTrue);
    nav.goto('notif-prompt');
    expect(nav.instant, isFalse);
    nav.dispose();
    app.dispose();
  });

  test('registry has every exact React ID and onboarding flag binding', () {
    expect(screens.map((s) => s.id).toList(), [
      'splash',
      'login',
      'login-expanded',
      'login-google',
      'login-email',
      'login-otp',
      'welcome-offer',
      'notif-prompt',
      'payment-sheet',
      'live',
      'explore',
      'messages',
      'me',
      'live-searching',
      'live-free',
      'live-gift',
      'sky-lantern',
      'profile',
      'call',
      'notifications',
      'visitors-loading',
      'visitors-list',
      'tokens',
      'bonus',
      'package-props',
      'package-gift',
      'expired-items',
      'token-history',
      'level',
      'history-list',
      'history-empty',
      'welcome',
      'setup',
      'chat',
      'edit-profile',
      'settings',
    ]);
    expect(screenById.length, screens.length);
    expect(screenById['notif-prompt']?.props, {'forceNotif': true});
    expect(screenById['payment-sheet']?.props, {'forcePay': true});
    expect(screenById['chat']?.props, {'id': 10});
    expect(screenGroups, [
      'ONBOARDING',
      'MAIN TABS',
      'LIVE',
      'DISCOVER',
      'MESSAGES',
      'COMMERCE',
      'HISTORY',
      'OTHER',
    ]);
  });

  test('messageUser never overwrites an existing conversation', () {
    final app = AppContextState();
    final nav = NavigationState(app: app);
    final seeded = app.convos[10]!;
    nav.messageUser(seeded.user);
    expect(app.convos[10], same(seeded));
    expect(app.unread, 3);
    app.markRead(10);
    expect(app.unread, 2);
    nav.dispose();
    app.dispose();
  });
}
