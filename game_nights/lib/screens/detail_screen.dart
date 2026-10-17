import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/game.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Game _game = widget.args.game;
  late final Timer _timer;

  String get _me => widget.args.profileName;
  bool get _joined => _me.isNotEmpty && _game.contains(_me);

  @override
  void initState() {
    super.initState();
    // rebuild once a minute so the countdown stays fresh
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // keep our copy and tell the shell about the change
  void _update(Game game) {
    setState(() => _game = game);
    widget.args.onChanged(game);
  }

  Future<void> _join() async {
    if (_me.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in the profile first'),
          action: SnackBarAction(label: 'Profile', onPressed: _openProfile),
        ),
      );
      return;
    }
    final ok = await confirm(
      context,
      title: 'Join this game?',
      message: 'Your name will be added to "${_game.title}".',
      action: 'Join',
    );
    if (!ok || !mounted) return;
    _update(_game.copyWith(players: [..._game.players, _me]));
  }

  void _leave() {
    _update(
      _game.copyWith(players: _game.players.where((p) => p != _me).toList()),
    );
  }

  void _openProfile() {
    if (!mounted) return;
    Navigator.pop(context);
    widget.args.onOpenProfile();
  }

  Future<void> _edit() async {
    final edited = await Navigator.pushNamed<Game>(
      context,
      Routes.form,
      arguments: FormArgs(game: _game),
    );
    if (edited == null || !mounted) return;
    _update(edited);
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: 'Delete this game?',
      message: 'Players will lose their places. This cannot be undone.',
      action: 'Delete',
    );
    if (!ok || !mounted) return;
    widget.args.onDelete(_game);
    Navigator.pop(context);
  }

  String _countdownText(Countdown countdown) => switch (countdown) {
    Upcoming(:final left) => 'In ${formatDuration(left)}',
    Started() => 'Going on now',
    Ended() => 'Finished',
  };

  Widget _primaryButton() {
    if (_joined) {
      return OutlinedButton.icon(
        onPressed: _game.isPast ? null : _leave,
        icon: const Icon(Icons.logout),
        label: const Text('Leave'),
      );
    }
    final canJoin = !_game.isFull && !_game.isPast;
    return FilledButton.icon(
      onPressed: canJoin ? _join : null,
      icon: const Icon(Icons.group_add),
      label: Text(_game.isFull ? 'Full' : 'Join'),
    );
  }

  Widget _header() {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 160,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/header.png', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: _game.category.color(scheme),
              foregroundColor: scheme.surface,
              child: Icon(_game.category.icon, size: 36),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Chip(
              avatar: Icon(_game.category.icon),
              label: Text(_game.category.label),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Chip(
              avatar: const Icon(Icons.timer_outlined),
              label: Text(_countdownText(_game.countdown)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _about() {
    final (:taken, :free) = _game.places;
    final notes = _game.notes;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoRow(icon: Icons.event, text: formatDate(_game.startsAt)),
        _InfoRow(
          icon: _game.online ? Icons.link : Icons.place,
          text: _game.place,
        ),
        _InfoRow(
          icon: Icons.event_seat,
          text: '$taken taken, $free free of ${_game.seats}',
        ),
        if (notes != null) _InfoRow(icon: Icons.notes, text: notes),
        const SizedBox(height: 16),
        _primaryButton(),
      ],
    );
  }

  Widget _players() {
    final players = _game.players;
    if (players.isEmpty) {
      return const EmptyState(
        icon: Icons.group_off,
        message: 'Nobody has joined yet',
      );
    }
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, i) {
        final isMe = players[i] == _me;
        return ListTile(
          title: Text(players[i]),
          subtitle: isMe ? const Text('You') : null,
          selected: isMe,
          trailing: isMe ? const Icon(Icons.star) : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _game.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _edit();
                } else {
                  _delete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _header(),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Players (${_game.count})'),
              ],
            ),
            Expanded(child: TabBarView(children: [_about(), _players()])),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
