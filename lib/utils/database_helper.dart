
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_search/models/material.dart';
import 'package:material_search/models/warehouse.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "material.db";
  static const _databaseVersion = 1;

  // Singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    // DB가 존재하지 않으면 asset에서 복사
    var exists = await databaseExists(path);
    if (!exists) {
      if (kDebugMode) {
        print("Creating new copy from asset");
      }
      try {
        await Directory(dirname(path)).create(recursive: true);
        ByteData data = await rootBundle.load(join("assets", _databaseName));
        List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        // 에러 발생 시 로그 출력
        if (kDebugMode) {
          print("Error copying database: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("Opening existing database");
      }
    }

    return await openDatabase(path, version: _databaseVersion);
  }

  // Warehouse CRUD
  Future<List<Warehouse>> getWarehouses({String query = '', String type = 'all'}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (query.isEmpty) {
      maps = await db.query('warehouses', orderBy: 'name ASC');
    } else {
      if (type == 'all') {
        maps = await db.query(
          'warehouses',
          where: 'name LIKE ? OR memo LIKE ?',
          whereArgs: ['%$query%', '%$query%'],
          orderBy: 'name ASC',
        );
      } else { // type == 'name'
        maps = await db.query(
          'warehouses',
          where: 'name LIKE ?',
          whereArgs: ['%$query%'],
          orderBy: 'name ASC',
        );
      }
    }

    return List.generate(maps.length, (i) {
      return Warehouse.fromMap(maps[i]);
    });
  }

  Future<int> insertWarehouse(Warehouse warehouse) async {
    final db = await database;
    return await db.insert('warehouses', warehouse.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateWarehouse(Warehouse warehouse) async {
    final db = await database;
    return await db.update('warehouses', warehouse.toMap(),
        where: 'id = ?', whereArgs: [warehouse.id]);
  }

  Future<int> deleteWarehouse(int id) async {
    final db = await database;
    return await db.delete('warehouses', where: 'id = ?', whereArgs: [id]);
  }

  // Material CRUD
  Future<List<MaterialItem>> getMaterials(
      {String query = '', String type = 'all'}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (query.isEmpty) {
      maps = await db.query('materials', orderBy: 'name ASC');
    } else {
      String whereClause;
      switch (type) {
        case 'name':
          whereClause = 'name LIKE ?';
          break;
        case 'location':
          whereClause = 'location LIKE ?';
          break;
        case 'all':
        default:
          whereClause = 'name LIKE ? OR location LIKE ? OR memo LIKE ?';
          break;
      }

      List<String> whereArgs = (type == 'all')
          ? ['%$query%', '%$query%', '%$query%']
          : ['%$query%'];

      maps = await db.query(
        'materials',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'name ASC',
      );
    }

    return List.generate(maps.length, (i) {
      return MaterialItem.fromMap(maps[i]);
    });
  }

  Future<int> insertMaterial(MaterialItem material) async {
    final db = await database;
    return await db.insert('materials', material.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateMaterial(MaterialItem material) async {
    final db = await database;
    return await db.update('materials', material.toMap(),
        where: 'id = ?', whereArgs: [material.id]);
  }

  Future<int> deleteMaterial(int id) async {
    final db = await database;
    return await db.delete('materials', where: 'id = ?', whereArgs: [id]);
  }
}
