import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

enum NetworkState { online, offline, slow }

class AppContextState extends ChangeNotifier {
  AppContextState({SharedPreferences? preferences, DateTime Function()? now})
    : _preferences = preferences,
      _now = now ?? DateTime.now {
    try {
      final Object? stored = jsonDecode(
        preferences?.getString(profileKey) ?? '{}',
      );
      if (stored is Map && stored['name'] is String) {
        profileName = stored['name'] as String;
      }
    } on FormatException {
      /* React falls back to an empty profile. */
    }
  }
  static const String profileKey = 'yourapp.profile';
  final SharedPreferences? _preferences;
  final DateTime Function() _now;
  final Set<int> following = {};
  final Set<int> blocked = {};
  final Set<int> visited = {};
  final Map<int, Conversation> convos = seededConversations();
  final Set<Timer> _timers = {};
  String profileName = '';
  int sentCount = 0;
  NetworkState network = NetworkState.online;

  bool get hasProfile => profileName.trim().length >= 2;
  bool get offline => network == NetworkState.offline;
  int get unread => convos.values.fold(0, (sum, convo) => sum + convo.unread);

  void saveProfile(String name) {
    profileName = name;
    _preferences?.setString(profileKey, jsonEncode({'name': name}));
    notifyListeners();
  }

  void toggleFollow(int id) {
    if (!following.remove(id)) following.add(id);
    notifyListeners();
  }

  void block(int id) {
    blocked.add(id);
    convos.remove(id);
    notifyListeners();
  }

  void ensureConvo(AppUser user) {
    if (convos.containsKey(user.id)) return;
    convos[user.id] = Conversation(
      user: user,
      timestamp: _now().millisecondsSinceEpoch,
    );
    notifyListeners();
  }

  void send(int id, String text) {
    final now = _now();
    final mid = now.millisecondsSinceEpoch;
    final convo = convos[id];
    if (convo != null) {
      convos[id] = convo.copyWith(
        timestamp: mid,
        date: 'Today',
        messages: [
          ...convo.messages,
          Message(
            id: mid,
            from: 'me',
            text: text,
            state: MessageState.pending,
            time:
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          ),
        ],
      );
    }
    sentCount++;
    notifyListeners();
    retry(id, mid);
  }

  void retry(int id, int messageId) {
    _setMessageState(
      id,
      messageId,
      offline ? MessageState.failed : MessageState.pending,
    );
    if (offline) return;
    late final Timer timer;
    timer = Timer(
      Duration(milliseconds: network == NetworkState.slow ? 2500 : 700),
      () {
        _timers.remove(timer);
        _setMessageState(id, messageId, MessageState.sent);
      },
    );
    _timers.add(timer);
  }

  void _setMessageState(int id, int mid, MessageState state) {
    final convo = convos[id];
    if (convo == null) return;
    convos[id] = convo.copyWith(
      messages: [
        for (final msg in convo.messages)
          msg.id == mid ? msg.withState(state) : msg,
      ],
    );
    notifyListeners();
  }

  void markRead(int id) {
    final convo = convos[id];
    if (convo == null || convo.unread == 0) return;
    convos[id] = convo.copyWith(unread: 0);
    notifyListeners();
  }

  void visit(int id) {
    if (visited.add(id)) notifyListeners();
  }

  void setOffline(bool value) {
    network = value ? NetworkState.offline : NetworkState.online;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }
}
