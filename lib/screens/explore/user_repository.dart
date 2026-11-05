import 'dart:async';

import '../../state/models.dart';

/// Data source for the Explore grid. Replace with an API-backed
/// implementation when the backend exists.
abstract class UserRepository {
  Future<List<AppUser>> fetch();
}

class SeedUserRepository implements UserRepository {
  const SeedUserRepository({this.delay = const Duration(milliseconds: 900)});

  final Duration delay;

  @override
  Future<List<AppUser>> fetch() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return users;
  }
}
