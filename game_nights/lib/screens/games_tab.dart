import 'package:flutter/material.dart';

import '../models/game.dart';
import '../widgets/empty_state.dart';
import '../widgets/game_list.dart';

class GamesTab extends StatefulWidget {
  const GamesTab({
    super.key,
    required this.games,
    required this.onOpen,
    required this.onFavourite,
    required this.onCreate,
  });

  final List<Game> games;
  final ValueChanged<Game> onOpen;
  final ValueChanged<Game> onFavourite;
  final VoidCallback onCreate;

  @override
  State<GamesTab> createState() => _GamesTabState();
}

class _GamesTabState extends State<GamesTab> {
  final _search = TextEditingController();
  GameCategory? _category; // null means "All"
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearSearch() {
    setState(() => _search.clear());
  }

  Widget _buildList(List<Game> visible) {
    if (widget.games.isEmpty) {
      return EmptyState(
        icon: Icons.casino_outlined,
        message: 'No game nights yet',
        buttonLabel: 'Add a game',
        onPressed: widget.onCreate,
      );
    }
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        message: 'No games match your search',
        buttonLabel: 'Clear search',
        onPressed: _clearSearch,
      );
    }
    return GameList(
      games: visible,
      onOpen: widget.onOpen,
      onFavourite: widget.onFavourite,
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    // toList() makes a copy, so sort never touches the list from the shell
    final visible =
        widget.games
            .where((g) => _showPast || !g.isPast)
            .where((g) => _category == null || g.category == _category)
            .where((g) => g.title.toLowerCase().contains(query))
            .toList()
          ..sort(compareGames);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search games',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final category in GameCategory.values)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    avatar: Icon(category.icon),
                    label: Text(category.label),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label: const Text('Past'),
                  selected: _showPast,
                  onSelected: (value) => setState(() => _showPast = value),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildList(visible)),
      ],
    );
  }
}
