import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _delete(BuildContext context) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (sure != true) return;
    if (!context.mounted) return;
    Navigator.of(context).pop(BookAction.delete);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final year = book.year;

    return Scaffold(
      appBar: AppBar(title: const Text('Book')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: text.headlineSmall),
            const SizedBox(height: 8),
            Text('Author: ${book.author}'),
            Text('Pages: ${book.pages}'),
            Text(year == null ? 'Year unknown' : 'Year: $year'),
            Text(book.read ? 'Status: read' : 'Status: not read yet'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(BookAction.toggleRead),
              child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _delete(context),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
