import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ingredient_model.dart';

class InventoryRepository {
  final String _uid;
  static const String boxName = 'fridge_inventory';

  InventoryRepository(this._uid);

  // Helper: Gets the Firestore reference for this user's ingredients
  // This is a "getter" so it doesn't run until we actually need it (prevents crashes)
  CollectionReference get _ingredientsRef {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('ingredients');
  }

  /// GET DATA (Hybrid Sync Strategy)
  Future<List<Ingredient>> getIngredients() async {
    final box = await Hive.openBox<Ingredient>(boxName);

    try {
      // Try fetching from Cloud
      final snapshot = await _ingredientsRef.get();

      // If Cloud has data, update Local (Sync Down)
      if (snapshot.docs.isNotEmpty) {
        final remoteIngredients = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Ensure the ID matches the document ID
          data['id'] = doc.id; 
          return Ingredient.fromJson(data);
        }).toList();

        // Overwrite local cache with fresh cloud data
        await box.clear();
        // Use .put() to ensure Hive Key == Item ID
        for (var item in remoteIngredients) {
          await box.put(item.id, item);
        }

        return remoteIngredients;
      } else {
        // Cloud is empty, return local
        return box.values.toList();
      }

    } catch (e) {
      // Offline Mode? Fallback to Hive
      print("Offline Mode active: Fetching from Hive only. Error: $e");
      return box.values.toList();
    }
  }

  /// ADD ITEM (Double Write)
  Future<void> addIngredient(Ingredient item) async {
    final box = await Hive.openBox<Ingredient>(boxName);
    
    // Save Locally (Instant UI update)
    // Using .put(id, item) ensures we can delete it easily later by ID
    await box.put(item.id, item);

    // Sync to Cloud
    try {
      // Use .set() with the item's ID so the Document ID matches our Item ID
      await _ingredientsRef.doc(item.id).set(item.toJson());
    } catch (e) {
      print("Offline: Item saved locally only. Sync failed: $e");
    }
  }

  /// DELETE ITEM (Double Delete)
  Future<void> deleteIngredient(String id) async {
    final box = await Hive.openBox<Ingredient>(boxName);
    
    // Delete Locally (O(1) operation because we used .put)
    await box.delete(id);

    // Delete from Cloud
    try {
      await _ingredientsRef.doc(id).delete();
    } catch (e) {
      print("Offline: Delete processed locally only. Sync failed: $e");
    }
  }
}