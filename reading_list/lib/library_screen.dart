import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((b) => b.read).toList(),
  };

  String _filterName(Filter f) {
    switch (f) {
      case Filter.all:
        return 'All';
      case Filter.unread:
        return 'Unread';
      case Filter.read:
        return 'Read';
    }
  }

  Future<void> _openDetail(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute(builder: (context) => DetailScreen(book: book)),
    );
    if (!mounted) return;
    switch (action) {
      case null:
        break;
      case BookAction.toggleRead:
        setState(() => book.read = !book.read);
      case BookAction.delete:
        setState(() => _books.remove(book));
    }
  }

  Future<void> _addBook() async {
    final book = await Navigator.of(context).push<Book>(
      MaterialPageRoute(builder: (context) => const AddBookScreen()),
    );
    if (book == null) return;
    if (!mounted) return;
    setState(() => _books.add(book));
  }

  Widget _headerColumn(String number, String label) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text(number, style: text.headlineSmall),
          Text(label, style: text.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = _visible;

    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${books.length})')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _headerColumn('${_books.length}', 'Books'),
                  _headerColumn('${totalPages(_books)}', 'Pages'),
                  _headerColumn('${unread(_books).length}', 'Unread'),
                ],
              ),
            ),
          ),
          Row(
            children: [
              for (final f in Filter.values)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(_filterName(f)),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return BookTile(
                  book: book,
                  onToggle: () => setState(() => book.read = !book.read),
                  onTap: () => _openDetail(book),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
