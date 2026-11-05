class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.age,
    required this.status,
    required this.h,
    this.country,
    this.topic,
    this.avail = 'online',
    this.photoUrl,
    this.verified = false,
  });
  final int id;
  final String name;
  final int age;
  final String? country;
  final String status;
  final double h;
  final String? topic;
  final String avail;
  final String? photoUrl;
  final bool verified;

  AppUser withIdentity(int id, String name, String avail) => AppUser(
    id: id,
    name: name,
    age: age,
    country: country,
    status: status,
    h: h,
    topic: topic,
    avail: avail,
    photoUrl: photoUrl,
    verified: verified,
  );
}

const users = <AppUser>[
  AppUser(
    id: 0,
    name: 'Ragini',
    age: 22,
    country: 'India',
    status: 'red',
    h: 223,
    topic: 'Music',
  ),
  AppUser(
    id: 1,
    name: 'MAHIAM',
    age: 23,
    country: 'Pakistan',
    status: 'red',
    h: 227,
    topic: 'Talk',
  ),
  AppUser(
    id: 2,
    name: 'Suhani',
    age: 19,
    country: 'India',
    status: 'red',
    h: 219,
    topic: 'Games',
  ),
  AppUser(
    id: 3,
    name: 'Hot Mahira 💋',
    age: 18,
    country: 'India',
    status: 'cyan',
    h: 223,
    topic: 'Creative',
  ),
  AppUser(
    id: 4,
    name: 'maya Telugu',
    age: 20,
    status: 'red',
    h: 200,
    topic: 'Talk',
    avail: 'away',
  ),
  AppUser(
    id: 5,
    name: 'fruittyy',
    age: 20,
    country: 'India',
    status: 'cyan',
    h: 228,
    topic: 'Music',
  ),
  AppUser(
    id: 6,
    name: 'RED BERRY',
    age: 18,
    country: 'Pakistan',
    status: 'red',
    h: 214,
    topic: 'Games',
  ),
  AppUser(
    id: 7,
    name: 'Queen 👑',
    age: 24,
    country: 'Pakistan',
    status: 'red',
    h: 190,
    topic: 'Creative',
    avail: 'away',
  ),
  AppUser(
    id: 8,
    name: 'Riya 😊',
    age: 18,
    country: 'India',
    status: 'red',
    h: 226,
    topic: 'Music',
  ),
  AppUser(
    id: 9,
    name: 'mannat kaur',
    age: 24,
    status: 'cyan',
    h: 222,
    topic: 'Talk',
    avail: 'unavailable',
  ),
];

enum MessageState { sent, pending, failed }

class Message {
  const Message({
    required this.id,
    required this.from,
    required this.text,
    required this.state,
    required this.time,
  });
  final int id;
  final String from;
  final String text;
  final MessageState state;
  final String time;
  Message withState(MessageState value) =>
      Message(id: id, from: from, text: text, state: value, time: time);
}

class Conversation {
  const Conversation({
    required this.user,
    this.messages = const [],
    this.unread = 0,
    this.timestamp = 0,
    this.date = '',
  });
  final AppUser user;
  final List<Message> messages;
  final int unread;
  final int timestamp;
  final String date;
  Conversation copyWith({
    List<Message>? messages,
    int? unread,
    int? timestamp,
    String? date,
  }) => Conversation(
    user: user,
    messages: messages ?? this.messages,
    unread: unread ?? this.unread,
    timestamp: timestamp ?? this.timestamp,
    date: date ?? this.date,
  );
}

Map<int, Conversation> seededConversations() {
  final result = <int, Conversation>{};
  for (final (id, base, name, avail, text, unread, timestamp) in [
    (12, 4, 'Pinku', 'away', 'chat', 0, 1),
    (10, 2, 'Camila 💕😍', 'online', 'Hola amor, cómo estás ?', 1, 2),
    (13, 5, 'Kiara ❤️', 'online', 'Hola me da gusto saludarte ❤️', 1, 3),
    (15, 7, '😍 Hot Queen 😍', 'unavailable', 'open call me', 1, 4),
  ]) {
    result[id] = Conversation(
      user: users[base].withIdentity(id, name, avail),
      unread: unread,
      timestamp: timestamp,
      date: '10-24',
      messages: [
        Message(
          id: timestamp,
          from: 'them',
          text: text,
          state: MessageState.sent,
          time: '10:24',
        ),
      ],
    );
  }
  return result;
}
