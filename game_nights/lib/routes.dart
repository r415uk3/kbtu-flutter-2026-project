import 'package:flutter/foundation.dart';

import 'models/game.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArgs {
  const DetailArgs({
    required this.game,
    required this.profileName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Game game;
  final String profileName;
  final ValueChanged<Game> onChanged;
  final ValueChanged<Game> onDelete;
  final VoidCallback onOpenProfile;
}

class FormArgs {
  // game is null when we create a new one
  const FormArgs({this.game});

  final Game? game;
}
