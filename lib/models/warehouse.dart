class Warehouse {
  final int id;
  final String name;
  final String memo;

  Warehouse({required this.id, required this.name, required this.memo});

  // DB → 객체
  factory Warehouse.fromMap(Map<String, dynamic> map) {
    return Warehouse(
      id: map['id'] as int,
      name: map['name'] as String,
      memo: map['memo'] as String,
    );
  }

  // 객체 → DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'memo': memo,
    };
  }
}