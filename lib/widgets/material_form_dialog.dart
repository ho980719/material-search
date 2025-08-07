
import 'package:flutter/material.dart';
import './warehouse_selection_dialog.dart';

class MaterialFormDialog extends StatefulWidget {
  final Map<String, String>? material;

  const MaterialFormDialog({super.key, this.material});

  @override
  State<MaterialFormDialog> createState() => _MaterialFormDialogState();
}

class _MaterialFormDialogState extends State<MaterialFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _quantityController;
  late TextEditingController _memoController;

  // Dummy warehouse data for demonstration
  final List<Warehouse> _warehouses = [
    Warehouse(id: '1', name: '창고 A', memo: '서울시 강남구'),
    Warehouse(id: '2', name: '창고 B', memo: '경기도 판교'),
    Warehouse(id: '3', name: '창고 C', memo: '인천시 서구'),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.material?['name'] ?? '');
    _locationController = TextEditingController(text: widget.material?['location'] ?? '');
    _quantityController = TextEditingController(text: widget.material?['quantity'] ?? '');
    _memoController = TextEditingController(text: widget.material?['memo'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _showWarehouseSelectionDialog() async {
    final selectedWarehouse = await showDialog<Warehouse>(
      context: context,
      builder: (context) => WarehouseSelectionDialog(warehouses: _warehouses),
    );

    if (selectedWarehouse != null) {
      setState(() {
        _locationController.text = selectedWarehouse.name;
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
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: '수량',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_list_numbered_rtl_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '수량을 입력해주세요.';
                  }
                  if (int.tryParse(value) == null) {
                    return '숫자만 입력해주세요.';
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // TODO: Implement save logic with selected warehouse
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
