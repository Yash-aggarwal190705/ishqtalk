import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../state/models.dart';
import 'domain.dart';

// ---------------------------------------------------------------------------
// Repositories. Swap the seed implementations for API-backed ones without
// touching UI.
// ---------------------------------------------------------------------------

class TokenRepository {
  const TokenRepository();

  static const List<TokenPack> packs = <TokenPack>[
    TokenPack(tokens: 160, price: '₹163'),
    TokenPack(tokens: 240, price: '₹240'),
    TokenPack(tokens: 530, offPercent: 10, price: '₹480'),
    TokenPack(tokens: 880, offPercent: 15, price: '₹801'),
    TokenPack(tokens: 1800, offPercent: 20, price: '₹1602'),
    TokenPack(tokens: 4600, offPercent: 25, price: '₹4005'),
    TokenPack(tokens: 10000, offPercent: 30, price: '₹8400'),
  ];
}

/// Tickets the user holds. Coins come from NavigationState.coins.
/// shortcut: seeded local counts; upgrade to an API-backed store when a
/// backend exists.
class BonusRepository extends ChangeNotifier {
  BonusRepository();

  int chatTickets = 2;
  int matchTickets = 3;
  bool _signedInToday = false;

  bool get signedInToday => _signedInToday;
  int get todayIndex => _signedInToday ? 1 : 0;
  int get ticketTotal => chatTickets + matchTickets;

  /// Seconds until local midnight (countdown target for "Sign in rewards").
  int secondsToMidnight({DateTime? now}) {
    final DateTime t = now ?? DateTime.now();
    final DateTime midnight = DateTime(t.year, t.month, t.day + 1);
    return midnight.difference(t).inSeconds.clamp(0, 86399);
  }

  /// Countdown targets: sign-in rewards and daily bonus (seeded, ~8:48).
  int signInCountdownSeconds({DateTime? now}) {
    // shortcut: fixed seed; replaced by a server-provided reset time later.
    return secondsToMidnight(now: now);
  }

  int dailyCountdownSeconds({DateTime? now}) {
    // shortcut: fixed seed; replaced by a server-provided reset time later.
    return secondsToMidnight(now: now);
  }

  void signIn() {
    if (_signedInToday) return;
    _signedInToday = true;
    matchTickets += 1;
    notifyListeners();
  }

  static const List<RewardTask> tasks = <RewardTask>[
    RewardTask(
      title: 'Profile Verification',
      reward: RewardKind.coin,
      amount: 5,
      progress: '0/1',
    ),
    RewardTask(
      title: 'Have (0/10) friends',
      reward: RewardKind.coin,
      amount: 5,
      progress: '0/1',
      action: TaskAction.exploreTab,
    ),
    RewardTask(
      title: 'Get (0/1) month VIP',
      reward: RewardKind.coin,
      amount: 50,
      progress: '0/1',
      action: TaskAction.openPackage,
    ),
    RewardTask(
      title: 'Give (0/1) gifts',
      reward: RewardKind.coin,
      amount: 10,
      progress: '0/1',
      action: TaskAction.openPackage,
    ),
  ];

  static const List<RewardTask> daily = <RewardTask>[
    RewardTask(
      title: 'Match Video (1/1) min',
      reward: RewardKind.matchTicket,
      amount: 1,
      progress: '1/1',
      done: true,
    ),
    RewardTask(
      title: 'Private Call (0/1) min',
      reward: RewardKind.coin,
      amount: 3,
      progress: '0/1',
    ),
    RewardTask(
      title: 'Message with (1/5) new friends',
      reward: RewardKind.chatTicket,
      amount: 1,
      progress: '0/1',
      action: TaskAction.exploreTab,
    ),
    RewardTask(
      title: 'Give (0/10) Rose',
      reward: RewardKind.coin,
      amount: 50,
      progress: '0/1',
      action: TaskAction.openPackage,
    ),
  ];
}

class PackageRepository {
  const PackageRepository();

  static const List<PropItem> props = <PropItem>[
    PropItem(
      kind: TicketKind.chat,
      qty: 2,
      name: 'Chat Ticket',
      desc: 'Send a message to anyone you have not chatted with yet.',
    ),
    PropItem(
      kind: TicketKind.match,
      qty: 1,
      name: 'Match Ticket',
      desc: 'Skip the wait and start a video match right away.',
    ),
  ];

  static const List<PropItem> gifts = <PropItem>[]; // extra: API shape unknown
}

class HistoryRepository {
  const HistoryRepository();

  static const List<CallRecord> calls = <CallRecord>[
    CallRecord(
      user: AppUser(id: 2, name: 'she has 🥰😘', age: 20, status: 'red', h: 0),
      time: '00:37  00:00:20',
    ),
    CallRecord(
      user: AppUser(
        id: 5,
        name: 'junumoni begum',
        age: 20,
        status: 'red',
        h: 0,
      ),
      time: '00:37  00:00:20',
    ),
    CallRecord(
      user: AppUser(id: 7, name: 'sona', age: 20, status: 'red', h: 0),
      time: '00:35  00:01:20',
    ),
  ];
}

/// Simulated load delay (the prototype fakes ~800ms loading states).
Future<void> fakeLoad({
  Duration delay = const Duration(milliseconds: 800),
}) async {
  if (delay > Duration.zero) await Future<void>.delayed(delay);
}
