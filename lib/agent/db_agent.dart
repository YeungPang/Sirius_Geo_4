import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseAgent {
  final int version;
  final String dbName;
  String? dbtable;
  String? dbindex;
  Database? db;

  DataBaseAgent(
      {required this.version,
      required this.dbName,
      this.dbtable,
      this.dbindex});

  Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), dbName),
        onCreate: (db, version) async {
      if (dbtable != null) {
        await db.execute(dbtable!);
      }
    }, version: version);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    db ??= await _getDB();
    return await db!.insert(table, data);
  }

  Future<int> update(String table, Map<String, dynamic> map) async {
    db ??= await _getDB();
    return await db!
        .update(table, map["data"], where: "id = ?", whereArgs: [map["id"]]);
  }

  Future<int> delete(String table, Map<String, dynamic> data) async {
    db ??= await _getDB();
    return await db!.delete(table, where: "id = ?", whereArgs: [data["id"]]);
  }

  Future<List<Map<String, dynamic>>> query(
      String table, Map<String, dynamic> whereData) async {
    db ??= await _getDB();
    return await db!
        .query(table, where: whereData["where"], whereArgs: whereData["list"]);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql) async {
    db ??= await _getDB();
    return await db!.rawQuery(sql);
  }

  Future<void> close() async {
    db ??= await _getDB();
    await db!.close();
  }

  Future<void> deleteDB() async {
    bool exists = await databaseExists(join(await getDatabasesPath(), dbName));
    if (exists) {
      db ??= await _getDB();
      if (db != null) {
        await db!.close();
        await deleteDatabase(join(await getDatabasesPath(), dbName));
      }
    }
  }
}
