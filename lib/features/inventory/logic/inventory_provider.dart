import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/ingredient_model.dart';
import '../data/repository/inventory_repository.dart';
import '../../auth/logic/auth_provider.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final uid = ref.watch(userIdProvider); // Use the SAME provider
  return InventoryRepository(uid);
});

// 2. The List State (AsyncValue handles loading/error states automatically)
final inventoryProvider = StateNotifierProvider<InventoryNotifier, AsyncValue<List<Ingredient>>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return InventoryNotifier(repo);
});

class InventoryNotifier extends StateNotifier<AsyncValue<List<Ingredient>>> {
  final InventoryRepository _repo;

  InventoryNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadIngredients();
  }

  // Load Initial Data
  Future<void> loadIngredients() async {
    try {
      final items = await _repo.getIngredients();
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Add Item
  Future<void> addItem(Ingredient item) async {
    // 1. Optimistic Update (Update UI before server responds)
    state.whenData((items) => state = AsyncValue.data([...items, item]));
    
    // 2. Run actual logic
    try {
      await _repo.addIngredient(item);
    } catch (e) {
      // If fail, reload source of truth
      loadIngredients(); 
    }
  }

  // DELETE ITEM
  Future<void> deleteItem(String id) async {
    // 1. Optimistic UI: Remove immediately from list
    state.whenData((items) {
      state = AsyncValue.data(items.where((i) => i.id != id).toList());
    });
    
    // 2. Run actual delete logic
    await _repo.deleteIngredient(id);
  }

  // UPDATE ITEM (Reuse addItem logic)
  Future<void> updateItem(Ingredient updatedItem) async {
    // 1. Optimistic UI: Find and replace
    state.whenData((items) {
      state = AsyncValue.data([
        for (final item in items)
          if (item.id == updatedItem.id) updatedItem else item
      ]);
    });

    // 2. Save to DB (Since ID is same, Repository's add/set logic handles overwrite)
    await _repo.addIngredient(updatedItem);
  }
}