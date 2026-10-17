import 'package:flutter/material.dart';

import '../models/game.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.games,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Game> games;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // like IT-2302 or SIS-2104
  static final _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{4}$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _group;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // the profile can be cleared from the drawer while this tab is open
    if (_name.text != widget.profile.name) _name.text = widget.profile.name;
    if (_group.text != widget.profile.group) _group.text = widget.profile.group;
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  String? _validateGroup(String? value) {
    if (!_groupPattern.hasMatch(value?.trim() ?? '')) {
      return 'Use the format IT-2302';
    }
    return null;
  }

  void _showSaved() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  void _saveName(String value) {
    widget.onProfileChanged(widget.profile.copyWith(name: value.trim()));
    _showSaved();
  }

  void _saveGroup(String value) {
    // currentState is not null: the Form with this key is on the screen
    if (!_formKey.currentState!.validate()) return;
    widget.onProfileChanged(widget.profile.copyWith(group: value.trim()));
    _showSaved();
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.name;
    final lists = widget.games.fold(
      0,
      (sum, game) => name.isNotEmpty && game.contains(name) ? sum + 1 : sum,
    );

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          Text(
            'You are on $lists ${lists == 1 ? 'list' : 'lists'}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.name,
            onFieldSubmitted: _saveName,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              labelText: 'Name',
              helperText: 'Press Enter to save',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _group,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            validator: _validateGroup,
            onFieldSubmitted: _saveGroup,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              labelText: 'Group',
              hintText: 'IT-2302',
              helperText: 'Press Enter to save',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text('Theme', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final mode in ThemeMode.values)
                ChoiceChip(
                  label: Text(_themeLabel(mode)),
                  selected: widget.themeMode == mode,
                  onSelected: (_) => widget.onThemeModeChanged(mode),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
