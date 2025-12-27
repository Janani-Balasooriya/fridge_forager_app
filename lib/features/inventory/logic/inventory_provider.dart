import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/ingredient_model.dart';
import '../data/repository/inventory_repository.dart';
import '../../auth/logic/auth_provider.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final uid = ref.watch(userIdProvider);
  return InventoryRepository(uid);
});

final inventoryProvider = StateNotifierProvider<InventoryNotifier, AsyncValue<List<Ingredient>>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return InventoryNotifier(repo);
});

class InventoryNotifier extends StateNotifier<AsyncValue<List<Ingredient>>> {
  final InventoryRepository _repo;

  InventoryNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadIngredients();
  }

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
    state.whenData((items) => state = AsyncValue.data([...items, item]));
    try {
      await _repo.addIngredient(item);
    } catch (e) {
      loadIngredients(); 
    }
  }

  // DELETE ITEM
  Future<void> deleteItem(String id) async {
    state.whenData((items) {
      state = AsyncValue.data(items.where((i) => i.id != id).toList());
    });
    await _repo.deleteIngredient(id);
  }

  // UPDATE ITEM
  Future<void> updateItem(Ingredient updatedItem) async {
    state.whenData((items) {
      state = AsyncValue.data([
        for (final item in items)
          if (item.id == updatedItem.id) updatedItem else item
      ]);
    });

    // Save to DB (Since ID is same, Repository's add/set logic handles overwrite)
    await _repo.addIngredient(updatedItem);
  }
}