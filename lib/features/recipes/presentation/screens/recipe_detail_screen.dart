import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recipe_model.dart';
import '../../logic/recipe_provider.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  List<String> _instructions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInstructions();
  }

  Future<void> _loadInstructions() async {
    // Simulate it to prevent errors if API isn't ready
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _instructions = ["Step 1: Chop everything.", "Step 2: Cook it.", "Step 3: Eat it."];
        _isLoading = false;
      });
    }
  }

  void _cookThisNow(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Cooking started! Inventory updated."),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // WATCH FAVORITES (To update the heart icon)
    final favoritesState = ref.watch(favoritesProvider);
    final isSaved = ref.read(favoritesProvider.notifier).isSaved(widget.recipe.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            // HEART BUTTON
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
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
                    ref.read(favoritesProvider.notifier).toggleFavorite(widget.recipe);
                  },
                ),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.recipe.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Image.network(
                widget.recipe.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(color: Colors.grey),
              ),
            ),
          ),
        
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags
                    Row(
                      children: [
                        _buildTag("High Protein", Colors.blue[100]!),
                        const SizedBox(width: 10),
                        _buildTag("30 Mins", Colors.orange[100]!),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // INGREDIENTS
                    const Text("Ingredients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...widget.recipe.usedIngredients.map((ing) => _buildIngredientTile(context, ing, true)),
                    ...widget.recipe.missedIngredients.map((ing) => _buildIngredientTile(context, ing, false)),
                    
                    const SizedBox(height: 25),
                    const Divider(),
                    const SizedBox(height: 15),

                    // INSTRUCTIONS
                    const Text("Instructions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    
                    if (_isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
                    else 
                      ..._instructions.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                child: Text("${entry.key + 1}", style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 14, height: 1.5))),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 80), 
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onPressed: () => _cookThisNow(context),
          child: const Text("Cook This Now"),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildIngredientTile(BuildContext context, String name, bool isAvailable) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.warning_rounded,
            color: isAvailable ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}