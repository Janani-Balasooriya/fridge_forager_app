import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/ingredient_model.dart';
import '../../logic/inventory_provider.dart';

class AddItemModal extends ConsumerStatefulWidget {
  final Ingredient? itemToEdit;

  const AddItemModal({super.key, this.itemToEdit});

  @override
  ConsumerState<AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends ConsumerState<AddItemModal> {
  final _nameController = TextEditingController();
  
  String _selectedCategory = 'Dairy';
  double _amount = 1.0;
  IngredientUnit _selectedUnit = IngredientUnit.pcs;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));

  final List<String> _categories = ['Dairy', 'Vegetable', 'Fruit', 'Meat', 'Pantry'];

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      final item = widget.itemToEdit!;
      _nameController.text = item.name;
      _selectedCategory = item.category;
      _amount = item.amount;
      _selectedUnit = item.unit;
      _expiryDate = item.expiryDate;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _saveItem() {
    if (_nameController.text.isEmpty) return;

    final String idToUse = widget.itemToEdit?.id ?? const Uuid().v4();
    final DateTime addedDateToUse = widget.itemToEdit?.addedDate ?? DateTime.now();

    final newItem = Ingredient(
      id: idToUse,
      name: _nameController.text,
      category: _selectedCategory,
      amount: _amount,
      unit: _selectedUnit,
      expiryDate: _expiryDate,
      addedDate: addedDateToUse,
    );

    if (widget.itemToEdit != null) {
      ref.read(inventoryProvider.notifier).updateItem(newItem);
    } else {
      ref.read(inventoryProvider.notifier).addItem(newItem);
    }
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, 
        right: 20, 
        top: 20, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.itemToEdit != null ? "Edit Item" : "Add New Item", 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Item Name", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),

          const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (bool selected) => setState(() => _selectedCategory = cat),
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: _amount.toString(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Amount", border: OutlineInputBorder()),
                  onChanged: (val) => setState(() => _amount = double.tryParse(val) ?? 1.0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<IngredientUnit>(
                  value: _selectedUnit,
                  decoration: const InputDecoration(labelText: "Unit", border: OutlineInputBorder()),
                  items: IngredientUnit.values.map((unit) => DropdownMenuItem(value: unit, child: Text(unit.name))).toList(),
                  onChanged: (val) => setState(() => _selectedUnit = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Expiry Date",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(DateFormat('yyyy-MM-dd').format(_expiryDate)),
            ),
          ),
          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: _saveItem,
              child: Text(widget.itemToEdit != null ? "Update Item" : "Save Item"),
            ),
          ),
        ],
      ),
    );
  }
}