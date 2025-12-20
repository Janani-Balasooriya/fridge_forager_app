import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../logic/shopping_provider.dart';
import '../../../inventory/data/models/ingredient_model.dart';
import '../../../inventory/logic/inventory_provider.dart';
import '../../data/models/shopping_item_model.dart';

class BatchTransferModal extends ConsumerStatefulWidget {
  final List<ShoppingItem> itemsToMove;

  const BatchTransferModal({super.key, required this.itemsToMove});

  @override
  ConsumerState<BatchTransferModal> createState() => _BatchTransferModalState();
}

class _BatchTransferModalState extends ConsumerState<BatchTransferModal> {
  // We keep a list of temporary ingredient data for each item
  late List<Ingredient> _pendingItems;

  final List<String> _categories = ['Dairy', 'Vegetable', 'Fruit', 'Meat', 'Pantry'];

  @override
  void initState() {
    super.initState();
    _pendingItems = widget.itemsToMove.map((item) {
      return Ingredient(
        id: const Uuid().v4(), // New ID for the fridge
        name: item.name,       // Keep the name from shopping list
        category: 'Pantry',    // Default
        amount: 1.0,           // Default
        unit: IngredientUnit.pcs,
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        addedDate: DateTime.now(),
      );
    }).toList();
  }

  void _updateItem(int index, {String? category, double? amount, IngredientUnit? unit, DateTime? expiry}) {
    setState(() {
      final old = _pendingItems[index];
      _pendingItems[index] = Ingredient(
        id: old.id,
        name: old.name,
        category: category ?? old.category,
        amount: amount ?? old.amount,
        unit: unit ?? old.unit,
        expiryDate: expiry ?? old.expiryDate,
        addedDate: old.addedDate,
      );
    });
  }

  void _confirmTransfer() {
    // Add all configured items to Inventory
    for (var item in _pendingItems) {
      ref.read(inventoryProvider.notifier).addItem(item);
    }

    // Clear them from Shopping List
    ref.read(shoppingListProvider.notifier).clearChecked();

    // Close Modal
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Moved ${_pendingItems.length} items to Fridge!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Tall modal
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Verify ${widget.itemsToMove.length} Items", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          
          // THE LIST OF FORMS
          Expanded(
            child: ListView.builder(
              itemCount: _pendingItems.length,
              itemBuilder: (context, index) {
                final item = _pendingItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Item Name
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),

                        // Category Chips (Horizontal Scroll)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((cat) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: ChoiceChip(
                                  label: Text(cat, style: const TextStyle(fontSize: 12)),
                                  selected: item.category == cat,
                                  onSelected: (selected) {
                                    if(selected) _updateItem(index, category: cat);
                                  },
                                  selectedColor: Colors.green[100],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Row: Amount & Unit
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: item.amount.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: "Amount", isDense: true, border: OutlineInputBorder()),
                                onChanged: (val) => _updateItem(index, amount: double.tryParse(val) ?? 1.0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<IngredientUnit>(
                                value: item.unit,
                                decoration: const InputDecoration(labelText: "Unit", isDense: true, border: OutlineInputBorder()),
                                items: IngredientUnit.values.map((u) => DropdownMenuItem(value: u, child: Text(u.name))).toList(),
                                onChanged: (val) => _updateItem(index, unit: val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Expiry Date
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: item.expiryDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                            );
                            if (picked != null) _updateItem(index, expiry: picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Expiry", 
                              isDense: true, 
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today, size: 16),
                            ),
                            child: Text(DateFormat('yyyy-MM-dd').format(item.expiryDate)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // CONFIRM BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _confirmTransfer,
              child: const Text("Confirm & Add to Fridge"),
            ),
          ),
        ],
      ),
    );
  }
}