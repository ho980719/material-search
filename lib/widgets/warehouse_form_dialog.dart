import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:material_search/data/drift/database.dart';

class WarehouseFormDialog extends StatefulWidget {
  final Warehouse? warehouse;
  final AppDatabase db;

  const WarehouseFormDialog({super.key, this.warehouse, required this.db});

  @override
  State<WarehouseFormDialog> createState() => _WarehouseFormDialogState();
}

class _WarehouseFormDialogState extends State<WarehouseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.warehouse?.name ?? '');
    _memoController = TextEditingController(text: widget.warehouse?.memo ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final memo = _memoController.text;
      final isEditing = widget.warehouse != null;

      try {
        if (isEditing) {
          final updatedWarehouse = (widget.db.update(widget.db.warehouses)
                ..where((tbl) => tbl.id.equals(widget.warehouse!.id)))
              .write(WarehousesCompanion(
            name: Value(name),
            memo: Value(memo),
          ));
        } else {
          await widget.db.into(widget.db.warehouses).insert(WarehousesCompanion.insert(
                name: name,
                memo: Value(memo),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.warehouse != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Row(
        children: [
          Icon(isEditing ? Icons.edit : Icons.add_business, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(isEditing ? '창고 수정' : '창고 등록', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '창고명',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '창고명을 입력해주세요.';
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
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('저장'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
