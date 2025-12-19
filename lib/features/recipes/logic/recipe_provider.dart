import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../inventory/logic/inventory_provider.dart';
import '../data/models/recipe_model.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// FILTER PROVIDER
// Stores the names of ingredients the user wants to include.
// If empty, we assume "Use Everything".
final recipeFilterProvider = StateProvider<Set<String>>((ref) => {});

// The Main Recipe Feed Provider
final recipeFeedProvider = FutureProvider.autoDispose<List<Recipe>>((ref) async {
  
  // Watch Inventory & Filter
  final inventoryState = ref.watch(inventoryProvider);
  final activeFilters = ref.watch(recipeFilterProvider);
  
  final allIngredients = inventoryState.valueOrNull ?? [];
  
  if (allIngredients.isEmpty) return [];

  // Determine which ingredients to send to API
  List<String> ingredientsToSearch;

  if (activeFilters.isEmpty) {
    // Default: Use EVERYTHING in the fridge
    ingredientsToSearch = allIngredients.map((e) => e.name).toList();
  } else {
    // Filtered: Use only what the user selected
    ingredientsToSearch = activeFilters.toList();
  }

  // Call API
  final apiService = ref.read(apiServiceProvider);
  return apiService.fetchRecipesByIngredients(ingredientsToSearch);
});