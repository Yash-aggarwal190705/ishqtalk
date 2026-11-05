import 'dart:async';

import '../state/models.dart';

/// Social stats for a profile. Replace with API data when a backend exists.
class ProfileStats {
  const ProfileStats({
    required this.following,
    required this.fans,
    required this.friends,
  });

  final int following;
  final int fans;
  final int friends;
}

/// Data source for profile stats, the Visitors list and profile photos.
/// Swap the seed implementation for an API-backed one without touching UI.
abstract class ProfileRepository {
  Future<ProfileStats> statsFor(AppUser user);
  Future<List<AppUser>> visitors();
  Future<List<String>> photosFor(AppUser user);
}

/// Prototype seed values (React `Me`/`Visitors`/`UserProfile`).
class SeedProfileRepository implements ProfileRepository {
  const SeedProfileRepository({
    this.loadingDelay = const Duration(milliseconds: 800),
  });

  final Duration loadingDelay;

  static const ProfileStats _seedStats = ProfileStats(
    following: 7,
    fans: 2695,
    friends: 18,
  );

  /// Visitors from the prototype: Pinku, Anaya, Zoya.
  static const List<AppUser> _seedVisitors = <AppUser>[
    AppUser(
      id: 4,
      name: 'Pinku',
      age: 18,
      country: 'India',
      status: 'red',
      h: 0,
    ),
    AppUser(
      id: 6,
      name: 'Anaya',
      age: 19,
      country: 'India',
      status: 'red',
      h: 0,
    ),
    AppUser(
      id: 1,
      name: 'Zoya',
      age: 22,
      country: 'Pakistan',
      status: 'red',
      h: 0,
    ),
  ];

  @override
  Future<ProfileStats> statsFor(AppUser user) async {
    if (loadingDelay > Duration.zero) await Future<void>.delayed(loadingDelay);
    return _seedStats;
  }

  @override
  Future<List<AppUser>> visitors() async {
    if (loadingDelay > Duration.zero) await Future<void>.delayed(loadingDelay);
    return _seedVisitors;
  }

  @override
  Future<List<String>> photosFor(AppUser user) async => const <String>[
    '',
    '',
    '',
  ];
}
