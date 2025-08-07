class MaterialItem {
  final int id;
  final String name;
  final String location;
  final String quantity;
  final String memo;

  MaterialItem({
    required this.id,
    required this.name,
    required this.location,
    required this.quantity,
    required this.memo,
  });

  // DB 또는 Map → 객체
  factory MaterialItem.fromMap(Map<String, dynamic> map) {
    return MaterialItem(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      name: map['name'] as String,
      location: map['location'] as String,
      quantity: map['quantity'] as String,
      memo: map['memo'] as String,
    );
  }

  // 객체 → Map (DB 저장용)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'quantity': quantity,
      'memo': memo,
    };
  }
}