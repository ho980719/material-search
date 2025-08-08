import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart' hide Material;
import 'package:material_search/data/drift/database.dart';
import 'package:material_search/widgets/material_form_dialog.dart';

class MaterialManagementScreen extends StatefulWidget {
  const MaterialManagementScreen({super.key});

  @override
  State<MaterialManagementScreen> createState() => _MaterialManagementScreenState();
}

class _MaterialManagementScreenState extends State<MaterialManagementScreen> {
  late AppDatabase _db;
  List<Material> _materials = [];
  bool _isLoading = true;

  // 검색 관련 상태
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'all'; // 'all', 'name', 'location'

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _refreshMaterialList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _db.close();
    super.dispose();
  }

  Future<void> _refreshMaterialList() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await (_db.select(_db.materials)
            ..where((tbl) {
              if (_searchController.text.isEmpty) {
                return const Constant(true);
              } else {
                switch (_searchType) {
                  case 'name':
                    return tbl.name.like('%${_searchController.text}%');
                  case 'location':
                    return tbl.location.like('%${_searchController.text}%');
                  case 'all':
                  default:
                    return tbl.name.like('%${_searchController.text}%') |
                        tbl.location.like('%${_searchController.text}%') |
                        tbl.memo.like('%${_searchController.text}%');
                }
              }
            })
          ).get();

      if (mounted) {
        setState(() {
          _materials = data;
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

  void _showMaterialFormDialog({Material? material}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => MaterialFormDialog(material: material, db: _db),
    );
    if (result == true) {
      _refreshMaterialList();
    }
  }

  void _deleteMaterial(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말로 이 자재를 삭제하시겠습니까?'),
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

    if (confirm == true) {
      try {
        await (_db.delete(_db.materials)..where((tbl) => tbl.id.equals(id))).go();
        _refreshMaterialList();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Area
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _searchType,
                        onChanged: (String? newValue) {
                          setState(() {
                            _searchType = newValue!;
                          });
                        },
                        items: <String>['all', 'name', 'location']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value == 'all' ? '전체' : value == 'name' ? '자재명' : '위치'),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '검색어를 입력해주세요.',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchController.text = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton.icon(
                  onPressed: _refreshMaterialList,
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
            const SizedBox(height: 24.0),
            // Material List Header
            const Row(
              children: [
                Expanded(flex: 3, child: Text('품목명', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('위치', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('수량', style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 48), // For the menu button
              ],
            ),
            const Divider(height: 24.0),
            // Material List
            Expanded(
              child: ListView.builder(
                itemCount: _materials.length,
                itemBuilder: (context, index) {
                  final material = _materials[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      title: Text(material.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('위치: ${material.location}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<String>(
                            onSelected: (String result) {
                              if (result == 'edit') {
                                _showMaterialFormDialog(material: material);
                              } else if (result == 'delete') {
                                _deleteMaterial(material.id);
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: ListTile(leading: Icon(Icons.edit), title: Text('수정')),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: ListTile(leading: Icon(Icons.delete), title: Text('삭제')),
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
        onPressed: () => _showMaterialFormDialog(),
        label: const Text('자재 추가'),
        icon: const Icon(Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // More rectangular shape
        ),
      ),
    );
  }
}
