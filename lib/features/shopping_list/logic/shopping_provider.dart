import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/repositories/shopping_repository.dart';
import '../data/models/shopping_item_model.dart';
import '../../auth/logic/auth_provider.dart';

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  // Watch the ID. If user logs out/in, this updates automatically.
  final uid = ref.watch(userIdProvider);
  return ShoppingRepository(uid); 
});

class ShoppingListNotifier extends StateNotifier<AsyncValue<List<ShoppingItem>>> {
  final ShoppingRepository _repository;

  ShoppingListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final items = await _repository.getItems();
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addItem(String name) async {
    final newItem = ShoppingItem(
      id: const Uuid().v4(),
      name: name,
      isChecked: false, // Updated
    );
    final currentList = state.value ?? [];
    state = AsyncValue.data([...currentList, newItem]);
    await _repository.saveItem(newItem);
  }

  Future<void> toggleItem(String id) async {
    final currentList = state.value ?? [];
    final index = currentList.indexWhere((i) => i.id == id);
    if (index != -1) {
      final oldItem = currentList[index];
      // Updated to use isChecked
      final newItem = oldItem.copyWith(isChecked: !oldItem.isChecked);
      
      currentList[index] = newItem;
      state = AsyncValue.data([...currentList]);

      await _repository.saveItem(newItem);
    }
  }

  Future<void> deleteItem(String id) async {
    final currentList = state.value ?? [];
    state = AsyncValue.data(currentList.where((i) => i.id != id).toList());
    await _repository.deleteItem(id);
  }

  Future<void> clearAll() async {
    state = const AsyncValue.data([]); // Clear UI immediately
    await _repository.deleteAllItems();
  }
  Future<void> clearChecked() async {
    final currentList = state.value ?? [];
    
    // Identify items to remove (where isChecked == true)
    final itemsToRemove = currentList.where((i) => i.isChecked).toList();
    
    // Update State (Keep only unchecked items)
    final remainingItems = currentList.where((i) => !i.isChecked).toList();
    state = AsyncValue.data(remainingItems);

    // Delete from Repository
    for (var item in itemsToRemove) {
      await _repository.deleteItem(item.id);
    }
  }
}

final shoppingListProvider = StateNotifierProvider<ShoppingListNotifier, AsyncValue<List<ShoppingItem>>>((ref) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return ShoppingListNotifier(repo);
});