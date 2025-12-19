// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IngredientAdapter extends TypeAdapter<Ingredient> {
  @override
  final int typeId = 1;

  @override
  Ingredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ingredient(
      id: fields[0] as String?,
      name: fields[1] as String,
      category: fields[2] as String,
      amount: fields[3] as double,
      unit: fields[4] as IngredientUnit,
      expiryDate: fields[5] as DateTime,
      addedDate: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Ingredient obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.expiryDate)
      ..writeByte(6)
      ..write(obj.addedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IngredientUnitAdapter extends TypeAdapter<IngredientUnit> {
  @override
  final int typeId = 0;

  @override
  IngredientUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IngredientUnit.pcs;
      case 1:
        return IngredientUnit.g;
      case 2:
        return IngredientUnit.kg;
      case 3:
        return IngredientUnit.ml;
      case 4:
        return IngredientUnit.l;
      default:
        return IngredientUnit.pcs;
    }
  }

  @override
  void write(BinaryWriter writer, IngredientUnit obj) {
    switch (obj) {
      case IngredientUnit.pcs:
        writer.writeByte(0);
        break;
      case IngredientUnit.g:
        writer.writeByte(1);
        break;
      case IngredientUnit.kg:
        writer.writeByte(2);
        break;
      case IngredientUnit.ml:
        writer.writeByte(3);
        break;
      case IngredientUnit.l:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
