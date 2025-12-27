import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/recipe_provider.dart';
import '../../../inventory/logic/inventory_provider.dart';

class FilterModal extends ConsumerStatefulWidget {
  const FilterModal({super.key});

  @override
  ConsumerState<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends ConsumerState<FilterModal> {
  final Set<String> _tempSelected = {};

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(recipeFilterProvider);
    _tempSelected.addAll(currentFilters);
  }

  void _toggleItem(String name) {
    setState(() {
      if (_tempSelected.contains(name)) {
        _tempSelected.remove(name);
      } else {
        _tempSelected.add(name);
      }
    });
  }

  void _applyFilters() {
    ref.read(recipeFilterProvider.notifier).state = Set.from(_tempSelected);
    Navigator.pop(context); // Close modal
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.6, // Half-screen height
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Filter Ingredients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  setState(() => _tempSelected.clear()); // Clear local selection
                },
                child: const Text("Clear All"),
              ),
            ],
          ),
          const Divider(),

          // List of Fridge Items
          Expanded(
            child: inventoryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Center(child: Text("Could not load inventory")),
              data: (ingredients) {
                if (ingredients.isEmpty) {
                  return const Center(child: Text("No items in fridge to filter!"));
                }
                return ListView.builder(
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    final item = ingredients[index];
                    final isSelected = _tempSelected.contains(item.name);

                    return CheckboxListTile(
                      title: Text(item.name),
                      subtitle: Text(item.displayQuantity),
                      value: isSelected,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (_) => _toggleItem(item.name),
                    );
                  },
                );
              },
            ),
          ),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _applyFilters,
              child: Text("Apply Filters (${_tempSelected.length})"),
            ),
          ),
        ],
      ),
    );
  }
}