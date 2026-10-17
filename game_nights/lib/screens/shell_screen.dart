import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/game.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../widgets/confirm_dialog.dart';
import 'favourites_tab.dart';
import 'games_tab.dart';
import 'profile_tab.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  // all app data lives here and goes down to the tabs
  List<Game> _games = seedGames();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  static const _titles = ['Game nights', 'Favourites', 'Profile'];

  void _goToTab(int index) {
    setState(() => _tab = index);
  }

  void _replace(Game updated) {
    setState(() {
      _games = _games.map((g) => g.id == updated.id ? updated : g).toList();
    });
  }

  void _delete(Game game) {
    setState(() {
      _games = _games.where((g) => g.id != game.id).toList();
    });
  }

  void _toggleFavourite(Game game) {
    _replace(game.copyWith(favourite: !game.favourite));
  }

  void _changeProfile(Profile profile) {
    setState(() => _profile = profile);
  }

  void _openDetail(Game game) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        game: game,
        profileName: _profile.name,
        onChanged: _replace,
        onDelete: _delete,
        onOpenProfile: () => _goToTab(2),
      ),
    );
  }

  Future<void> _create() async {
    final game = await Navigator.pushNamed<Game>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (game == null || !mounted) return;
    setState(() => _games = [..._games, game]);
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Nights'),
        content: const Text(
          'Board game evenings at the campus club. '
          'Find a game, join it and bring your friends.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _reset() async {
    final ok = await confirm(
      context,
      title: 'Reset data?',
      message: 'All games go back to the start and your profile is cleared.',
      action: 'Reset',
    );
    if (!ok || !mounted) return;
    setState(() {
      _games = seedGames();
      _profile = const Profile.empty();
    });
  }

  Widget _body() {
    return switch (_tab) {
      0 => GamesTab(
        games: _games,
        onOpen: _openDetail,
        onFavourite: _toggleFavourite,
        onCreate: _create,
      ),
      1 => FavouritesTab(
        games: _games,
        onOpen: _openDetail,
        onFavourite: _toggleFavourite,
        onBrowse: () => _goToTab(0),
      ),
      _ => ProfileTab(
        profile: _profile,
        games: _games,
        themeMode: widget.themeMode,
        onProfileChanged: _changeProfile,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(
                'Game Nights',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            ListTile(
              title: const Text('About'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                Navigator.pop(context);
                _showAbout();
              },
            ),
            ListTile(
              title: const Text('Reset data'),
              trailing: const Icon(Icons.restart_alt),
              onTap: () {
                Navigator.pop(context);
                _reset();
              },
            ),
          ],
        ),
      ),
      body: _body(),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: _create,
              tooltip: 'New game',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.casino), label: 'Games'),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
