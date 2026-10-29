import 'package:flutter/material.dart';

import 'book_row.dart';
import 'cart_badge.dart';
import 'models/book.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  // search text is only used here, so it stays in this State
  String _search = '';

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');

    final List<Book> shown = [];
    for (final b in books) {
      if (b.title.toLowerCase().contains(_search.toLowerCase())) {
        shown.add(b);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search books',
            border: InputBorder.none,
          ),
          onChanged: (text) => setState(() => _search = text),
        ),
        actions: const [CartBadge()],
      ),
      body: ListView(children: [for (final b in shown) BookRow(book: b)]),
    );
  }
}
