
import 'package:flutter/material.dart';
import 'package:material_search/models/warehouse.dart';

class WarehouseSelectionDialog extends StatefulWidget {
  final List<Warehouse> warehouses;

  const WarehouseSelectionDialog({Key? key, required this.warehouses}) : super(key: key);

  @override
  _WarehouseSelectionDialogState createState() => _WarehouseSelectionDialogState();
}

class _WarehouseSelectionDialogState extends State<WarehouseSelectionDialog> {
  late List<Warehouse> _filteredWarehouses;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredWarehouses = widget.warehouses;
    _searchController.addListener(() {
      _filterWarehouses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterWarehouses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredWarehouses = widget.warehouses.where((warehouse) {
        return warehouse.name.toLowerCase().contains(query) ||
               warehouse.memo.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('창고 선택'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: '창고 검색',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredWarehouses.length,
                itemBuilder: (context, index) {
                  final warehouse = _filteredWarehouses[index];
                  return ListTile(
                    title: Text(warehouse.name),
                    subtitle: Text(warehouse.memo),
                    onTap: () {
                      Navigator.of(context).pop(warehouse);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
      ],
    );
  }
}
