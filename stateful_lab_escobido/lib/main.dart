import 'package:flutter/material.dart';

// Lively color palette used across the app.
const Color kPurple = Color(0xFF7C4DFF);
const Color kPink = Color(0xFFFF4081);
const Color kOrange = Color(0xFFFF9100);
const Color kTeal = Color(0xFF00BFA5);
const Color kBlue = Color(0xFF2979FF);
const Color kBackground = Color(0xFFFFF7FB);

// Each item gets one of these accent colors (based on its name).
const List<Color> kItemColors = [
  Color(0xFFFF4081), // pink
  Color(0xFF00BFA5), // teal
  Color(0xFFFF9100), // orange
  Color(0xFF7C4DFF), // purple
  Color(0xFF2979FF), // blue
  Color(0xFF76B900), // green
];

void main() => runApp(
      MaterialApp(
        title: 'Mini Shopping Cart',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: kPurple, // lively purple theme seed
          scaffoldBackgroundColor: kBackground,
          useMaterial3: true,
        ),
        home: const CartScreen(),
      ),
    );

// ---------------- MODEL ----------------
// name and price never change; quantity and gotIt are changeable (not final).
class CartItem {
  final String name;
  final double price;
  int quantity;
  bool gotIt;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.gotIt = false,
  });
}

// ---------------- STATEFUL SCREEN ----------------
// Stateful because the items, totals and form errors change while the app runs.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // The State owns the list of items.
  final List<CartItem> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Error messages shown under the TextFields (null = no error).
  String? _nameError;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    // Preload 3 sample items.
    _items.addAll([
      CartItem(name: 'Rice', price: 60.00, quantity: 2),
      CartItem(name: 'Eggs', price: 8.00, quantity: 12),
      CartItem(name: 'Milk', price: 95.00, quantity: 1),
    ]);
  }

  @override
  void dispose() {
    // Always dispose controllers to free memory.
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Plus button: stops at 99.
  void _increase(int i) {
    setState(() {
      if (_items[i].quantity < 99) {
        _items[i].quantity++;
      }
    });
  }

  // Minus button: never goes below 1.
  void _decrease(int i) {
    setState(() {
      if (_items[i].quantity > 1) {
        _items[i].quantity--;
      }
    });
  }

  // Checkbox: flip the gotIt value.
  void _toggle(int i) {
    setState(() {
      _items[i].gotIt = !_items[i].gotIt;
    });
  }

  // Validate the form, then add the item if everything is valid.
  void _addItem() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    setState(() {
      _nameError = name.isEmpty ? 'Name cannot be empty' : null;
      _priceError =
          (price == null || price <= 0) ? 'Enter a number greater than 0' : null;

      if (_nameError == null && _priceError == null) {
        _items.add(CartItem(name: name, price: price!));
        _nameController.clear();
        _priceController.clear();
      }
    });
  }

  // Remove every item that is marked "got it".
  void _clearChecked() {
    setState(() {
      _items.removeWhere((item) => item.gotIt);
    });
  }

  // Sum of price x quantity for all items.
  double get _total =>
      _items.fold(0.0, (sum, item) => sum + item.price * item.quantity);

  int get _gotCount => _items.where((item) => item.gotIt).length;

  // Same look for both TextFields: filled, rounded, with an icon.
  InputDecoration _fieldDecoration(String label, IconData icon, String? error) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: kPurple),
      filled: true,
      fillColor: const Color(0xFFF3EBFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      errorText: error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mini Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        // Gradient AppBar: purple -> pink -> orange.
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPurple, kPink, kOrange],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ListView inside Expanded to avoid unbounded height error.
            Expanded(
              child: _items.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 64, color: kPink),
                          SizedBox(height: 8),
                          Text('Your cart is empty',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length,
                      itemBuilder: (context, i) {
                        return CartItemTile(
                          item: _items[i],
                          onIncrease: () => _increase(i),
                          onDecrease: () => _decrease(i),
                          onToggle: () => _toggle(i),
                        );
                      },
                    ),
            ),

            // ---------- Summary bar (gradient) ----------
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kTeal, kBlue]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items: ${_items.length}  •  Got it: $_gotCount',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Total: PHP ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ---------- Add item form ----------
            Card(
              margin: const EdgeInsets.all(12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _nameController,
                            decoration: _fieldDecoration(
                              'Item name',
                              Icons.shopping_basket,
                              _nameError,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: _fieldDecoration(
                              'Price',
                              Icons.payments,
                              _priceError,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add'),
                            style: FilledButton.styleFrom(
                              backgroundColor: kPink,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _clearChecked,
                            icon: const Icon(Icons.delete_sweep),
                            label: const Text('Clear checked'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kOrange,
                              side: const BorderSide(color: kOrange, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- STATELESS CHILD ----------------
// Stateless: it only draws the item it receives and calls the callbacks; the parent owns the state.
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onToggle;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Accent color picked from the item's name, so each item looks different.
    final accent = kItemColors[item.name.codeUnitAt(0) % kItemColors.length];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        // Light tint of the accent when the item is checked.
        color: item.gotIt ? accent.withAlpha(45) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(70),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.gotIt,
            activeColor: accent,
            onChanged: (_) => onToggle(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    // line-through when checked
                    decoration: item.gotIt ? TextDecoration.lineThrough : null,
                    color: item.gotIt ? Colors.grey[600] : Colors.black87,
                  ),
                ),
                Text(
                  'PHP ${item.price.toStringAsFixed(2)} each',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove_circle, color: accent),
            onPressed: onDecrease,
          ),
          Text(
            '${item.quantity}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: accent),
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}