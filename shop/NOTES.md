# Practice 9 notes

## Level 1: Lift it up

Adding `total` to the badge the honest way (owner -> BooksScreen -> CartBadge):

- constructors touched: **2** (`BooksScreen`, `CartBadge`), plus the call in `Shell`'s route
- files touched: **3** - `main.dart`, `books_screen.dart`, `cart_badge.dart`
- `BooksScreen` does not even use `total`, it only passes it down to the badge.

Rebuilds: one tap on Add printed **7 lines** in the console
(`BooksScreen build` + 6 `row ...` lines). `setState` in `Shell` rebuilds
the whole screen and every row, even the rows that did not change.
