import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/shopping_item_model.dart';

class ShoppingRepository {
  final String _uid;
  static const String boxName = 'shopping_list';

  ShoppingRepository(this._uid);

  CollectionReference get _shoppingRef {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('shopping_list');
  }

  Future<List<ShoppingItem>> getItems() async {
    final box = await Hive.openBox<ShoppingItem>(boxName);
    try {
      final snapshot = await _shoppingRef.get();
      if (snapshot.docs.isNotEmpty) {
        final remoteItems = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return ShoppingItem.fromJson(data);
        }).toList();

        await box.clear();
        for (var item in remoteItems) {
          await box.put(item.id, item);
        }
        return remoteItems;
      } else {
        return box.values.toList();
      }
    } catch (e) {
      return box.values.toList();
    }
  }

  Future<void> saveItem(ShoppingItem item) async {
    final box = await Hive.openBox<ShoppingItem>(boxName);
    await box.put(item.id, item);
    try {
      await _shoppingRef.doc(item.id).set(item.toJson());
    } catch (e) {
      print("Offline save only");
    }
  }

  Future<void> deleteItem(String id) async {
    final box = await Hive.openBox<ShoppingItem>(boxName);
    await box.delete(id);
    try {
      await _shoppingRef.doc(id).delete();
    } catch (e) {
      print("Offline delete only");
    }
  }

  Future<void> deleteAllItems() async {
    final box = await Hive.openBox<ShoppingItem>(boxName);
    await box.clear();
    try {
      final snapshot = await _shoppingRef.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("Offline clear only");
    }
  }
}