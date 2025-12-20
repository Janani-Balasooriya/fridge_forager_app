import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/shopping_provider.dart';
import '../../data/models/shopping_item_model.dart';
import '../widgets/batch_transfer_modal.dart'; 

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final TextEditingController _quickAddController = TextEditingController();

  void _handleQuickAdd() {
    if (_quickAddController.text.trim().isEmpty) return;
    ref.read(shoppingListProvider.notifier).addItem(_quickAddController.text);
    _quickAddController.clear();
  }

  void _moveCheckedToFridge(List<ShoppingItem> checkedItems) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => BatchTransferModal(itemsToMove: checkedItems),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shoppingListAsync = ref.watch(shoppingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => ref.read(shoppingListProvider.notifier).clearAll(),
          )
        ],
      ),
      body: shoppingListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allItems) {
          
          final toBuy = allItems.where((i) => !i.isChecked).toList();
          final completed = allItems.where((i) => i.isChecked).toList();

          return Column(
            children: [
              // QUICK ADD BAR
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _quickAddController,
                  onSubmitted: (_) => _handleQuickAdd(),
                  decoration: InputDecoration(
                    hintText: "Add item to list...",
                    prefixIcon: const Icon(Icons.add),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _handleQuickAdd,
                    ),
                  ),
                ),
              ),

              // LISTS
              Expanded(
                child: ListView(
                  children: [
                    if (toBuy.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text("TO BUY", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      ...toBuy.map((item) => _buildItemTile(item)).toList(),
                    ],

                    if (completed.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text("COMPLETED", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      ...completed.map((item) => _buildItemTile(item)).toList(),
                    ],
                  ],
                ),
              ),

              // BATCH TRANSFER
              if (completed.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () => _moveCheckedToFridge(completed),
                    child: Text("Add ${completed.length} Checked to Fridge"),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemTile(ShoppingItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: item.isChecked,
          onChanged: (_) {
            ref.read(shoppingListProvider.notifier).toggleItem(item.id);
          },
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked ? Colors.grey : Colors.black,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18, color: Colors.grey),
          onPressed: () {
             ref.read(shoppingListProvider.notifier).deleteItem(item.id);
          },
        ),
      ),
    );
  }
}