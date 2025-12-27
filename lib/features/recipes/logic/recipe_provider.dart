import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../inventory/logic/inventory_provider.dart';
import '../data/models/recipe_model.dart';
import '../../inventory/data/models/ingredient_model.dart';

import '../data/repository/recipe_repository.dart';
import '../../auth/logic/auth_provider.dart'; 

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// REPOSITORY PROVIDER
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final uid = ref.watch(userIdProvider); // Dynamic User ID from Auth
  return RecipeRepository(uid);
});

// FAVORITES NOTIFIER
class FavoritesNotifier extends StateNotifier<AsyncValue<List<Recipe>>> {
  final RecipeRepository _repository;
  final List<Ingredient> _currentInventory;

  FavoritesNotifier(this._repository, AsyncValue<List<Ingredient>> inventoryState) 
      : _currentInventory = inventoryState.valueOrNull ?? [],
        super(const AsyncValue.loading()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      // Get the raw recipes from Hive/Firebase
      final rawRecipes = await _repository.getFavorites();
      final smartRecipes = _recalculateStatus(rawRecipes);

      state = AsyncValue.data(smartRecipes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // THE LOGIC ENGINE
  List<Recipe> _recalculateStatus(List<Recipe> recipes) {
    // If fridge is empty, mark everything as missing
    if (_currentInventory.isEmpty) {
      return recipes.map((r) {
        final allIngredients = [...r.usedIngredients, ...r.missedIngredients];
        return r.copyWith(
          usedIngredients: [],
          missedIngredients: allIngredients,
          usedIngredientCount: 0,
          missedIngredientCount: allIngredients.length,
        );
      }).toList();
    }

    // Prepare a set of lowercase fridge item names for fast lookup
    final fridgeItems = _currentInventory
        .map((i) => i.name.toLowerCase().trim())
        .toSet();

    return recipes.map((recipe) {
      // Combine all ingredients the recipe needs
      final allRequired = [...recipe.usedIngredients, ...recipe.missedIngredients];

      final List<String> newUsed = [];
      final List<String> newMissed = [];

      for (var ingredient in allRequired) {
        // Check if we have it NOW
        // Using 'contains' helps match "Apple" with "Green Apple"
        bool hasItem = fridgeItems.any((fridgeItem) => 
            fridgeItem.contains(ingredient.toLowerCase()) || 
            ingredient.toLowerCase().contains(fridgeItem));

        if (hasItem) {
          newUsed.add(ingredient);
        } else {
          newMissed.add(ingredient);
        }
      }

      // Return a fresh copy with updated counts
      return recipe.copyWith(
        usedIngredients: newUsed,
        missedIngredients: newMissed,
        usedIngredientCount: newUsed.length,
        missedIngredientCount: newMissed.length,
      );
    }).toList();
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final currentList = state.value ?? [];
    final isAlreadySaved = currentList.any((r) => r.id == recipe.id);

    if (isAlreadySaved) {
      final newList = currentList.where((r) => r.id != recipe.id).toList();
      state = AsyncValue.data(newList);
      await _repository.removeFavorite(recipe.id);
    } else {
      state = AsyncValue.data([...currentList, recipe]);
      await _repository.saveFavorite(recipe);
    }
  }
  
  // Helper for UI (Heart Icon)
  bool isSaved(int id) {
    return state.value?.any((r) => r.id == id) ?? false;
  }
}

// MAIN FAVORITES PROVIDER
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<Recipe>>>((ref) {
  final repo = ref.watch(recipeRepositoryProvider);
  final inventoryState = ref.watch(inventoryProvider); 

  return FavoritesNotifier(repo, inventoryState);
});

// FILTER PROVIDER
final recipeFilterProvider = StateProvider<Set<String>>((ref) => {});

// The Main Recipe Feed Provider
final recipeFeedProvider = FutureProvider.autoDispose<List<Recipe>>((ref) async {
  
  // Watch Inventory & Filter
  final inventoryState = ref.watch(inventoryProvider);
  final activeFilters = ref.watch(recipeFilterProvider);
  
  final allIngredients = inventoryState.valueOrNull ?? [];
  
  if (allIngredients.isEmpty) return [];

  List<String> ingredientsToSearch;

  if (activeFilters.isEmpty) {
    ingredientsToSearch = allIngredients.map((e) => e.name).toList();
  } else {
    ingredientsToSearch = activeFilters.toList();
  }

  // Call API
  final apiService = ref.read(apiServiceProvider);
  return apiService.fetchRecipesByIngredients(ingredientsToSearch);
});