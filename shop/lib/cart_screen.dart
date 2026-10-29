import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _askClear(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('All books will be removed from the cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (yes == true) {
      context.read<Cart>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          TextButton(
            onPressed: () => _askClear(context),
            child: const Text('Clear cart'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<Cart>(
              builder: (context, cart, _) => ListView(
                children: [
                  for (final b in cart.items)
                    ListTile(
                      title: Text(b.title),
                      subtitle: Text('${b.price} ₸  ×${cart.qtyOf(b)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => cart.increment(b),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => cart.remove(b),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<Cart>(
              // child is built once and reused on every notify
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.payments), SizedBox(width: 8)],
              ),
              builder: (context, cart, child) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  child!,
                  Text(
                    'Total: ${cart.total} ₸',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
