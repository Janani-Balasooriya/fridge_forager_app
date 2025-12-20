import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/recipe_provider.dart';
import '../../data/models/recipe_model.dart';
import 'recipe_detail_screen.dart';
import '../widgets/filter_modal.dart';
import '../widgets/recipe_card.dart';

class RecipeFeedScreen extends ConsumerWidget {
  const RecipeFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2, // Two tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recipes', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            // Filter Button
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const FilterModal(),
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF2ECC71), // Emerald Green
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2ECC71),
            indicatorWeight: 3,
            tabs: [
              Tab(text: "What to Cook"),
              Tab(text: "Saved Recipes"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: The Feed
            _buildFeedTab(context, ref),

            // TAB 2: Saved Recipes
            _buildSavedTab(context, ref),
          ],
        ),
      ),
    );
  }

  // TAB 1: FEED LIST
  Widget _buildFeedTab(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipeFeedProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Context Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.eco, color: Colors.green, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Recipes based on your fridge items to reduce waste.",
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // The List
          Expanded(
            child: recipesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (recipes) {
                if (recipes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.kitchen, size: 48, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Add items to your fridge to see recipes!", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return GestureDetector(
                      onTap: () => _navigateToDetail(context, recipe),
                      child: RecipeCard(recipe: recipe),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: SAVED LIST
  Widget _buildSavedTab(BuildContext context, WidgetRef ref) {
    // Watch the Favorites Provider
    final savedAsync = ref.watch(favoritesProvider);

    return savedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (savedRecipes) {
        if (savedRecipes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text("No saved recipes yet.", style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: savedRecipes.length,
          itemBuilder: (context, index) {
            final recipe = savedRecipes[index];
            return GestureDetector(
              onTap: () => _navigateToDetail(context, recipe),
              child: RecipeCard(recipe: recipe),
            );
          },
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe),
      ),
    );
  }
}