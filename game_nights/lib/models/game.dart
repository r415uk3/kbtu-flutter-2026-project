import 'package:flutter/material.dart';

import 'countdown.dart';

enum GameCategory {
  strategy('Strategy', Icons.psychology),
  party('Party', Icons.celebration),
  cooperative('Co-op', Icons.handshake),
  cards('Cards', Icons.style),
  deduction('Deduction', Icons.search);

  const GameCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    GameCategory.strategy => scheme.primary,
    GameCategory.party => scheme.tertiary,
    GameCategory.cooperative => scheme.secondary,
    GameCategory.cards => scheme.error,
    GameCategory.deduction => scheme.outline,
  };
}

class Game {
  const Game({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.place,
    required this.seats,
    this._players = const [],
    this.online = false,
    this.notes,
    this.favourite = false,
  });

  Game.empty()
    : this(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '',
        category: GameCategory.strategy,
        startsAt: DateTime.now(),
        place: '',
        seats: 6,
      );

  final String id;
  final String title;
  final GameCategory category;
  final DateTime startsAt;

  // an address, or a link when online is true
  final String place;
  final int seats;
  final List<String> _players;
  final bool online;
  final String? notes;
  final bool favourite;

  List<String> get players => List.unmodifiable(_players);
  int get count => _players.length;
  int get free => seats - count;
  bool get isFull => free <= 0;
  bool get isPast => startsAt.isBefore(DateTime.now());
  ({int taken, int free}) get places => (taken: count, free: free);
  Countdown get countdown => Countdown.of(startsAt, DateTime.now());

  bool contains(String name) => _players.any((p) => p == name);

  Game copyWith({List<String>? players, bool? favourite}) {
    return Game(
      id: id,
      title: title,
      category: category,
      startsAt: startsAt,
      place: place,
      seats: seats,
      players: players ?? _players,
      online: online,
      notes: notes,
      favourite: favourite ?? this.favourite,
    );
  }
}

// upcoming games first by date, past games at the end
int compareGames(Game a, Game b) {
  if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
  return a.startsAt.compareTo(b.startsAt);
}
