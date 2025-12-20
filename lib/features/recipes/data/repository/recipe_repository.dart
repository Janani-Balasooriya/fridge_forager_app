import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe_model.dart';

class RecipeRepository {
  final String _uid;
  static const String boxName = 'saved_recipes';

  RecipeRepository(this._uid);

  CollectionReference get _favRef {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('saved_recipes');
  }

  // GET FAVORITES
  Future<List<Recipe>> getFavorites() async {
    final box = await Hive.openBox<Recipe>(boxName);
    
    try {
      final snapshot = await _favRef.get();
      if (snapshot.docs.isNotEmpty) {
        final remoteItems = snapshot.docs.map((doc) {
          return Recipe.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        // Sync Down (Cloud -> Local)
        await box.clear();
        for (var item in remoteItems) {
          await box.put(item.id, item);
        }
        return remoteItems;
      } else {
        return box.values.toList();
      }
    } catch (e) {
      // Offline Mode
      return box.values.toList();
    }
  }

  // SAVE RECIPE
  Future<void> saveFavorite(Recipe recipe) async {
    final box = await Hive.openBox<Recipe>(boxName);
    
    // Save Local
    await box.put(recipe.id, recipe);

    // Save Cloud
    try {
      await _favRef.doc(recipe.id.toString()).set(recipe.toJson());
    } catch (e) {
      print("Offline: Saved locally only");
    }
  }

  // REMOVE FAVORITE
  Future<void> removeFavorite(int recipeId) async {
    final box = await Hive.openBox<Recipe>(boxName);
    
    // Delete Local
    await box.delete(recipeId);

    // Delete Cloud
    try {
      await _favRef.doc(recipeId.toString()).delete();
    } catch (e) {
      print("Offline: Deleted locally only");
    }
  }
}