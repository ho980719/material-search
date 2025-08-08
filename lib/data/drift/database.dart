import 'package:drift/drift.dart';

// These imports are used to open the database
import 'connection/connection.dart' as connection;

part 'database.g.dart';

// Tables
class Warehouses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get memo => text().nullable()();
}

class Materials extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get location => text()();
  TextColumn get memo => text().nullable()();
  IntColumn get warehouseId => integer().references(Warehouses, #id)();
}

@DriftDatabase(tables: [Warehouses, Materials])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.openConnection());

  @override
  int get schemaVersion => 1;
}
