enum ItemTab { passes, gifts }

class PassItem {
  const PassItem({
    required this.id,
    required this.kind,
    required this.name,
    required this.qty,
    required this.when,
    required this.desc,
  });

  final int id;
  final String kind; // 'match' | 'chat'
  final String name;
  final int qty;
  final String when;
  final String desc;
}

/// Seed active passes (myItems.tsx ACTIVE).
const List<PassItem> activePasses = <PassItem>[
  PassItem(
    id: 1,
    kind: 'match',
    name: 'Match pass',
    qty: 2,
    when: 'Expires 12 Nov, 6:30 pm',
    desc: 'Skip the wait and start a video match right away.',
  ),
  PassItem(
    id: 2,
    kind: 'chat',
    name: 'Chat pass',
    qty: 1,
    when: 'Expires 15 Nov, 9:00 am',
    desc: 'Start a chat with anyone, even before they reply.',
  ),
];

/// Seed expired passes (myItems.tsx EXPIRED).
const List<PassItem> expiredPasses = <PassItem>[
  PassItem(
    id: 3,
    kind: 'match',
    name: 'Match pass',
    qty: 2,
    when: 'Expired 25 Oct, 5:15 pm',
    desc: '',
  ),
  PassItem(
    id: 4,
    kind: 'match',
    name: 'Match pass',
    qty: 2,
    when: 'Expired 24 Oct, 8:40 pm',
    desc: '',
  ),
  PassItem(
    id: 5,
    kind: 'match',
    name: 'Match pass',
    qty: 1,
    when: 'Expired 22 Oct, 11:05 am',
    desc: '',
  ),
  PassItem(
    id: 6,
    kind: 'chat',
    name: 'Chat pass',
    qty: 1,
    when: 'Expired 20 Oct, 7:30 pm',
    desc: '',
  ),
  PassItem(
    id: 7,
    kind: 'chat',
    name: 'Chat pass',
    qty: 2,
    when: 'Expired 18 Oct, 2:10 pm',
    desc: '',
  ),
  PassItem(
    id: 8,
    kind: 'chat',
    name: 'Chat pass',
    qty: 1,
    when: 'Expired 15 Oct, 9:45 am',
    desc: '',
  ),
];

class ItemsRepository {
  const ItemsRepository();

  List<PassItem> get active => activePasses;
  List<PassItem> get expired => expiredPasses;
}

/// Placeholder repository that yields no items (test-only / future API).
class EmptyItemsRepository extends ItemsRepository {
  const EmptyItemsRepository();

  @override
  List<PassItem> get active => const <PassItem>[];

  @override
  List<PassItem> get expired => const <PassItem>[];
}
