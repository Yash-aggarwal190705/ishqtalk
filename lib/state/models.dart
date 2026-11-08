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
    this.photo,
  });
  final int id;
  final String from;
  final String text;
  final MessageState state;
  final String time;
  final int? photo; // photo message id (Conversation spec)
  Message withState(MessageState value) => Message(
    id: id,
    from: from,
    text: text,
    state: value,
    time: time,
    photo: photo,
  );
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

/// v2 SEED (inbox.tsx): sorted by ts desc.
Map<int, Conversation> seededConversations() {
  final result = <int, Conversation>{};
  // Tara's thread opens with a greeting and a photo, then the latest message.
  result[10] = Conversation(
    user: users[2].withIdentity(10, 'Tara', 'online'),
    unread: 1,
    timestamp: 6,
    date: '10:24',
    messages: [
      Message(
        id: 61,
        from: 'them',
        text: 'welcome to my profile, call me for talking',
        state: MessageState.sent,
        time: '10:20',
      ),
      Message(
        id: 62,
        from: 'them',
        text: '',
        photo: 3,
        state: MessageState.sent,
        time: '10:21',
      ),
      Message(
        id: 6,
        from: 'them',
        text: 'That story circle was so fun 😄',
        state: MessageState.sent,
        time: '10:24',
      ),
    ],
  );
  for (final (id, base, name, avail, text, unread, timestamp, date) in [
    (12, 4, 'Kabir', 'away', 'Playlist link sent!', 1, 5, '09:12'),
    (
      13,
      5,
      'Isha',
      'online',
      'Mock interview tomorrow at 6?',
      1,
      4,
      'Yesterday',
    ),
    (15, 7, 'Anaya', 'away', 'Thanks for saying hi', 0, 3, '24 Oct'),
    (16, 6, 'Dev', 'unavailable', 'Game night is on Friday', 0, 2, '22 Oct'),
    (17, 1, 'Aarav', 'online', 'Sent you the notes', 0, 1, '20 Oct'),
  ]) {
    result[id] = Conversation(
      user: users[base].withIdentity(id, name, avail),
      unread: unread,
      timestamp: timestamp,
      date: date,
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
