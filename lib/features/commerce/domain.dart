import '../../state/models.dart';

enum TicketKind { chat, match }

class TokenPack {
  const TokenPack({required this.tokens, this.offPercent, required this.price});
  final int tokens;
  final int? offPercent;
  final String price;
}

enum RewardKind { coin, chatTicket, matchTicket }

enum TaskAction { none, exploreTab, openPackage }

class RewardTask {
  const RewardTask({
    required this.title,
    required this.reward,
    required this.amount,
    required this.progress,
    this.done = false,
    this.action = TaskAction.none,
  });
  final String title;
  final RewardKind reward;
  final int amount;
  final String progress;
  final bool done;
  final TaskAction action;
}

class PropItem {
  const PropItem({
    required this.kind,
    required this.qty,
    required this.name,
    required this.desc,
  });
  final TicketKind kind;
  final int qty;
  final String name;
  final String desc;
}

class CallRecord {
  const CallRecord({required this.user, required this.time});
  final AppUser user;
  final String time; // "00:37  00:00:20"
}
