
import 'package:flutter/material.dart';
import 'package:material_search/widgets/material_form_dialog.dart';

class MaterialManagementScreen extends StatefulWidget {
  const MaterialManagementScreen({super.key});

  @override
  State<MaterialManagementScreen> createState() => _MaterialManagementScreenState();
}

class _MaterialManagementScreenState extends State<MaterialManagementScreen> {
  String _searchType = '전체';
  final TextEditingController _searchTextController = TextEditingController();

  // Dummy data for the list
  final List<Map<String, String>> _materials = [
    {'name': '자재 A', 'location': '선반 1', 'quantity': '10', 'memo': '메모 내용 1'},
    {'name': '자재 B', 'location': '선반 2', 'quantity': '20', 'memo': '메모 내용 2'},
    {'name': '자재 C', 'location': '선반 3', 'quantity': '30', 'memo': '메모 내용 3'},
  ];

  void _showMaterialFormDialog({Map<String, String>? material}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MaterialFormDialog(material: material);
      },
    );
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
                        items: <String>['전체', '자재명', '위치']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
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
                    controller: _searchTextController,
                    decoration: const InputDecoration(
                      hintText: '검색어를 입력해주세요.',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement search logic
                  },
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
                      title: Text(material['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('위치: ${material['location']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${material['quantity']} 개', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(width: 16),
                          PopupMenuButton<String>(
                            onSelected: (String result) {
                              if (result == 'edit') {
                                _showMaterialFormDialog(material: material);
                              }
                              // TODO: Implement other menu actions
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'memo',
                                child: ListTile(leading: Icon(Icons.note), title: Text('메모')),
                              ),
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
