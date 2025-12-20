import 'package:hive/hive.dart';

part 'shopping_item_model.g.dart';

@HiveType(typeId: 2) 
class ShoppingItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isChecked;

  ShoppingItem({
    required this.id,
    required this.name,
    this.isChecked = false,
  });

  ShoppingItem copyWith({String? id, String? name, bool? isChecked}) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isChecked': isChecked,
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      isChecked: json['isChecked'] ?? false,
    );
  }
}