import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

class ChecklistDatabase {
  String dbName = 'grocery_checklist';

  Future<Database> loadSqlStartup() async {
    Database db = await openDatabase('grocery.db', version: 2, onCreate: (Database db, int version) async {
      var sqlScript = await rootBundle.loadString('assets/grocery.txt');
      List<String> sqlScripts = sqlScript.split(";");
      sqlScripts.forEach((v) {
        if (v.isNotEmpty) {
          print(v.trim());
          db.execute(v.trim());
        }
      });
    });

    return db;
  }

  Future<List<Map>> loadItems() async {
    Database db = await loadSqlStartup();

    List<Map> entries = await db.rawQuery('SELECT * FROM $dbName');
    db.close();
    return entries;
  }

  Future<void> deleteItem(title) async {
    Database db = await loadSqlStartup();

    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM $dbName WHERE item = ?', [title]);
    });
    db.close();
  }

  Future<void> addItem(item) async {
    Database db = await loadSqlStartup();

    await db.transaction((txn) async {
      await txn.rawInsert('INSERT INTO $dbName(item) VALUES(?)', [item]);
    });

    db.close();
  }
}
