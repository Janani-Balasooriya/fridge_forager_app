import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/inventory_provider.dart';
import '../../data/models/ingredient_model.dart';
import '../widgets/add_item_modal.dart';

class MyFridgeScreen extends ConsumerStatefulWidget {
  const MyFridgeScreen({super.key});

  @override
  ConsumerState<MyFridgeScreen> createState() => _MyFridgeScreenState();
}

class _MyFridgeScreenState extends ConsumerState<MyFridgeScreen> {
  // Controller for the search bar
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Listen to changes in the search text field
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryProvider);

    return DefaultTabController(
      length: 4, // All, Fresh, Soon, Wasted
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Fridge', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true, // Allows tabs to scroll if they get too wide
            labelColor: Color(0xFF2ECC71), // Active color (Green)
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2ECC71),
            tabs: [
              Tab(text: "All Items"),
              Tab(text: "Fresh"),
              Tab(text: "Expiring Soon"),
              Tab(text: "Wasted"),
            ],
          ),
        ),
        body: inventoryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (ingredients) {
            // --- 1. SEARCH FILTER ---
            // Filter the master list based on the search text first
            final searchResults = ingredients.where((item) {
              return item.name.toLowerCase().contains(_searchQuery);
            }).toList();

            if (ingredients.isEmpty) {
              return const Center(child: Text("Your fridge is empty! Add items +"));
            }

            // --- 2. CATEGORY FILTERS ---
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            // Fresh: Expires in 4+ days
            final freshItems = searchResults.where((i) {
               final expiry = DateTime(i.expiryDate.year, i.expiryDate.month, i.expiryDate.day);
               return expiry.difference(today).inDays > 3;
            }).toList();

            // Soon: Expires in 0-3 days
            final soonItems = searchResults.where((i) {
               final expiry = DateTime(i.expiryDate.year, i.expiryDate.month, i.expiryDate.day);
               final diff = expiry.difference(today).inDays;
               return diff >= 0 && diff <= 3;
            }).toList();

            // Wasted: Already expired
            final wastedItems = searchResults.where((i) {
               final expiry = DateTime(i.expiryDate.year, i.expiryDate.month, i.expiryDate.day);
               return expiry.isBefore(today);
            }).toList();

            return Column(
              children: [
                // --- SEARCH BAR UI ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search ingredients...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // Pill shape
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),

                // --- TAB VIEWS ---
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildList(searchResults), // All
                      _buildList(freshItems),    // Fresh
                      _buildList(soonItems),     // Soon
                      _buildList(wastedItems),   // Wasted
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              builder: (context) => const AddItemModal(),
            );
          },
        ),
      ),
    );
  }

  // --- REUSABLE LIST BUILDER ---
  Widget _buildList(List<Ingredient> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.kitchen, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              "No items found",
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildListItem(item, context);
      },
    );
  }

  // --- INDIVIDUAL LIST ITEM ---
  Widget _buildListItem(Ingredient item, BuildContext context) {
    final now = DateTime.now();
    final difference = DateTime(item.expiryDate.year, item.expiryDate.month, item.expiryDate.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    Color statusColor;
    String statusText;
    Color textColor;

    if (difference < 0) {
      statusColor = Colors.red[100]!;
      statusText = "Expired";
      textColor = Colors.red;
    } else if (difference <= 3) {
      statusColor = Colors.orange[100]!;
      statusText = difference == 0 ? "Expires Today" : "Expires in $difference days";
      textColor = Colors.deepOrange;
    } else {
      statusColor = Colors.green[100]!;
      statusText = "Expires: ${item.expiryDate.toString().split(' ')[0]}";
      textColor = Colors.grey;
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(inventoryProvider.notifier).deleteItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${item.name} deleted")),
        );
      },
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            builder: (context) => AddItemModal(itemToEdit: item),
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Slightly tighter spacing
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: statusColor,
              foregroundColor: Colors.black54,
              child: Icon(_getCategoryIcon(item.category), size: 20),
            ),
            title: Text(
              item.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: difference < 0 ? TextDecoration.lineThrough : null,
                color: difference < 0 ? Colors.grey : Colors.black,
              ),
            ),
            subtitle: Text(
              statusText,
              style: TextStyle(
                color: textColor,
                fontWeight: difference <= 3 ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
            trailing: Text(
              item.displayQuantity,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Dairy': return Icons.egg_alt;
      case 'Vegetable': return Icons.eco;
      case 'Fruit': return Icons.apple;
      case 'Meat': return Icons.set_meal;
      case 'Pantry': return Icons.shopping_basket;
      default: return Icons.fastfood;
    }
  }
}