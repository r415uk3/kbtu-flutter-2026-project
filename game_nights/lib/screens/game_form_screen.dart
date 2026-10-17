import 'package:flutter/material.dart';

import '../models/game.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';

class GameFormScreen extends StatefulWidget {
  // game is null for a new game
  const GameFormScreen({super.key, this.game});

  final Game? game;

  @override
  State<GameFormScreen> createState() => _GameFormScreenState();
}

class _GameFormScreenState extends State<GameFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final Game _base;
  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _seats;
  late final TextEditingController _notes;
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;

  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _seatsFocus = FocusNode();
  final _notesFocus = FocusNode();

  GameCategory? _category;
  bool _online = false;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;

  // the values the form opened with, to know if something changed
  late final Object _initial;

  bool get _isNew => widget.game == null;

  @override
  void initState() {
    super.initState();
    final game = widget.game;
    _base = game ?? Game.empty();

    _title = TextEditingController(text: _base.title);
    _place = TextEditingController(text: _base.place);
    _seats = TextEditingController(text: '${_base.seats}');
    _notes = TextEditingController(text: _base.notes ?? '');

    // a new game starts without category, date and time
    _category = game?.category;
    _online = _base.online;
    final start = game?.startsAt;
    if (start != null) {
      _date = DateTime(start.year, start.month, start.day);
      _time = TimeOfDay.fromDateTime(start);
    }
    _dateText = TextEditingController(
      text: start == null ? '' : formatDay(start),
    );
    _timeText = TextEditingController(
      text: start == null ? '' : formatTime(start.hour, start.minute),
    );

    _initial = _snapshot();
  }

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _seats.dispose();
    _notes.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _seatsFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  // records compare by value, so two snapshots are == when nothing changed
  Object _snapshot() => (
    _title.text,
    _place.text,
    _seats.text,
    _notes.text,
    _category,
    _online,
    _date,
    _time,
  );

  bool get _dirty => _snapshot() != _initial;

  DateTime? get _startsAt {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _hideKeyboard(PointerDownEvent _) {
    FocusScope.of(context).unfocus();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    // Cancel returns null and we keep the old value
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _dateText.text = formatDay(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _timeText.text = formatTime(picked.hour, picked.minute);
    });
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.length < 3) return 'At least 3 characters';
    if (title.length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validatePlace(String? value) {
    final place = value?.trim() ?? '';
    if (place.isEmpty) return _online ? 'Enter a link' : 'Enter a place';
    if (_online && !place.contains('://')) return 'A link must contain ://';
    return null;
  }

  String? _validateSeats(String? value) {
    final seats = int.tryParse(value?.trim() ?? '');
    if (seats == null) return 'Enter a number';
    if (seats < 1 || seats > 500) return 'From 1 to 500';
    if (seats < _base.count) return '${_base.count} players already joined';
    return null;
  }

  String? _validateCategory(GameCategory? value) {
    return value == null ? 'Pick a category' : null;
  }

  String? _validateDate(String? _) {
    return _date == null ? 'Pick a date' : null;
  }

  String? _validateTime(String? _) {
    if (_time == null) return 'Pick a time';
    final start = _startsAt;
    if (_isNew && start != null && start.isBefore(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  Future<void> _save() async {
    // currentState is not null: the Form with this key is on the screen
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    // pretend we are saving to a server
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final notes = _notes.text.trim();
    final game = Game(
      id: _base.id,
      title: _title.text.trim(),
      // validate() passed, so category, date and time are not null
      category: _category!,
      startsAt: _startsAt!,
      place: _place.text.trim(),
      seats: int.parse(_seats.text.trim()),
      players: _base.players,
      online: _online,
      notes: notes.isEmpty ? null : notes,
      favourite: _base.favourite,
    );
    Navigator.pop(context, game);
  }

  Future<void> _askToDiscard() async {
    final discard = await confirm(
      context,
      title: 'Discard changes?',
      message: 'Your changes will be lost.',
      action: 'Discard',
    );
    if (discard && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Game>(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _askToDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New game' : 'Edit game')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // rebuild on every change so canPop is up to date
          onChanged: () => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: _validateTitle,
                onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                onTapOutside: _hideKeyboard,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<GameCategory>(
                initialValue: _category,
                validator: _validateCategory,
                onChanged: (value) => setState(() => _category = value),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final category in GameCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(category.icon),
                          const SizedBox(width: 8),
                          Text(category.label),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online game'),
                subtitle: const Text('The place becomes a link'),
                value: _online,
                onChanged: (value) => setState(() => _online = value),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _place,
                focusNode: _placeFocus,
                keyboardType: _online
                    ? TextInputType.url
                    : TextInputType.streetAddress,
                textInputAction: TextInputAction.next,
                validator: _validatePlace,
                onFieldSubmitted: (_) => _seatsFocus.requestFocus(),
                onTapOutside: _hideKeyboard,
                decoration: InputDecoration(
                  labelText: _online ? 'Link' : 'Place',
                  hintText: _online ? 'https://...' : 'Room, cafe or address',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateText,
                      readOnly: true,
                      onTap: _pickDate,
                      validator: _validateDate,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _timeText,
                      readOnly: true,
                      onTap: _pickTime,
                      validator: _validateTime,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        suffixIcon: Icon(Icons.schedule),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seats,
                focusNode: _seatsFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: _validateSeats,
                onFieldSubmitted: (_) => _notesFocus.requestFocus(),
                onTapOutside: _hideKeyboard,
                decoration: const InputDecoration(
                  labelText: 'Seats',
                  helperText: 'From 1 to 500',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notes,
                focusNode: _notesFocus,
                minLines: 1,
                maxLines: 3,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onTapOutside: _hideKeyboard,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
