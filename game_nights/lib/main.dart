import 'package:flutter/material.dart';

import 'models/game.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/game_form_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/shell_screen.dart';

void main() => runApp(const MyApp());

// the default Material primary is the seed, so there is no colour literal
final _seed = const ColorScheme.light().primary;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    if (settings.name == Routes.detail && args is DetailArgs) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(args: args),
      );
    }
    if (settings.name == Routes.form && args is FormArgs) {
      return MaterialPageRoute<Game>(
        settings: settings,
        builder: (_) => GameFormScreen(game: args.game),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Nights',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seed)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      initialRoute: Routes.home,
      routes: {
        Routes.home: (_) => ShellScreen(
          themeMode: _themeMode,
          onThemeModeChanged: _changeThemeMode,
        ),
      },
      onGenerateRoute: _onGenerateRoute,
      onUnknownRoute: (_) =>
          MaterialPageRoute<void>(builder: (_) => const NotFoundScreen()),
    );
  }
}
