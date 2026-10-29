# Practice 9 notes

## Level 1: Lift it up

Adding `total` to the badge the honest way (owner -> BooksScreen -> CartBadge):

- constructors touched: **2** (`BooksScreen`, `CartBadge`), plus the call in `Shell`'s route
- files touched: **3** - `main.dart`, `books_screen.dart`, `cart_badge.dart`
- `BooksScreen` does not even use `total`, it only passes it down to the badge.

Rebuilds: one tap on Add printed **7 lines** in the console
(`BooksScreen build` + 6 `row ...` lines). `setState` in `Shell` rebuilds
the whole screen and every row, even the rows that did not change.

## Level 2: A model with no widgets

`Cart` runs without any screen. In `main()` before `runApp` I added two books,
added the first one again (returned `false`), removed one and printed:

```
1 items, 3100 ₸
```

`cart.items.add(books[0])` from outside throws:

```
Unsupported operation: Cannot add to an unmodifiable list
```

So only `add` can change the cart, and `add` always calls `notifyListeners()`.
Giving `Cart` a `BuildContext` field breaks the `main()` code, because there is
no context before `runApp`. The model must not need a context.

## Level 3: provider - the two errors

The loud one - `context.watch<Cart>().add(b)` inside `onPressed`:

```
Tried to listen to a value exposed with provider, from outside of the widget tree.

This is likely caused by an event handler (like a button's onPressed) that called
Provider.of without passing `listen: false`.

To fix, write:
Provider.of<Cart>(context, listen: false);
```

The silent one - `context.read<Cart>().count` inside the badge's `build`:
no error at all, it compiles and runs, but the badge stays at **0** forever,
because nobody said "I depend on the cart".

## Level 4: badge rebuilds

Pressing `+` on a cart row three times (count does not change):

| badge uses | `badge build` lines |
|---|---|
| `context.watch<Cart>().count` | **3** |
| `context.select<Cart, int>((c) => c.count)` | **0** |

Removing a book with `select`: **1** `badge build` (the count changed).

The rows on the Books screen still use `watch`, so three `+` presses printed
18 `row ...` lines (6 rows x 3). If I put `context.watch<Cart>()` into
`BooksScreen.build`, the whole screen rebuilds too. Subscribe where the value
is shown.

## Where does it live?

- **The cart** - provided. Two screens (Books and Cart) and the badge need it,
  so it lives in a `ChangeNotifierProvider` above `MaterialApp`.
- **The search text** - ephemeral. Only the Books screen uses it to filter the
  list, so it is a `String` in `_BooksScreenState`.
- **Total expanded or collapsed** - ephemeral. Only the Cart screen cares, it
  would be a `bool` in that screen's `State`.
- **Theme mode (dark switch)** - provided (or lifted). `MaterialApp` itself needs
  it, so it must live above `MaterialApp`, like the cart.
