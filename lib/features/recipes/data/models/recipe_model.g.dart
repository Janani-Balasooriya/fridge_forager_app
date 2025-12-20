// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 4;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as int,
      title: fields[1] as String,
      imageUrl: fields[2] as String,
      usedIngredientCount: fields[3] as int,
      missedIngredientCount: fields[4] as int,
      likes: fields[5] as int,
      usedIngredients: (fields[6] as List).cast<String>(),
      missedIngredients: (fields[7] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.usedIngredientCount)
      ..writeByte(4)
      ..write(obj.missedIngredientCount)
      ..writeByte(5)
      ..write(obj.likes)
      ..writeByte(6)
      ..write(obj.usedIngredients)
      ..writeByte(7)
      ..write(obj.missedIngredients);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
