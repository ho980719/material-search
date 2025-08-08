import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

DatabaseConnection openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    final db = await WasmDatabase.open(
      databaseName: 'material',
      sqlite3Uri: Uri.parse('/sqlite3.wasm'),
      driftWorkerUri: Uri.parse('/drift_worker.js'),
    );

    if (db.missingFeatures.isNotEmpty) {
      print('Unsupported features: ${db.missingFeatures}');
    }

    return db.resolvedExecutor;
  }));
}
