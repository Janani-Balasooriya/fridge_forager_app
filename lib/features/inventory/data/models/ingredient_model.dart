import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'ingredient_model.g.dart';

@HiveType(typeId: 0) // Unique ID for this class
enum IngredientUnit {
  @HiveField(0) pcs,
  @HiveField(1) g,
  @HiveField(2) kg,
  @HiveField(3) ml,
  @HiveField(4) l
}

@HiveType(typeId: 1) // Unique ID for this class
class Ingredient extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final IngredientUnit unit;

  @HiveField(5)
  final DateTime expiryDate;

  @HiveField(6)
  final DateTime addedDate;

  Ingredient({
    String? id,
    required this.name,
    required this.category,
    required this.amount,
    required this.unit,
    required this.expiryDate,
    required this.addedDate,
  }) : id = id ?? const Uuid().v4();
  
  // Helper for UI display
  String get displayQuantity => "$amount ${unit.name}";

  // CONVERT TO JSON (For Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'amount': amount,
      // Convert Enum to String
      'unit': unit.name, 
      // Convert DateTime to ISO String
      'expiryDate': expiryDate.toIso8601String(),
      'addedDate': addedDate.toIso8601String(),
    };
  }

  // CONVERT FROM JSON (From Firestore)
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      // Convert String back to Enum
      unit: IngredientUnit.values.firstWhere((e) => e.name == json['unit']),
      // Convert String back to DateTime
      expiryDate: DateTime.parse(json['expiryDate']),
      addedDate: DateTime.parse(json['addedDate']),
    );
  }
}