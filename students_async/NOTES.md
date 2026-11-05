# Practice 10 notes

## Level 1: The order of events

Code in `main()` before `runApp`:

```dart
print('A');
Future.delayed(const Duration(seconds: 2), () => print('B'));
print('C');
final api = FakeApi();
api.fetchStudents().then((l) => print('${l.length} students'));
```

**What I expected:** A, C, then the app draws, and after 2 seconds B and
`6 students`. `Future.delayed` does not stop `main()`, it only puts a callback
in the queue for later.

**What actually happened** (I also printed `first frame` from a post-frame callback):

```
flutter: A
flutter: C
flutter: fetchStudents #1
flutter: first frame
flutter: B
flutter: 6 students
```

Same as I expected. `fetchStudents #1` is printed right away because the code
before the first `await` runs synchronously. Nothing waited for the timer.

Calling `fetchStudents()` three times in a row on one `FakeApi`, without
awaiting:

```
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Instance of 'NoConnectionException'
```

The app kept running as if nothing happened. Nobody awaited that Future, so
nobody caught the error.

With `sleep(const Duration(seconds: 2))` from `dart:io` instead of
`await Future.delayed(...)`, the screen stays white for 2 seconds before the
first frame. `sleep` blocks the loop, so it cannot draw anything. `await` just
waits and lets the loop keep working. I put the `await` back and removed the
experiments from `main()`.

## Level 2: setState() after dispose()

With both `if (!mounted) return;` lines deleted, I opened the screen and
pressed Back within 2 seconds:

```
setState() called after dispose(): _StudentsScreenState#86294(lifecycle state: defunct, not mounted)
```

With the guards back, pressing Back during loading prints nothing. The answer
comes to a State that is already gone, and `mounted` is false, so we just
return.

## Level 3: FutureBuilder and the Switch

- Future in a field (`_future`): flipping the Switch 10 times prints only
  `fetchStudents #1`.
- `future: _api.fetchStudents()` inline in `build`: each flip is a rebuild, and
  each rebuild makes a new request: `#1 #2 #3 ... #12`. A spinner on every
  flip, and every third request fails.

## Level 4: The countdown

**Version B with `_sub.cancel()`**: Back at 7, and the console stops:

```
tick 10
tick 9
tick 8
tick 7
```

**Version B without `cancel()`**: Back at 7, and the console keeps going down
to 0, with an error on every tick:

```
tick 7
setState() called after dispose(): _CountdownBState#042cb(lifecycle state: defunct, not mounted)
tick 6
setState() called after dispose(): _CountdownBState#042cb(lifecycle state: defunct, not mounted)
tick 5
...
```

It's the same error as Level 2, coming from a different place. Nobody is on
the screen, but the stream keeps ticking. That is the leak.

**Version A (StreamBuilder)**: there is no `cancel()` anywhere in my code.
Back in the middle of the count, and the ticks stop right away. StreamBuilder cancels
its subscription for me when it is disposed.

## Level 5: Errors that do not vanish

The "AI version":

```dart
onPressed: () {
  _api.save(n);
  Navigator.pop(context);
},
```

On the second Save the screen pops as if it worked, and the console says:

```
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Bad state: server rejected 6
```

**The user saw a success, but the server said no.**

Note: `flutter analyze` did **not** flag this line, because `unawaited_futures`
only checks inside `async` functions and this callback is not `async`. When I
wrote the same call inside an `async` function, it said:
`Missing an 'await' for the 'Future' computed by this expression`.

The honest version: `await` + `try / on StateError` + `context.mounted` after
the await. It pops only on success and shows a SnackBar with
`server rejected 6` when it fails. While saving, the button is disabled and
shows a small spinner, so a fast double tap sends only one request.
