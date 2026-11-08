// ---------------------------------------------------------------------------
// Token history domain
// ---------------------------------------------------------------------------

enum TxKind { checkin, purchase, pass }

class Tx {
  const Tx({
    required this.id,
    required this.kind,
    required this.title,
    required this.when,
    required this.amount,
    required this.daysAgo,
  });

  final int id;
  final TxKind kind;
  final String title;
  final String when;
  final int amount;
  final int daysAgo;

  bool get earned => amount > 0;
}

/// Seed transactions (tokenHistory.tsx TX).
const List<Tx> seedTransactions = <Tx>[
  Tx(
    id: 1,
    kind: TxKind.checkin,
    title: 'Daily check-in bonus',
    when: 'Today, 10:46 am',
    amount: 5,
    daysAgo: 0,
  ),
  Tx(
    id: 2,
    kind: TxKind.purchase,
    title: 'Tokens added',
    when: '28 Oct, 3:19 pm',
    amount: 100,
    daysAgo: 1,
  ),
  Tx(
    id: 3,
    kind: TxKind.pass,
    title: 'Match pass',
    when: '26 Oct, 9:02 pm',
    amount: -50,
    daysAgo: 3,
  ),
  Tx(
    id: 4,
    kind: TxKind.checkin,
    title: 'Welcome bonus',
    when: '24 Oct, 5:15 pm',
    amount: 5,
    daysAgo: 5,
  ),
];

enum TxType { all, earned, spent }

class TxFilter {
  const TxFilter({required this.type, required this.range});

  final TxType type;
  final int range; // index into ranges

  static const TxFilter defaultFilter = TxFilter(type: TxType.all, range: 2);

  bool get isActive =>
      type != TxType.all || range != TxFilter.defaultFilter.range;
}

class DateRange {
  const DateRange(this.label, this.maxDays);

  final String label;
  final int maxDays; // -1 = all time
}

const List<DateRange> ranges = <DateRange>[
  DateRange('Today', 0),
  DateRange('Last 7 days', 7),
  DateRange('Last 30 days', 30),
  DateRange('All time', -1),
];

bool txMatches(Tx t, TxFilter f) {
  final bool typeOk =
      f.type == TxType.all || (f.type == TxType.earned) == t.earned;
  final int maxDays = ranges[f.range].maxDays;
  final bool rangeOk = maxDays < 0 || t.daysAgo <= maxDays;
  return typeOk && rangeOk;
}

/// en-IN grouping: 2,000 / 99,900 / 1,00,000.
String fmtIN(int n) {
  final String s = n.toString();
  if (s.length <= 3) return s;
  final String last3 = s.substring(s.length - 3);
  String rest = s.substring(0, s.length - 3);
  final List<String> parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

// ---------------------------------------------------------------------------
// Level domain (level.tsx)
// ---------------------------------------------------------------------------

const List<int> thresholds = <int>[
  0,
  100,
  1000,
  3000,
  10000,
  30000,
  100000,
  300000,
  1000000,
  3000000,
  10000000,
];

const List<String> thresholdLabels = <String>[
  '0',
  '100',
  '1,000',
  '3,000',
  '10,000',
  '30,000',
  '1 lakh',
  '3 lakh',
  '10 lakh',
  '30 lakh',
  '1 crore',
];

const List<int> bonusPerLevel = <int>[
  5,
  8,
  12,
  18,
  25,
  35,
  50,
  70,
  100,
  150,
  200,
];

int levelOf(int total) {
  int lv = 0;
  for (int i = 0; i < thresholds.length; i++) {
    if (total >= thresholds[i]) lv = i;
  }
  return lv;
}

class LevelInfo {
  const LevelInfo({
    required this.current,
    required this.next,
    required this.isMax,
    required this.pct,
    required this.need,
  });

  final int current;
  final int next;
  final bool isMax;
  final int pct;
  final int need;
}

LevelInfo levelInfo(int tokensAdded) {
  final int current = levelOf(tokensAdded);
  final bool max = current >= 10;
  final int next = max ? 10 : current + 1;
  final int pct = max
      ? 100
      : ((tokensAdded - thresholds[current]) /
                (thresholds[next] - thresholds[current]) *
                100)
            .round();
  final int need = max ? 0 : thresholds[next] - tokensAdded;
  return LevelInfo(
    current: current,
    next: next,
    isMax: max,
    pct: pct,
    need: need,
  );
}

enum Tier { gray, mint, violet, pink, sunset }

Tier tierOf(int lv) {
  if (lv == 0) return Tier.gray;
  if (lv <= 2) return Tier.mint;
  if (lv <= 5) return Tier.violet;
  if (lv <= 8) return Tier.pink;
  return Tier.sunset;
}

/// Placeholder repository (replace with an API-backed store later).
class WalletRepository {
  const WalletRepository();

  int get balance => 105;
  int get tokensAdded => 0;
  List<Tx> get transactions => seedTransactions;
}
