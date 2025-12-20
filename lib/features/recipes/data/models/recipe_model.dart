import 'package:hive/hive.dart';

part 'recipe_model.g.dart';

@HiveType(typeId: 4) // ID 4
class Recipe {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final int usedIngredientCount;

  @HiveField(4)
  final int missedIngredientCount;

  @HiveField(5)
  final int likes;

  @HiveField(6)
  final List<String> usedIngredients;

  @HiveField(7)
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

  // FROM API
  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> extractNames(List<dynamic>? list) {
      if (list == null) return [];
      // Handles both direct string lists (from Firebase) and object lists (from API)
      if (list.isNotEmpty && list.first is String) {
         return List<String>.from(list);
      }
      return list.map((item) => item['name'] as String).toList();
    }

    return Recipe(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image'] ?? '', // Added safety check for null image
      usedIngredientCount: json['usedIngredientCount'] ?? 0,
      missedIngredientCount: json['missedIngredientCount'] ?? 0,
      likes: json['likes'] ?? 0,
      usedIngredients: extractNames(json['usedIngredients']),
      missedIngredients: extractNames(json['missedIngredients']),
    );
  }

  // TO JSON (For Firebase Saving)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': imageUrl, // API calls it 'image', so we keep it consistent
      'usedIngredientCount': usedIngredientCount,
      'missedIngredientCount': missedIngredientCount,
      'likes': likes,
      'usedIngredients': usedIngredients, // Saves as simple List<String>
      'missedIngredients': missedIngredients,
    };
  }

  Recipe copyWith({
    int? usedIngredientCount,
    int? missedIngredientCount,
    List<String>? usedIngredients,
    List<String>? missedIngredients,
  }) {
    return Recipe(
      id: id,
      title: title,
      imageUrl: imageUrl,
      likes: likes,
      usedIngredientCount: usedIngredientCount ?? this.usedIngredientCount,
      missedIngredientCount: missedIngredientCount ?? this.missedIngredientCount,
      usedIngredients: usedIngredients ?? this.usedIngredients,
      missedIngredients: missedIngredients ?? this.missedIngredients,
    );
  }
}