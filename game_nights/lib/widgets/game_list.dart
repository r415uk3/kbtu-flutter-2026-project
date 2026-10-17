import 'package:flutter/material.dart';

import '../models/game.dart';
import 'game_card.dart';

// a list on phones, a grid on wide screens
class GameList extends StatelessWidget {
  const GameList({
    super.key,
    required this.games,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Game> games;
  final ValueChanged<Game> onOpen;
  final ValueChanged<Game> onFavourite;

  Widget _card(Game game) {
    return GameCard(
      game: game,
      onTap: () => onOpen(game),
      onFavourite: () => onFavourite(game),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 88),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 128,
            ),
            itemCount: games.length,
            itemBuilder: (context, i) => _card(games[i]),
          );
        }
        return ListView.separated(
          // bottom padding so the FAB does not cover the last card
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 88),
          itemCount: games.length,
          separatorBuilder: (context, i) => const SizedBox(height: 4),
          itemBuilder: (context, i) => _card(games[i]),
        );
      },
    );
  }
}
