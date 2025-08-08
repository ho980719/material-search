import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart' hide Material;
import 'package:material_search/data/drift/database.dart';
import './warehouse_selection_dialog.dart';

class MaterialFormDialog extends StatefulWidget {
  final Material? material;
  final AppDatabase db;

  const MaterialFormDialog({super.key, this.material, required this.db});

  @override
  State<MaterialFormDialog> createState() => _MaterialFormDialogState();
}

class _MaterialFormDialogState extends State<MaterialFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _memoController;
  int? _selectedWarehouseId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.material?.name ?? '');
    _locationController = TextEditingController(text: widget.material?.location ?? '');
    _memoController = TextEditingController(text: widget.material?.memo ?? '');
    _selectedWarehouseId = widget.material?.warehouseId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final location = _locationController.text;
      final memo = _memoController.text;
      final isEditing = widget.material != null;

      if (_selectedWarehouseId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('창고를 선택해주세요.')),
        );
        return;
      }

      try {
        if (isEditing) {
          await (widget.db.update(widget.db.materials)
                ..where((tbl) => tbl.id.equals(widget.material!.id)))
              .write(MaterialsCompanion(
            name: Value(name),
            location: Value(location),
            memo: Value(memo),
            warehouseId: Value(_selectedWarehouseId!),
          ));
        } else {
          await widget.db.into(widget.db.materials).insert(MaterialsCompanion.insert(
                name: name,
                location: location,
                memo: Value(memo),
                warehouseId: _selectedWarehouseId!,
              ));
        }
        if (mounted) {
          Navigator.of(context).pop(true); // Indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('저장에 실패했습니다: $e')),
          );
        }
      }
    }
  }

  void _showWarehouseSelectionDialog() async {
    final warehouses = await widget.db.select(widget.db.warehouses).get();
    final selectedWarehouse = await showDialog<Warehouse>(
      context: context,
      builder: (context) => WarehouseSelectionDialog(warehouses: warehouses),
    );

    if (selectedWarehouse != null) {
      setState(() {
        _locationController.text = selectedWarehouse.name;
        _selectedWarehouseId = selectedWarehouse.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: Row(
        children: [
          Icon(
            widget.material == null ? Icons.add_box_rounded : Icons.edit_note_rounded,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12.0),
          Text(
            widget.material == null ? '자재 등록' : '자재 수정',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '품목명',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '품목명을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: '위치',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                onTap: _showWarehouseSelectionDialog,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '위치를 선택해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: '메모',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('취소'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save_alt_rounded),
          label: const Text('저장'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: _save,
        ),
      ],
    );
  }
}
