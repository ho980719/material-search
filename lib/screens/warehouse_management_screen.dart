import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:material_search/data/drift/database.dart';
import '../widgets/warehouse_form_dialog.dart';

class WarehouseManagementScreen extends StatefulWidget {
  const WarehouseManagementScreen({super.key});

  @override
  State<WarehouseManagementScreen> createState() =>
      _WarehouseManagementScreenState();
}

class _WarehouseManagementScreenState extends State<WarehouseManagementScreen> {
  late AppDatabase _db;
  List<Warehouse> _warehouses = [];
  bool _isLoading = true;

  // 검색 관련 상태
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'all'; // 'all', 'name'

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _refreshWarehouseList();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _db.close();
    super.dispose();
  }

  Future<void> _refreshWarehouseList() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await (_db.select(_db.warehouses)
            ..where((tbl) {
              if (_searchController.text.isEmpty) {
                return const Constant(true);
              } else {
                if (_searchType == 'all') {
                  return tbl.name.like('%${_searchController.text}%') |
                      tbl.memo.like('%${_searchController.text}%');
                } else {
                  return tbl.name.like('%${_searchController.text}%');
                }
              }
            })
          ).get();

      if (mounted) {
        setState(() {
          _warehouses = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 에러 처리 (예: 스낵바 표시)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는 데 실패했습니다: $e')),
      );
    }
  }

  void _showWarehouseFormDialog({Warehouse? warehouse}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => WarehouseFormDialog(warehouse: warehouse, db: _db),
    );
    if (result == true) {
      _refreshWarehouseList();
    }
  }

  void _deleteWarehouse(int id) async {
    // 사용자 실수를 방지하기 위한 확인 다이얼로그
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말로 이 창고를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // 사용자가 '삭제'를 선택했을 때만 실행
    if (confirm == true) {
      try {
        await (_db.delete(_db.warehouses)..where((tbl) => tbl.id.equals(id))).go();
        // 삭제 후 목록 새로고침
        _refreshWarehouseList();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제에 실패했습니다: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('창고 관리'),
      ),
      body: Column(
        children: [
          // 검색 영역
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _searchType,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('전체')),
                    DropdownMenuItem(value: 'name', child: Text('창고명')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _searchType = value!;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '검색어를 입력해주세요.',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchController.text = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _refreshWarehouseList,
                  icon: const Icon(Icons.search),
                  label: const Text('검색'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // More rectangular shape
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Expanded(
                    flex: 3,
                    child: Text('창고명',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(
                    flex: 5,
                    child: Text('메모',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(
                    flex: 2,
                    child: Center(
                        child: Text('관리',
                            style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
          const Divider(),
          // 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _warehouses.isEmpty
                ? const Center(child: Text('표시할 창고가 없습니다.'))
                : ListView.builder(
              itemCount: _warehouses.length,
              itemBuilder: (context, index) {
                final warehouse = _warehouses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3, child: Text(warehouse.name)),
                        Expanded(
                            flex: 5,
                            child: Text(warehouse.memo ?? '')),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showWarehouseFormDialog(
                                      warehouse: warehouse);
                                } else if (value == 'delete') {

                                  _deleteWarehouse(warehouse.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('수정')),
                                const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('삭제')),
                              ],
                            ),
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWarehouseFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}