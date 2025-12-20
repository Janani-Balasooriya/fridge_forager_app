import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/repositories/shopping_repository.dart';
import '../data/models/shopping_item_model.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../core/services/shopping_list_hive_service.dart';

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  final uid = ref.watch(userIdProvider);
  return ShoppingRepository(uid);
});

final shoppingListHiveServiceProvider =
    Provider((ref) => ShoppingListHiveService());

class ShoppingListNotifier
    extends StateNotifier<AsyncValue<List<ShoppingItem>>> {
  final ShoppingRepository _repository;
  final ShoppingListHiveService _hiveService;

  ShoppingListNotifier(this._repository, this._hiveService)
      : super(const AsyncValue.loading()) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final hiveItems = _hiveService.getAllItems();
      if (hiveItems.isNotEmpty) {
        state = AsyncValue.data(hiveItems);
      } else {
        final repoItems = await _repository.getItems();
        await _saveAllToHive(repoItems);
        state = AsyncValue.data(repoItems);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _saveAllToHive(List<ShoppingItem> items) async {
    for (var item in items) {
      await _hiveService.addItem(item);
    }
  }

  Future<void> addItem(String name) async {
    final newItem = ShoppingItem(
      id: const Uuid().v4(),
      name: name,
      isChecked: false,
    );
    final currentList = state.value ?? [];
    state = AsyncValue.data([...currentList, newItem]);

    await _hiveService.addItem(newItem);
    await _repository.saveItem(newItem);
  }

  Future<void> toggleItem(String id) async {
    final currentList = state.value ?? [];
    final index = currentList.indexWhere((i) => i.id == id);
    if (index != -1) {
      final oldItem = currentList[index];
      final newItem = oldItem.copyWith(isChecked: !oldItem.isChecked);

      currentList[index] = newItem;
      state = AsyncValue.data([...currentList]);

      await _hiveService.updateItem(newItem);
      await _repository.saveItem(newItem);
    }
  }

  Future<void> deleteItem(String id) async {
    final currentList = state.value ?? [];
    state = AsyncValue.data(currentList.where((i) => i.id != id).toList());

    await _hiveService.deleteItem(id);
    await _repository.deleteItem(id);
  }

  Future<void> clearAll() async {
    state = const AsyncValue.data([]);
    await _hiveService.clearAll();
    await _repository.deleteAllItems();
  }

  Future<void> clearChecked() async {
    final currentList = state.value ?? [];
    final itemsToRemove = currentList.where((i) => i.isChecked).toList();
    final remainingItems = currentList.where((i) => !i.isChecked).toList();

    state = AsyncValue.data(remainingItems);

    await _hiveService.deleteCheckedItems();
    for (var item in itemsToRemove) {
      await _repository.deleteItem(item.id);
    }
  }
}

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, AsyncValue<List<ShoppingItem>>>(
        (ref) {
  final repo = ref.watch(shoppingRepositoryProvider);
  final hiveService = ref.watch(shoppingListHiveServiceProvider);
  return ShoppingListNotifier(repo, hiveService);
});

// Optimized selectors for filtered lists - memoized and only computed when needed
final uncheckedItemsProvider = Provider<AsyncValue<List<ShoppingItem>>>((ref) {
  return ref
      .watch(shoppingListProvider)
      .whenData((items) => items.where((i) => !i.isChecked).toList());
});

final checkedItemsProvider = Provider<AsyncValue<List<ShoppingItem>>>((ref) {
  return ref
      .watch(shoppingListProvider)
      .whenData((items) => items.where((i) => i.isChecked).toList());
});
