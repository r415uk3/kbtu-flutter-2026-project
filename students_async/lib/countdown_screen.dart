import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  String _version = 'A';

  @override
  Widget build(BuildContext context) {
    Widget counter;
    if (_version == 'A') {
      counter = const CountdownA();
    } else {
      counter = const CountdownB();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'A', label: Text('A: StreamBuilder')),
              ButtonSegment(value: 'B', label: Text('B: listen')),
            ],
            selected: {_version},
            onSelectionChanged: (selected) {
              setState(() => _version = selected.first);
            },
          ),
          Expanded(child: Center(child: counter)),
        ],
      ),
    );
  }
}

class CountdownA extends StatefulWidget {
  const CountdownA({super.key});

  @override
  State<CountdownA> createState() => _CountdownAState();
}

class _CountdownAState extends State<CountdownA> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snapshot) {
        return Text(
          '${snapshot.data ?? 10}',
          style: Theme.of(context).textTheme.displayLarge,
        );
      },
    );
  }
}

class CountdownB extends StatefulWidget {
  const CountdownB({super.key});

  @override
  State<CountdownB> createState() => _CountdownBState();
}

class _CountdownBState extends State<CountdownB> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) {
      setState(() => _left = i);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_left', style: Theme.of(context).textTheme.displayLarge);
  }
}
