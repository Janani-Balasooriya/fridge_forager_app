class Recipe {
  final int id;
  final String title;
  final String imageUrl;
  final int usedIngredientCount;
  final int missedIngredientCount;
  final int likes;
  final List<String> usedIngredients;
  final List<String> missedIngredients;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.usedIngredientCount,
    required this.missedIngredientCount,
    required this.likes,
    required this.usedIngredients,
    required this.missedIngredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> extractNames(List<dynamic>? list) {
      if (list == null) return [];
      return list.map((item) => item['name'] as String).toList();
    }

    return Recipe(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image'],
      usedIngredientCount: json['usedIngredientCount'],
      missedIngredientCount: json['missedIngredientCount'],
      likes: json['likes'],
      usedIngredients: extractNames(json['usedIngredients']),
      missedIngredients: extractNames(json['missedIngredients']),
    );
  }
}