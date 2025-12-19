import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import this
import '../../features/recipes/data/models/recipe_model.dart';

class ApiService {
  final Dio _dio = Dio();
  
  // READ FROM ENV
  // If the key is missing, this safely falls back to an empty string to prevent crashes
  final String _apiKey = dotenv.env['SPOONACULAR_API_KEY'] ?? ''; 
  
  final String _baseUrl = 'https://api.spoonacular.com/recipes';

  Future<List<Recipe>> fetchRecipesByIngredients(List<String> ingredients) async {
    if (ingredients.isEmpty || _apiKey.isEmpty) return []; // Safety check

    try {
      final response = await _dio.get(
        '$_baseUrl/findByIngredients',
        queryParameters: {
          'ingredients': ingredients.join(','),
          'number': 2,
          'ranking': 1,
          'apiKey': _apiKey, // Using the variable
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      // For debugging
      print("API Error: $e");
      rethrow;
    }
  }

  // Fetch detailed instructions for a specific recipe ID
  Future<List<String>> fetchRecipeInstructions(int recipeId) async {
    if (_apiKey.isEmpty) return [];

    try {
      final response = await _dio.get(
        '$_baseUrl/$recipeId/analyzedInstructions',
        queryParameters: {
          'apiKey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isNotEmpty) {
          // Spoonacular returns a list of steps inside the first element
          final List<dynamic> steps = data[0]['steps'];
          return steps.map((step) => step['step'] as String).toList();
        }
      }
      return [];
    } catch (e) {
      print("API Error (Instructions): $e");
      return ["Instructions not available for this recipe."];
    }
  }
}