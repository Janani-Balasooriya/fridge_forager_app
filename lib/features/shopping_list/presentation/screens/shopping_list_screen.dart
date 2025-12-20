import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/shopping_provider.dart';
import '../../data/models/shopping_item_model.dart';
import '../widgets/batch_transfer_modal.dart';

// Constants for better performance
const _quickAddInputDecoration = InputDecoration(
  hintText: "Add item to list...",
  prefixIcon: Icon(Icons.add),
  filled: true,
  fillColor: Color(0xFFF5F5F5),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide.none,
  ),
);

const _toByHeaderStyle = TextStyle(
  fontWeight: FontWeight.bold,
  color: Colors.grey,
);

const _toByHeaderPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
const _itemMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 4);

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  late final TextEditingController _quickAddController;

  @override
  void initState() {
    super.initState();
    _quickAddController = TextEditingController();
  }

  @override
  void dispose() {
    _quickAddController.dispose();
    super.dispose();
  }

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
    final uncheckedAsync = ref.watch(uncheckedItemsProvider);
    final checkedAsync = ref.watch(checkedItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => ref.read(shoppingListProvider.notifier).clearAll(),
          )
        ],
      ),
      body: uncheckedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (toBuy) {
          return checkedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (completed) {
              return Column(
                children: [
                  // QUICK ADD BAR
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _quickAddController,
                      onSubmitted: (_) => _handleQuickAdd(),
                      decoration: _quickAddInputDecoration.copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: _handleQuickAdd,
                        ),
                      ),
                    ),
                  ),

                  // LISTS
                  Expanded(
                    child: _buildShoppingList(toBuy, completed),
                  ),

                  // BATCH TRANSFER BUTTON
                  if (completed.isNotEmpty)
                    _buildBatchTransferButton(completed),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Builds the shopping list with optimized ListView.builder
  /// Only renders items that are visible - efficient for large lists
  Widget _buildShoppingList(
      List<ShoppingItem> toBuy, List<ShoppingItem> completed) {
    final totalItems = (toBuy.isNotEmpty ? 1 : 0) +
        toBuy.length +
        (completed.isNotEmpty ? 1 : 0) +
        completed.length;

    return ListView.builder(
      itemCount: totalItems,
      itemBuilder: (context, index) {
        int counter = 0;

        // "TO BUY" header
        if (toBuy.isNotEmpty) {
          if (index == counter) {
            return const Padding(
              padding: _toByHeaderPadding,
              child: Text("TO BUY", style: _toByHeaderStyle),
            );
          }
          counter++;

          // TO BUY items
          if (index < counter + toBuy.length) {
            return _buildItemTile(toBuy[index - counter]);
          }
          counter += toBuy.length;
        }

        // "BOUGHT" header
        if (completed.isNotEmpty) {
          if (index == counter) {
            return const Padding(
              padding: _toByHeaderPadding,
              child: Text("Bought", style: _toByHeaderStyle),
            );
          }
          counter++;

          // BOUGHT items
          if (index < counter + completed.length) {
            return _buildItemTile(completed[index - counter]);
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Builds the batch transfer button for completed items
  Widget _buildBatchTransferButton(List<ShoppingItem> completed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))
        ],
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
    );
  }

  /// Individual item tile with memoization through ValueKey
  Widget _buildItemTile(ShoppingItem item) {
    return Card(
      key: ValueKey(item.id),
      margin: _itemMargin,
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
