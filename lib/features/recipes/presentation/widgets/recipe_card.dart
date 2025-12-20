import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recipe_model.dart';
import '../../logic/recipe_provider.dart';

class RecipeCard extends ConsumerWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // LISTEN TO FAVORITES
    final favoritesState = ref.watch(favoritesProvider);
    
    // CHECK IF THIS RECIPE IS SAVED
    final isSaved = favoritesState.value?.any((r) => r.id == recipe.id) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE SECTION
          Stack(
            children: [
              // Recipe Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  recipe.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              
              // HEART BUTTON (Top Right)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      // TRIGGER SAVE/UNSAVE
                      ref.read(favoritesProvider.notifier).toggleFavorite(recipe);
                    },
                  ),
                ),
              ),
            ],
          ),

          // DETAILS SECTION
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Stats Row
                Row(
                  children: [
                    // Used Ingredients (Green)
                    _buildTag(
                      icon: Icons.check_circle_outline,
                      text: "${recipe.usedIngredientCount} Used",
                      color: const Color(0xFF2ECC71),
                    ),
                    const SizedBox(width: 8),
                    
                    // Missing Ingredients (Orange)
                    _buildTag(
                      icon: Icons.shopping_cart_outlined,
                      text: "${recipe.missedIngredientCount} Missing",
                      color: const Color(0xFFFF9F1C),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Likes Count
                Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "${recipe.likes} Likes",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for the tags
  Widget _buildTag({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}