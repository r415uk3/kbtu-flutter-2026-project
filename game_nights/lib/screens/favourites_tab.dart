import 'package:flutter/material.dart';

import '../models/game.dart';
import '../widgets/empty_state.dart';
import '../widgets/game_list.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.games,
    required this.onOpen,
    required this.onFavourite,
    required this.onBrowse,
  });

  final List<Game> games;
  final ValueChanged<Game> onOpen;
  final ValueChanged<Game> onFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = games.where((g) => g.favourite).toList()
      ..sort(compareGames);

    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet.\nTap the heart on a game to keep it here.',
        buttonLabel: 'Browse games',
        onPressed: onBrowse,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GameList(
        games: favourites,
        onOpen: onOpen,
        onFavourite: onFavourite,
      ),
    );
  }
}
