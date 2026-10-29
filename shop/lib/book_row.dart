import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/book.dart';
import 'models/cart.dart';

class BookRow extends StatelessWidget {
  const BookRow({super.key, required this.book});

  final Book book;

  void _add(BuildContext context) {
    // read: we only call add, we don't need to rebuild
    final ok = context.read<Cart>().add(book);
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${book.title}');
    // watch: this row must rebuild when the cart changes
    final inCart = context.watch<Cart>().items.contains(book);

    Widget trailing;
    if (inCart) {
      trailing = const Text('Added');
    } else {
      trailing = OutlinedButton(
        onPressed: () => _add(context),
        child: const Text('Add'),
      );
    }

    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: trailing,
    );
  }
}
