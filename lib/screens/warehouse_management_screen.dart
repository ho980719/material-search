
import 'package:flutter/material.dart';
import 'package:material_search/widgets/warehouse_form_dialog.dart';
import 'package:material_search/widgets/warehouse_selection_dialog.dart';

class WarehouseManagementScreen extends StatefulWidget {
  const WarehouseManagementScreen({super.key});

  @override
  State<WarehouseManagementScreen> createState() =>
      _WarehouseManagementScreenState();
}

class _WarehouseManagementScreenState extends State<WarehouseManagementScreen> {
  final List<Warehouse> _warehouses = [
    Warehouse(id: 'W001', name: '본사 창고', memo: '본사 건물 지하 1층'),
    Warehouse(id: 'W002', name: '부산 지점 창고', memo: '지점 건물 1층'),
    Warehouse(id: 'W003', name: '물류센터', memo: '대형 물류 단지 내'),
  ];
  String _searchType = '전체';
  final TextEditingController _searchController = TextEditingController();

  void _showWarehouseFormDialog({Warehouse? warehouse}) {
    showDialog(
      context: context,
      builder: (context) {
        return WarehouseFormDialog(warehouse: warehouse);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색 영역
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    value: _searchType,
                    onChanged: (value) {
                      setState(() {
                        _searchType = value!;
                      });
                    },
                    items: ['전체', '창고명']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '검색어를 입력해주세요.',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // 검색 로직
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 20.0,
                    ),
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Expanded(flex: 4, child: Text('창고명', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 6, child: Text('메모', style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 48, child: Container()), // PopupMenuButton 자리
                ],
              ),
            ),
            const Divider(),
            // 목록
            Expanded(
              child: ListView.builder(
                itemCount: _warehouses.length,
                itemBuilder: (context, index) {
                  final warehouse = _warehouses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                      child: Row(
                        children: [
                          Expanded(flex: 4, child: Text(warehouse.name)),
                          Expanded(flex: 6, child: Text(warehouse.memo, overflow: TextOverflow.ellipsis)),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showWarehouseFormDialog(warehouse: warehouse);
                              } else if (value == 'delete') {
                                // 삭제 로직
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('수정'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('삭제'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showWarehouseFormDialog();
        },
        label: const Text('창고 추가'),
        icon: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
