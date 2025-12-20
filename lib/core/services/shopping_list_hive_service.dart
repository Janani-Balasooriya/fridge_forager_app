import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../features/shopping_list/data/models/shopping_item_model.dart';

class ShoppingListHiveService {
  static final ShoppingListHiveService _instance =
      ShoppingListHiveService._internal();

  factory ShoppingListHiveService() {
    return _instance;
  }

  ShoppingListHiveService._internal();

  static const String _boxName = 'shopping_list_box';

  Future<void> initializeBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<ShoppingItem>(_boxName);
    }
  }

  Future<void> addItem(ShoppingItem item) async {
    try {
      final box = Hive.box<ShoppingItem>(_boxName);
      await box.put(item.id, item);
      debugPrint('Shopping item saved: ${item.name}');
    } catch (e) {
      debugPrint('Error saving shopping item: $e');
    }
  }

  Future<void> updateItem(ShoppingItem item) async {
    try {
      final box = Hive.box<ShoppingItem>(_boxName);
      await box.put(item.id, item);
      debugPrint('Shopping item updated: ${item.name}');
    } catch (e) {
      debugPrint('Error updating shopping item: $e');
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      final box = Hive.box<ShoppingItem>(_boxName);
      await box.delete(itemId);
      debugPrint('Shopping item deleted: $itemId');
    } catch (e) {
      debugPrint('Error deleting shopping item: $e');
    }
  }

  Future<void> deleteCheckedItems() async {
    try {
      final box = Hive.box<ShoppingItem>(_boxName);
      final keysToDelete = <String>[];

      for (var item in box.values) {
        if (item.isChecked) {
          keysToDelete.add(item.id);
        }
      }

      for (var key in keysToDelete) {
        await box.delete(key);
      }
      debugPrint('Deleted ${keysToDelete.length} checked items');
    } catch (e) {
      debugPrint('Error deleting checked items: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final box = Hive.box<ShoppingItem>(_boxName);
      await box.clear();
      debugPrint('Shopping list cleared');
    } catch (e) {
      debugPrint('Error clearing shopping list: $e');
    }
  }

  List<ShoppingItem> getAllItems() {
    try {
      final box = Hive.box<ShoppingItem>(_boxName);
      return box.values.toList();
    } catch (e) {
      debugPrint('Error getting shopping items: $e');
      return [];
    }
  }

  ShoppingItem? getItem(String itemId) {
    try {
      final box = Hive.box<ShoppingItem>(_boxName);
      return box.get(itemId);
    } catch (e) {
      debugPrint('Error getting shopping item: $e');
      return null;
    }
  }

  List<ShoppingItem> getCheckedItems() {
    try {
      final box = Hive.box<ShoppingItem>(_boxName);
      return box.values.where((item) => item.isChecked).toList();
    } catch (e) {
      debugPrint('Error getting checked items: $e');
      return [];
    }
  }

  List<ShoppingItem> getUncheckedItems() {
    try {
      final box = Hive.box<ShoppingItem>(_boxName);
      return box.values.where((item) => !item.isChecked).toList();
    } catch (e) {
      debugPrint('Error getting unchecked items: $e');
      return [];
    }
  }

  Future<void> restoreFromBackup(List<ShoppingItem> items) async {
    try {
      final box = Hive.box<ShoppingItem>(_boxName);
      await box.clear();
      for (var item in items) {
        await box.put(item.id, item);
      }
      debugPrint('Shopping list restored from backup');
    } catch (e) {
      debugPrint('Error restoring shopping list: $e');
    }
  }
}
